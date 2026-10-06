import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('first launch shows onboarding, then sign in', (tester) async {
    final harness = TestHarness();
    await harness.pumpApp(tester);

    expect(find.text('Plants are all around you'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('WELCOME BACK!'), findsOneWidget);
    expect(harness.state.onboardingDone, isTrue);
  });

  testWidgets('a guest can start exploring right away', (tester) async {
    final harness = TestHarness();
    await harness.state.completeOnboarding();
    await harness.pumpApp(tester);

    await tester.tap(find.text('Explore as a guest'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Dewi');
    await tester.tap(find.text('Start exploring'));
    await tester.pumpAndSettle();

    expect(find.text('Dewi'), findsOneWidget);
    expect(harness.state.user!.isGuest, isTrue);
  });

  testWidgets('registration validates the form', (tester) async {
    final harness = TestHarness();
    await harness.state.completeOnboarding();
    await harness.pumpApp(tester);

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name.'), findsOneWidget);
    expect(find.text('Please enter a valid email address.'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Bima');
    await tester.enterText(fields.at(1), 'bima@school.id');
    await tester.enterText(fields.at(2), 'tumbuhan');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Bima'), findsOneWidget);
  });

  testWidgets('wrong passwords show an error', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.state.signOut();
    await harness.pumpApp(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'sari@school.id');
    await tester.enterText(fields.at(1), 'wrong-password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('The email or password is not correct.'), findsOneWidget);

    await tester.enterText(fields.at(1), 'secret1');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Sari'), findsOneWidget);
  });
}
