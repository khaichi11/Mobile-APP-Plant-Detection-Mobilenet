import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('home keeps the original layout and opens every game', (
    tester,
  ) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Hello!'), findsOneWidget);
    expect(find.text('Sari'), findsOneWidget);
    expect(find.text('Get to Know Plants!'), findsOneWidget);
    expect(find.text('Part 1: Growing carrots'), findsOneWidget);

    for (final (button, title) in [
      ('PETA (Plant Adventure)', 'PETA: Plant Adventure'),
      ('Plant Puzzle', 'Choose a Puzzle'),
      ('Memory Match', 'Memory Match'),
      ('Build a Plant', 'Build a Plant'),
      ('Daily Quiz', 'Daily quiz'),
    ]) {
      await tester.dragUntilVisible(
        find.text(button),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets, reason: button);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.scrollUntilVisible(
      find.text('Swipe down to see the leaderboard'),
      300,
    );
    await tester.scrollUntilVisible(find.text('Ayu'), 300);
    expect(find.text('Ayu'), findsOneWidget);
  });

  testWidgets('the other tabs open without errors', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpApp(tester);

    await tapNav(tester, 'Collection');
    expect(find.text('Plant Collection'), findsOneWidget);
    expect(find.text('Your collection is empty'), findsOneWidget);
    await tester.tap(find.text('Plant guide'));
    await tester.pumpAndSettle();
    expect(find.text('Sunflower'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'kelapa');
    await tester.pumpAndSettle();
    expect(find.text('Coconut palm'), findsOneWidget);
    expect(find.text('Sunflower'), findsNothing);
    await tester.tap(find.text('Coconut palm'));
    await tester.pumpAndSettle();
    expect(find.text('Cocos nucifera'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapNav(tester, 'Profile');
    expect(find.text('Grade 4 · sari@school.id'), findsOneWidget);
    expect(
      find.text('Climb the leaderboard by finishing the games!'),
      findsOneWidget,
    );

    await tapNav(tester, 'Settings');
    await tester.tap(find.text('About Pandai'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Made by Team Terang Bulan'),
      200,
    );
    expect(find.text('Made by Team Terang Bulan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Credits and licenses'));
    await tester.pumpAndSettle();
    expect(find.text('Plant photos'), findsOneWidget);
  });

  testWidgets('notifications can be read', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpApp(tester);

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Pandai, Sari!'), findsOneWidget);
    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();
    expect(harness.state.unreadNotifications, 0);
  });

  testWidgets('signing out returns to the welcome page', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpApp(tester);

    await tapNav(tester, 'Settings');
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('WELCOME BACK!'), findsOneWidget);
    expect(harness.state.isSignedIn, isFalse);
  });

  testWidgets('the camera button explains when no camera is available', (
    tester,
  ) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpApp(tester);

    await tester.tap(find.byTooltip('Scan a plant'));
    await tester.pumpAndSettle();
    expect(
      find.text('The camera is not available on this device.'),
      findsOneWidget,
    );
    expect(find.text('Pick a photo'), findsOneWidget);
  });
}
