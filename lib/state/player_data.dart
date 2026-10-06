import '../models/app_notification.dart';
import '../models/collection_entry.dart';

/// Counters that reset every day: mission progress, claimed missions, used
/// hints and the daily quiz.
class DailyState {
  DailyState({
    required this.date,
    Map<String, int>? counters,
    Set<String>? claimedMissions,
    Set<String>? speciesScanned,
    this.hintsUsed = 0,
    this.quizScore,
  }) : counters = counters ?? {},
       claimedMissions = claimedMissions ?? {},
       speciesScanned = speciesScanned ?? {};

  factory DailyState.fromJson(Map<String, dynamic> json) {
    return DailyState(
      date: json['date'] as String,
      counters: (json['counters'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, value as int),
      ),
      claimedMissions: {
        ...(json['claimedMissions'] as List<dynamic>? ?? []).cast<String>(),
      },
      speciesScanned: {
        ...(json['speciesScanned'] as List<dynamic>? ?? []).cast<String>(),
      },
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      quizScore: json['quizScore'] as int?,
    );
  }

  /// Day in `yyyy-mm-dd` format.
  final String date;
  final Map<String, int> counters;
  final Set<String> claimedMissions;

  /// Different species identified today. Scanning the same plant again does
  /// not count twice.
  final Set<String> speciesScanned;
  int hintsUsed;

  /// Correct answers in today's quiz, or null if it was not played yet.
  int? quizScore;

  Map<String, dynamic> toJson() => {
    'date': date,
    'counters': counters,
    'claimedMissions': claimedMissions.toList(),
    'speciesScanned': speciesScanned.toList(),
    'hintsUsed': hintsUsed,
    'quizScore': quizScore,
  };
}

/// Everything Pandai remembers about one player. Stored as JSON in the local
/// database.
class PlayerData {
  PlayerData({
    this.points = 0,
    Map<String, int>? storyStars,
    Map<int, int>? puzzleStars,
    Map<int, int>? puzzleBestMoves,
    Map<int, int>? memoryStars,
    this.plantPartsStars = 0,
    List<CollectionEntry>? collection,
    List<AppNotification>? notifications,
    Set<String>? badges,
    Set<String>? lessonsRead,
    this.totalScans = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.lastActiveDate,
    this.perfectQuizzes = 0,
    this.daily,
  }) : storyStars = storyStars ?? {},
       puzzleStars = puzzleStars ?? {},
       puzzleBestMoves = puzzleBestMoves ?? {},
       memoryStars = memoryStars ?? {},
       collection = collection ?? [],
       notifications = notifications ?? [],
       badges = badges ?? {},
       lessonsRead = lessonsRead ?? {};

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    Map<int, int> intMap(String key) =>
        (json[key] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(int.parse(k), v as int),
        );

    return PlayerData(
      points: json['points'] as int? ?? 0,
      storyStars: (json['storyStars'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(k, v as int),
      ),
      puzzleStars: intMap('puzzleStars'),
      puzzleBestMoves: intMap('puzzleBestMoves'),
      memoryStars: intMap('memoryStars'),
      plantPartsStars: json['plantPartsStars'] as int? ?? 0,
      collection:
          (json['collection'] as List<dynamic>? ?? [])
              .map((e) => CollectionEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      notifications:
          (json['notifications'] as List<dynamic>? ?? [])
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList(),
      badges: {...(json['badges'] as List<dynamic>? ?? []).cast<String>()},
      lessonsRead: {
        ...(json['lessonsRead'] as List<dynamic>? ?? []).cast<String>(),
      },
      totalScans: json['totalScans'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
      perfectQuizzes: json['perfectQuizzes'] as int? ?? 0,
      daily:
          json['daily'] == null
              ? null
              : DailyState.fromJson(json['daily'] as Map<String, dynamic>),
    );
  }

  int points;

  /// Best stars per story level id.
  final Map<String, int> storyStars;

  /// Best stars per puzzle level number.
  final Map<int, int> puzzleStars;
  final Map<int, int> puzzleBestMoves;

  /// Best stars per memory level number.
  final Map<int, int> memoryStars;
  int plantPartsStars;

  /// Newest first.
  final List<CollectionEntry> collection;

  /// Newest first.
  final List<AppNotification> notifications;
  final Set<String> badges;
  final Set<String> lessonsRead;
  int totalScans;
  int streak;
  int bestStreak;
  String? lastActiveDate;
  int perfectQuizzes;
  DailyState? daily;

  Set<String> get speciesFound => {
    for (final entry in collection) entry.scientificName,
  };

  Map<String, dynamic> toJson() {
    Map<String, int> stringKeys(Map<int, int> map) =>
        map.map((k, v) => MapEntry('$k', v));

    return {
      'points': points,
      'storyStars': storyStars,
      'puzzleStars': stringKeys(puzzleStars),
      'puzzleBestMoves': stringKeys(puzzleBestMoves),
      'memoryStars': stringKeys(memoryStars),
      'plantPartsStars': plantPartsStars,
      'collection': collection.map((e) => e.toJson()).toList(),
      'notifications': notifications.map((e) => e.toJson()).toList(),
      'badges': badges.toList(),
      'lessonsRead': lessonsRead.toList(),
      'totalScans': totalScans,
      'streak': streak,
      'bestStreak': bestStreak,
      'lastActiveDate': lastActiveDate,
      'perfectQuizzes': perfectQuizzes,
      'daily': daily?.toJson(),
    };
  }
}
