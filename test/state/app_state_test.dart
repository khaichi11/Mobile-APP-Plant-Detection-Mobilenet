import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/data/missions.dart';
import 'package:pandai/data/story_levels.dart';
import 'package:pandai/models/app_notification.dart';
import 'package:pandai/models/mission.dart';
import 'package:pandai/services/account_repository.dart';
import 'package:pandai/services/local_database.dart';
import 'package:pandai/state/app_state.dart';
import 'package:pandai/state/game_rules.dart';

import '../support/fakes.dart';

void main() {
  late MemoryDatabase db;
  late TestClock clock;
  late FakePhotoStore photos;

  setUp(() {
    db = MemoryDatabase();
    clock = TestClock(DateTime(2026, 3, 10, 9));
    photos = FakePhotoStore();
  });

  Future<AppState> signedIn() async {
    final state = buildAppState(database: db, clock: clock, photos: photos);
    await state.register(
      name: 'Sari',
      email: 'sari@school.id',
      password: 'secret1',
      grade: 4,
    );
    return state;
  }

  test('registering signs in and greets the player', () async {
    final state = await signedIn();
    expect(state.isSignedIn, isTrue);
    expect(state.user!.name, 'Sari');
    expect(state.data.notifications.single.kind, NotificationKind.info);
  });

  test('progress is saved and restored for the same account', () async {
    final state = await signedIn();
    await state.completeStoryLevel(storyLevels.first.id, 3);

    final restored = buildAppState(database: db, clock: clock, photos: photos)
      ..restoreSession();
    expect(restored.user!.email, 'sari@school.id');
    expect(restored.storyStars(storyLevels.first.id), 3);
    expect(restored.data.points, 30);
  });

  test('story levels unlock in order and replays do not farm points', () async {
    final state = await signedIn();
    final first = storyLevels[0].id;
    final second = storyLevels[1].id;
    expect(state.isStoryUnlocked(first), isTrue);
    expect(state.isStoryUnlocked(second), isFalse);

    expect(await state.completeStoryLevel(first, 2), 20);
    expect(state.isStoryUnlocked(second), isTrue);
    expect(state.currentStoryIndex, 1);
    expect(await state.completeStoryLevel(first, 2), 0);
    expect(await state.completeStoryLevel(first, 1), 0);
    expect(state.storyStars(first), 2);
    expect(await state.completeStoryLevel(first, 3), 10);
    expect(state.data.points, 30);
  });

  test(
    'a new species earns points once; repeats only replace the photo',
    () async {
      final state = await signedIn();
      final first = await state.addToCollection(
        scientificName: 'Helianthus annuus',
        sourceImagePath: '/tmp/a.jpg',
        confidence: 0.8,
      );
      expect(first.isNewSpecies, isTrue);
      expect(state.data.points, GameRules.newSpeciesPoints);

      final again = await state.addToCollection(
        scientificName: 'Helianthus annuus',
        sourceImagePath: '/tmp/b.jpg',
        confidence: 0.9,
      );
      expect(again.isNewSpecies, isFalse);
      expect(state.data.collection, hasLength(1));
      expect(state.data.collection.single.imagePath, photos.saved.last);
      expect(photos.deleted, [photos.saved.first]);
      expect(state.data.points, GameRules.newSpeciesPoints);

      await state.removeFromCollection(state.data.collection.single.id);
      expect(state.data.collection, isEmpty);
      expect(state.hasSpecies('Helianthus annuus'), isFalse);
    },
  );

  test('scan missions count different species only', () async {
    final state = await signedIn();
    // Find a day whose outdoor mission is "scan 3 plants".
    while (state.todaysMissions.first.id != 'scan-3') {
      clock.advance(const Duration(days: 1));
    }
    final mission = state.todaysMissions.first;
    await state.recordScan('Helianthus annuus');
    await state.recordScan('Helianthus annuus');
    expect(state.missionProgress(mission), 1);
    await state.recordScan('Carica papaya');
    await state.recordScan('Mimosa pudica');
    expect(state.isMissionComplete(mission), isTrue);
    expect(state.data.totalScans, 4);

    expect(await state.claimMission(mission.id), mission.reward);
    expect(await state.claimMission(mission.id), 0);
    expect(state.isMissionClaimed(mission), isTrue);
  });

  test('missions reset the next day', () async {
    final state = await signedIn();
    final mission = state.todaysMissions.first;
    await state.recordScan('Helianthus annuus');
    await state.addToCollection(
      scientificName: 'Helianthus annuus',
      sourceImagePath: '/tmp/a.jpg',
      confidence: 0.8,
    );
    expect(state.missionProgress(mission), greaterThan(0));
    clock.advance(const Duration(days: 1));
    for (final m in state.todaysMissions) {
      expect(state.missionProgress(m), 0);
      expect(state.isMissionClaimed(m), isFalse);
    }
  });

  test('incomplete missions cannot be claimed', () async {
    final state = await signedIn();
    expect(await state.claimMission(state.todaysMissions.last.id), 0);
    expect(await state.claimMission('not-a-mission'), 0);
  });

  test('the daily quiz gives points only once per day', () async {
    final state = await signedIn();
    expect(await state.completeDailyQuiz(5, 5), 25);
    expect(state.dailyQuizScore, 5);
    expect(state.data.badges, contains('quiz-whiz'));
    expect(await state.completeDailyQuiz(5, 5), 0);
    clock.advance(const Duration(days: 1));
    expect(state.dailyQuizScore, isNull);
    expect(await state.completeDailyQuiz(3, 5), 15);
  });

  test('three hints a day', () async {
    final state = await signedIn();
    expect(state.hintsLeft, 3);
    expect(await state.useHint(), isTrue);
    expect(await state.useHint(), isTrue);
    expect(await state.useHint(), isTrue);
    expect(await state.useHint(), isFalse);
    expect(state.hintsLeft, 0);
    clock.advance(const Duration(days: 1));
    expect(state.hintsLeft, 3);
  });

  test('streaks grow on consecutive days and reset after a gap', () async {
    final state = await signedIn();
    await state.recordScan('Helianthus annuus');
    expect(state.data.streak, 1);
    clock.advance(const Duration(days: 1));
    await state.recordScan('Helianthus annuus');
    clock.advance(const Duration(days: 1));
    await state.markLessonRead('photosynthesis');
    expect(state.data.streak, 3);
    expect(state.data.badges, contains('streak-3'));
    clock.advance(const Duration(days: 3));
    await state.recordScan('Helianthus annuus');
    expect(state.data.streak, 1);
    expect(state.data.bestStreak, 3);
  });

  test('badges are awarded once with a notification', () async {
    final state = await signedIn();
    await state.recordScan('Helianthus annuus');
    await state.recordScan('Carica papaya');
    final badgeNotes =
        state.data.notifications
            .where((n) => n.kind == NotificationKind.badge)
            .toList();
    expect(state.data.badges, contains('first-scan'));
    expect(badgeNotes, hasLength(1));
  });

  test('completing a mission sends a notification', () async {
    final state = await signedIn();
    final storyMission = allMissions.firstWhere(
      (m) => m.event == GameEvent.storyLevel,
    );
    while (!state.todaysMissions.contains(storyMission)) {
      clock.advance(const Duration(days: 1));
    }
    await state.completeStoryLevel(storyLevels.first.id, 3);
    expect(
      state.data.notifications.where((n) => n.kind == NotificationKind.mission),
      hasLength(1),
    );
  });

  test('notifications can be marked as read', () async {
    final state = await signedIn();
    await state.completeStoryLevel(storyLevels.first.id, 3);
    expect(state.unreadNotifications, greaterThan(1));
    await state.markNotificationRead(state.data.notifications.first.id);
    expect(state.data.notifications.first.read, isTrue);
    await state.markAllNotificationsRead();
    expect(state.unreadNotifications, 0);
  });

  test('puzzles and memory levels unlock one by one', () async {
    final state = await signedIn();
    expect(state.isPuzzleUnlocked(1), isTrue);
    expect(state.isPuzzleUnlocked(2), isFalse);
    await state.completePuzzle(1, stars: 3, moves: 40);
    await state.completePuzzle(1, stars: 2, moves: 30);
    expect(state.isPuzzleUnlocked(2), isTrue);
    expect(state.data.puzzleStars[1], 3);
    expect(state.data.puzzleBestMoves[1], 30);

    expect(state.isMemoryUnlocked(2), isFalse);
    expect(await state.completeMemory(1, 2), 20);
    expect(state.isMemoryUnlocked(2), isTrue);
  });

  test('build a plant keeps the best stars', () async {
    final state = await signedIn();
    expect(await state.completePlantParts(2), 20);
    expect(await state.completePlantParts(3), 10);
    expect(await state.completePlantParts(1), 0);
    expect(state.data.badges, contains('plant-builder'));
  });

  test('reset clears progress and deletes photos', () async {
    final state = await signedIn();
    await state.addToCollection(
      scientificName: 'Helianthus annuus',
      sourceImagePath: '/tmp/a.jpg',
      confidence: 0.8,
    );
    await state.resetProgress();
    expect(state.data.points, 0);
    expect(state.data.collection, isEmpty);
    expect(photos.deleted, hasLength(1));
    expect(state.isSignedIn, isTrue);
  });

  test('guests lose their data on sign out; accounts keep it', () async {
    final guest = buildAppState(database: db, clock: clock, photos: photos);
    await guest.continueAsGuest(name: 'Explorer', grade: 3);
    final guestId = guest.user!.id;
    await guest.completeStoryLevel(storyLevels.first.id, 3);
    await guest.signOut();
    expect(guest.isSignedIn, isFalse);
    expect(db.read('player.v1.$guestId'), isNull);

    final state = await signedIn();
    await state.completeStoryLevel(storyLevels.first.id, 3);
    await state.signOut();
    await state.signIn(email: 'SARI@school.id ', password: 'secret1');
    expect(state.data.points, 30);
  });

  test('profile updates are validated and saved', () async {
    final state = await signedIn();
    await state.updateProfile(name: ' Sari Dewi ', grade: 5);
    expect(state.user!.name, 'Sari Dewi');
    expect(state.user!.grade, 5);
    await expectLater(
      state.updateProfile(name: '  '),
      throwsA(isA<AuthException>()),
    );

    await state.updateProfile(avatarSourcePath: '/tmp/me.jpg');
    final first = state.user!.avatarPath;
    await state.updateProfile(avatarSourcePath: '/tmp/me2.jpg');
    expect(photos.deleted, contains(first));

    final restored = buildAppState(database: db, clock: clock, photos: photos)
      ..restoreSession();
    expect(restored.user!.name, 'Sari Dewi');
  });

  test('onboarding is remembered', () async {
    final state = buildAppState(database: db, clock: clock, photos: photos);
    expect(state.onboardingDone, isFalse);
    await state.completeOnboarding();
    expect(buildAppState(database: db).onboardingDone, isTrue);
  });
}
