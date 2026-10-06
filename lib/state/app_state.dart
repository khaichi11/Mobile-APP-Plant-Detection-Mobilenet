import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../data/game_levels.dart';
import '../data/lessons.dart';
import '../data/missions.dart';
import '../data/plant_catalog.dart';
import '../data/story_levels.dart';
import '../models/app_notification.dart';
import '../models/collection_entry.dart';
import '../models/mission.dart';
import '../models/user_profile.dart';
import '../services/account_repository.dart';
import '../services/local_database.dart';
import '../services/photo_store.dart';
import 'game_rules.dart';
import 'player_data.dart';

class CollectResult {
  const CollectResult({required this.isNewSpecies, required this.points});
  final bool isNewSpecies;
  final int points;
}

/// The single source of truth for the signed-in player. Every change is
/// saved to the local database right away.
class AppState extends ChangeNotifier {
  AppState({
    required LocalDatabase database,
    required AccountRepository accounts,
    required PhotoStore photos,
    DateTime Function()? clock,
  }) : _db = database,
       _accounts = accounts,
       _photos = photos,
       _clock = clock ?? DateTime.now;

  static const _onboardingKey = 'onboarding.v1';
  static const _maxNotifications = 60;

  final LocalDatabase _db;
  final AccountRepository _accounts;
  final PhotoStore _photos;
  final DateTime Function() _clock;

  UserProfile? _user;
  PlayerData _data = PlayerData();
  int _idCounter = 0;

  UserProfile? get user => _user;
  bool get isSignedIn => _user != null;
  PlayerData get data => _data;
  bool get onboardingDone => _db.read(_onboardingKey) == 'done';

  // ---------------------------------------------------------------------------
  // Session

  /// Loads the user who was signed in last time, if any.
  void restoreSession() {
    final user = _accounts.currentUser();
    if (user != null) _loadPlayer(user);
  }

  Future<void> completeOnboarding() async {
    await _db.write(_onboardingKey, 'done');
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required int grade,
  }) async {
    final user = await _accounts.register(
      name: name,
      email: email,
      password: password,
      grade: grade,
    );
    _loadPlayer(user);
    _welcome();
    await _save();
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    final user = await _accounts.signIn(email: email, password: password);
    _loadPlayer(user);
    notifyListeners();
  }

  Future<void> continueAsGuest({
    required String name,
    required int grade,
  }) async {
    final user = await _accounts.continueAsGuest(name: name, grade: grade);
    _loadPlayer(user);
    _welcome();
    await _save();
    notifyListeners();
  }

  Future<void> signOut() async {
    final user = _user;
    if (user != null && user.isGuest) {
      await _deletePhotos();
      await _db.delete(_playerKey(user.id));
    }
    await _accounts.signOut();
    _user = null;
    _data = PlayerData();
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    int? grade,
    String? avatarSourcePath,
  }) async {
    final current = _user;
    if (current == null) return;
    if (name != null) {
      final error = AccountRepository.validateName(name);
      if (error != null) throw AuthException(error);
    }
    String? avatarPath;
    if (avatarSourcePath != null) {
      avatarPath = await _photos.save(avatarSourcePath, folder: 'avatars');
      final old = current.avatarPath;
      if (old != null) await _photos.delete(old);
    }
    final updated = current.copyWith(
      name: name?.trim(),
      grade: grade,
      avatarPath: avatarPath,
    );
    await _accounts.updateProfile(updated);
    _user = updated;
    notifyListeners();
  }

  /// Clears points, stars, the herbarium and notifications.
  Future<void> resetProgress() async {
    await _deletePhotos();
    _data = PlayerData();
    await _save();
    notifyListeners();
  }

  void _loadPlayer(UserProfile user) {
    _user = user;
    final raw = _db.read(_playerKey(user.id));
    _data =
        raw == null
            ? PlayerData()
            : PlayerData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  void _welcome() {
    _notify(
      NotificationKind.info,
      'Welcome to Pandai, ${_user!.name}!',
      'Scan a plant outside or start the PETA adventure to earn your first '
          'points.',
    );
  }

  Future<void> _deletePhotos() async {
    for (final entry in _data.collection) {
      await _photos.delete(entry.imagePath);
    }
  }

  String _playerKey(String userId) => 'player.v1.$userId';

  Future<void> _save() async {
    final user = _user;
    if (user == null) return;
    await _db.write(_playerKey(user.id), jsonEncode(_data.toJson()));
  }

  // ---------------------------------------------------------------------------
  // Derived values

  RankProgress get rank => RankProgress.fromPoints(_data.points);

  int get unreadNotifications =>
      _data.notifications.where((n) => !n.read).length;

  String get _today => _dateKey(_clock());

  /// Days since 1970 for today, used to pick daily missions and quizzes.
  int get dayIndex {
    final now = _clock();
    return DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  static String _dateKey(DateTime time) =>
      '${time.year.toString().padLeft(4, '0')}-'
      '${time.month.toString().padLeft(2, '0')}-'
      '${time.day.toString().padLeft(2, '0')}';

  DailyState get _daily {
    final today = _today;
    final current = _data.daily;
    if (current != null && current.date == today) return current;
    return _data.daily = DailyState(date: today);
  }

  List<Mission> get todaysMissions => missionsForDay(dayIndex);

  int missionProgress(Mission mission) {
    final daily = _data.daily;
    if (daily == null || daily.date != _today) return 0;
    return math.min(daily.counters[mission.event.name] ?? 0, mission.target);
  }

  bool isMissionComplete(Mission mission) =>
      missionProgress(mission) >= mission.target;

  bool isMissionClaimed(Mission mission) {
    final daily = _data.daily;
    return daily != null &&
        daily.date == _today &&
        daily.claimedMissions.contains(mission.id);
  }

  int get hintsLeft {
    final daily = _data.daily;
    final used = daily != null && daily.date == _today ? daily.hintsUsed : 0;
    return math.max(0, GameRules.dailyHints - used);
  }

  /// Correct answers in today's quiz, or null when not played today.
  int? get dailyQuizScore {
    final daily = _data.daily;
    return daily != null && daily.date == _today ? daily.quizScore : null;
  }

  bool hasSpecies(String scientificName) =>
      _data.collection.any((e) => e.scientificName == scientificName);

  int storyStars(String levelId) => _data.storyStars[levelId] ?? 0;

  bool isStoryUnlocked(String levelId) {
    final index = storyLevels.indexWhere((level) => level.id == levelId);
    if (index <= 0) return index == 0;
    return _data.storyStars.containsKey(storyLevels[index - 1].id);
  }

  /// Index of the first story level that is unlocked but not finished.
  int get currentStoryIndex {
    final index = storyLevels.indexWhere(
      (level) => !_data.storyStars.containsKey(level.id),
    );
    return index == -1 ? storyLevels.length - 1 : index;
  }

  bool isPuzzleUnlocked(int number) =>
      number == 1 || _data.puzzleStars.containsKey(number - 1);

  bool isMemoryUnlocked(int number) =>
      number == 1 || _data.memoryStars.containsKey(number - 1);

  // ---------------------------------------------------------------------------
  // Actions

  /// Call when the classifier recognised a plant with enough confidence.
  Future<void> recordScan(String scientificName) async {
    _touchStreak();
    _data.totalScans++;
    final daily = _daily;
    if (daily.speciesScanned.add(scientificName)) {
      _setCounter(GameEvent.scan, daily.speciesScanned.length);
    }
    _afterChange();
    await _save();
    notifyListeners();
  }

  /// Saves the photo to the herbarium. A plant that is already in the
  /// herbarium gets its photo replaced instead, without points.
  Future<CollectResult> addToCollection({
    required String scientificName,
    required String sourceImagePath,
    required double confidence,
  }) async {
    final path = await _photos.save(sourceImagePath, folder: 'herbarium');
    final existingIndex = _data.collection.indexWhere(
      (e) => e.scientificName == scientificName,
    );
    if (existingIndex != -1) {
      final existing = _data.collection[existingIndex];
      await _photos.delete(existing.imagePath);
      _data.collection[existingIndex] = CollectionEntry(
        id: existing.id,
        scientificName: scientificName,
        imagePath: path,
        confidence: confidence,
        foundAt: existing.foundAt,
      );
      await _save();
      notifyListeners();
      return const CollectResult(isNewSpecies: false, points: 0);
    }

    _touchStreak();
    _data.collection.insert(
      0,
      CollectionEntry(
        id: _newId(),
        scientificName: scientificName,
        imagePath: path,
        confidence: confidence,
        foundAt: _clock(),
      ),
    );
    _data.points += GameRules.newSpeciesPoints;
    _count(GameEvent.newSpecies);
    final name =
        plantByScientificName(scientificName)?.commonName ?? scientificName;
    _notify(
      NotificationKind.discovery,
      'New plant: $name',
      'You added it to your herbarium and earned '
          '${GameRules.newSpeciesPoints} points.',
    );
    _afterChange();
    await _save();
    notifyListeners();
    return const CollectResult(
      isNewSpecies: true,
      points: GameRules.newSpeciesPoints,
    );
  }

  Future<void> removeFromCollection(String entryId) async {
    final index = _data.collection.indexWhere((e) => e.id == entryId);
    if (index == -1) return;
    final entry = _data.collection.removeAt(index);
    await _photos.delete(entry.imagePath);
    await _save();
    notifyListeners();
  }

  /// Returns the points earned.
  Future<int> completeStoryLevel(String levelId, int stars) async {
    final previous = _data.storyStars[levelId];
    final earned = GameRules.pointsForImprovement(previous ?? 0, stars);
    _data.storyStars[levelId] = math.max(previous ?? 0, stars);
    _data.points += earned;
    _touchStreak();
    _count(GameEvent.storyLevel);
    if (previous == null) {
      final index = storyLevels.indexWhere((level) => level.id == levelId);
      if (index != -1 && index + 1 < storyLevels.length) {
        _notify(
          NotificationKind.unlock,
          'New adventure unlocked',
          '"${storyLevels[index + 1].title}" is waiting for you on the map.',
        );
      }
    }
    _afterChange();
    await _save();
    notifyListeners();
    return earned;
  }

  /// Returns the points earned.
  Future<int> completePuzzle(
    int number, {
    required int stars,
    required int moves,
  }) async {
    final previous = _data.puzzleStars[number];
    final earned = GameRules.pointsForImprovement(previous ?? 0, stars);
    _data.puzzleStars[number] = math.max(previous ?? 0, stars);
    final best = _data.puzzleBestMoves[number];
    _data.puzzleBestMoves[number] =
        best == null ? moves : math.min(best, moves);
    _data.points += earned;
    _touchStreak();
    _count(GameEvent.puzzle);
    if (previous == null && number < puzzleLevels.length) {
      _notify(
        NotificationKind.unlock,
        'Puzzle ${number + 1} unlocked',
        'A new plant picture is ready to be solved.',
      );
    }
    _afterChange();
    await _save();
    notifyListeners();
    return earned;
  }

  /// Returns the points earned.
  Future<int> completeMemory(int number, int stars) async {
    final previous = _data.memoryStars[number];
    final earned = GameRules.pointsForImprovement(previous ?? 0, stars);
    _data.memoryStars[number] = math.max(previous ?? 0, stars);
    _data.points += earned;
    _touchStreak();
    _count(GameEvent.memory);
    if (previous == null && number < memoryLevels.length) {
      _notify(
        NotificationKind.unlock,
        'Memory level ${number + 1} unlocked',
        'More plants to match. Can you remember them all?',
      );
    }
    _afterChange();
    await _save();
    notifyListeners();
    return earned;
  }

  /// Returns the points earned.
  Future<int> completePlantParts(int stars) async {
    final earned = GameRules.pointsForImprovement(_data.plantPartsStars, stars);
    _data.plantPartsStars = math.max(_data.plantPartsStars, stars);
    _data.points += earned;
    _touchStreak();
    _count(GameEvent.plantParts);
    _afterChange();
    await _save();
    notifyListeners();
    return earned;
  }

  /// Points are only given for the first quiz of the day. Returns the points
  /// earned.
  Future<int> completeDailyQuiz(int correct, int total) async {
    final daily = _daily;
    _touchStreak();
    var earned = 0;
    if (daily.quizScore == null) {
      daily.quizScore = correct;
      earned = correct * GameRules.quizPointsPerCorrect;
      _data.points += earned;
      if (correct == total) _data.perfectQuizzes++;
      _count(GameEvent.dailyQuiz);
    }
    _afterChange();
    await _save();
    notifyListeners();
    return earned;
  }

  Future<void> markLessonRead(String lessonId) async {
    _touchStreak();
    if (_data.lessonsRead.add(lessonId)) {
      _count(GameEvent.lesson);
    } else if ((_daily.counters[GameEvent.lesson.name] ?? 0) == 0) {
      // Re-reading still counts for today's mission.
      _count(GameEvent.lesson);
    }
    _afterChange();
    await _save();
    notifyListeners();
  }

  /// Uses one of today's puzzle hints. Returns false when none are left.
  Future<bool> useHint() async {
    if (hintsLeft == 0) return false;
    _daily.hintsUsed++;
    await _save();
    notifyListeners();
    return true;
  }

  /// Returns the reward, or 0 if the mission cannot be claimed.
  Future<int> claimMission(String missionId) async {
    final mission = todaysMissions.where((m) => m.id == missionId).firstOrNull;
    if (mission == null ||
        !isMissionComplete(mission) ||
        isMissionClaimed(mission)) {
      return 0;
    }
    _daily.claimedMissions.add(mission.id);
    _data.points += mission.reward;
    await _save();
    notifyListeners();
    return mission.reward;
  }

  Future<void> markNotificationRead(String id) async {
    for (final notification in _data.notifications) {
      if (notification.id == id) notification.read = true;
    }
    await _save();
    notifyListeners();
  }

  Future<void> markAllNotificationsRead() async {
    for (final notification in _data.notifications) {
      notification.read = true;
    }
    await _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers

  void _count(GameEvent event) {
    final counters = _daily.counters;
    _setCounter(event, (counters[event.name] ?? 0) + 1);
  }

  void _setCounter(GameEvent event, int value) {
    final before = {
      for (final mission in todaysMissions)
        mission.id: isMissionComplete(mission),
    };
    _daily.counters[event.name] = value;
    for (final mission in todaysMissions) {
      if (before[mission.id] == false && isMissionComplete(mission)) {
        _notify(
          NotificationKind.mission,
          'Mission complete: ${mission.title}',
          'Open your missions to claim ${mission.reward} points.',
        );
      }
    }
  }

  void _touchStreak() {
    final today = _today;
    final last = _data.lastActiveDate;
    if (last == today) return;
    final now = _clock();
    final yesterday = _dateKey(DateTime(now.year, now.month, now.day - 1));
    _data.streak = last == yesterday ? _data.streak + 1 : 1;
    _data.bestStreak = math.max(_data.bestStreak, _data.streak);
    _data.lastActiveDate = today;
  }

  void _afterChange() {
    final earned = <String>[
      if (_data.totalScans >= 1) 'first-scan',
      if (_data.speciesFound.length >= 5) 'botanist-5',
      if (_data.speciesFound.length >= 15) 'botanist-15',
      if (_data.storyStars.length >= 3) 'adventurer',
      if (_data.storyStars.length >= storyLevels.length) 'earth-guardian',
      if (_data.puzzleStars.length >= 5) 'puzzle-pro',
      if (_data.memoryStars.length >= memoryLevels.length) 'sharp-memory',
      if (_data.plantPartsStars >= 3) 'plant-builder',
      if (_data.perfectQuizzes >= 1) 'quiz-whiz',
      if (_data.bestStreak >= 3) 'streak-3',
      if (_data.bestStreak >= 7) 'streak-7',
      if (_data.lessonsRead.length >= lessons.length) 'bookworm',
    ];
    for (final id in earned) {
      if (_data.badges.add(id)) {
        final badge = badgeById(id);
        _notify(
          NotificationKind.badge,
          'Badge earned: ${badge.title}',
          badge.description,
        );
      }
    }
  }

  void _notify(NotificationKind kind, String title, String body) {
    _data.notifications.insert(
      0,
      AppNotification(
        id: _newId(),
        kind: kind,
        title: title,
        body: body,
        createdAt: _clock(),
      ),
    );
    if (_data.notifications.length > _maxNotifications) {
      _data.notifications.removeRange(
        _maxNotifications,
        _data.notifications.length,
      );
    }
  }

  String _newId() => '${_clock().microsecondsSinceEpoch}-${_idCounter++}';
}
