import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/data/game_levels.dart';
import 'package:pandai/data/story_levels.dart';
import 'package:pandai/games/memory_game.dart';
import 'package:pandai/games/quiz_builder.dart';
import 'package:pandai/models/story.dart';
import 'package:pandai/ui/games/adventure/adventure_map_page.dart';
import 'package:pandai/ui/games/adventure/story_player_page.dart';
import 'package:pandai/ui/games/memory/memory_game_page.dart';
import 'package:pandai/ui/games/plant_parts/plant_parts_page.dart';
import 'package:pandai/ui/games/puzzle/puzzle_levels_page.dart';
import 'package:pandai/ui/games/puzzle/puzzle_page.dart';
import 'package:pandai/ui/games/quiz/daily_quiz_page.dart';

import '../support/test_app.dart';

/// Taps the right answer of the question on screen.
Future<void> answer(WidgetTester tester, QuizQuestion question) async {
  final option = find.text(question.options[question.answer]);
  await tester.ensureVisible(option);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a perfect story level gives 3 stars and unlocks the next', (
    tester,
  ) async {
    final harness = TestHarness();
    await harness.signIn();
    final level = storyLevels.first;
    await harness.pumpPage(tester, StoryPlayerPage(level: level));

    for (final step in level.steps) {
      if (step is QuestionStep) await answer(tester, step.question);
      final last = identical(step, level.steps.last);
      await tapButton(tester, last ? 'Finish level' : 'Continue');
    }

    expect(find.text('Perfect!'), findsOneWidget);
    expect(harness.state.storyStars(level.id), 3);
    expect(harness.state.data.points, 30);
    expect(harness.state.isStoryUnlocked(storyLevels[1].id), isTrue);

    await tapButton(tester, 'Next: ${storyLevels[1].title}');
    expect(find.text(storyLevels[1].title), findsOneWidget);
  });

  testWidgets('wrong answers cost stars but can be retried', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    final level = storyLevels.first;
    await harness.pumpPage(tester, StoryPlayerPage(level: level));

    var mistakes = 0;
    for (final step in level.steps) {
      if (step is QuestionStep) {
        final q = step.question;
        final wrong = q.options[(q.answer + 1) % q.options.length];
        await tester.tap(find.text(wrong));
        await tester.pumpAndSettle();
        expect(find.textContaining('Not quite'), findsOneWidget);
        mistakes++;
        await answer(tester, q);
      }
      final last = identical(step, level.steps.last);
      await tapButton(tester, last ? 'Finish level' : 'Continue');
    }
    expect(mistakes, greaterThan(1));
    expect(harness.state.storyStars(level.id), 1);
  });

  testWidgets('locked map levels cannot be opened', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpPage(tester, const AdventureMapPage());
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel(RegExp('Level 2: .*locked')));
    await tester.pumpAndSettle();
    expect(
      find.text('Finish the previous level to unlock this one.'),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel(RegExp('^Level 1: ')));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('puzzle tiles only move next to the gap', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpPage(
      tester,
      PuzzlePage(level: puzzleLevels.first, random: Random(1)),
    );
    expect(find.text('0 moves'), findsOneWidget);

    // Tap every tile once; only tiles in line with the gap move.
    var moved = false;
    for (var id = 1; id <= 8 && !moved; id++) {
      await tester.tap(find.bySemanticsLabel('Tile $id'));
      await tester.pump(const Duration(milliseconds: 200));
      moved = find.text('0 moves').evaluate().isEmpty;
    }
    expect(moved, isTrue);
  });

  testWidgets('hints are limited to three a day', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpPage(
      tester,
      PuzzlePage(level: puzzleLevels.first, random: Random(2)),
    );

    for (var i = 3; i > 0; i--) {
      expect(find.text('Hint ($i)'), findsOneWidget);
      await tester.tap(find.text('Hint ($i)'));
      await tester.pump(const Duration(seconds: 4));
    }
    expect(find.text('Hint (0)'), findsOneWidget);
    expect(harness.state.hintsLeft, 0);
  });

  testWidgets('puzzle levels start locked except the first', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpPage(tester, const PuzzleLevelsPage());
    await tester.tap(find.text('Level 2'));
    await tester.pump();
    expect(find.text('Solve puzzle 1 to unlock this one.'), findsOneWidget);
  });

  testWidgets('finding every memory pair completes the level', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    final level = memoryLevels.first;
    final game = MemoryGame(level, Random(5));
    await harness.pumpPage(
      tester,
      MemoryGamePage(level: level, random: Random(5)),
    );

    final cards = find.bySemanticsLabel('Hidden card');
    final positions = [
      for (var i = 0; i < game.cards.length; i++) tester.getCenter(cards.at(i)),
    ];
    for (final id in level.plantIds) {
      final pair = [
        for (var i = 0; i < game.cards.length; i++)
          if (game.cards[i].plantId == id) i,
      ];
      await tester.tapAt(positions[pair[0]]);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tapAt(positions[pair[1]]);
      await tester.pump(const Duration(milliseconds: 300));
    }
    // The result sheet opens after a short pause.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('All pairs found!'), findsOneWidget);
    expect(harness.state.data.memoryStars[1], 3);
    expect(harness.state.isMemoryUnlocked(2), isTrue);
  });

  testWidgets('build a plant can be played by tapping', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpPage(tester, const PlantPartsPage());

    for (final part in PlantPart.values) {
      await tester.tap(find.text(part.label));
      await tester.pump();
      final spot = find.bySemanticsLabel('Empty label spot');
      // Spots are listed in enum order; the first empty one is this part's.
      await tester.tap(spot.first);
      await tester.pump(const Duration(milliseconds: 700));
    }
    await tester.pumpAndSettle();
    expect(find.textContaining('What does the'), findsOneWidget);

    for (var i = 0; i < PlantPart.values.length; i++) {
      final prompt =
          tester.widget<Text>(find.textContaining('What does the')).data!;
      final part = PlantPart.values.firstWhere(
        (p) => prompt.contains(p.label.toLowerCase()),
      );
      await tester.tap(find.text(part.job));
      await tester.pumpAndSettle();
      await tapButton(
        tester,
        i == PlantPart.values.length - 1 ? 'Finish' : 'Continue',
      );
    }
    expect(find.text('You built a plant!'), findsOneWidget);
    expect(harness.state.data.plantPartsStars, 3);
  });

  testWidgets('the daily quiz gives points once', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    final quiz = buildDailyQuiz(harness.state.dayIndex);
    await harness.pumpPage(tester, const DailyQuizPage());

    for (var i = 0; i < quiz.length; i++) {
      await answer(tester, quiz[i].question);
      await tapButton(
        tester,
        i == quiz.length - 1 ? 'See results' : 'Next question',
      );
    }
    expect(find.text('5 of 5 correct'), findsOneWidget);
    expect(harness.state.dailyQuizScore, 5);
    expect(harness.state.data.points, 25);
  });
}
