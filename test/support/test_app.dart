import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pandai/app.dart';
import 'package:pandai/services/app_services.dart';
import 'package:pandai/services/classifier/classifier_math.dart';
import 'package:pandai/services/classifier/plant_identifier.dart';
import 'package:pandai/services/leaderboard_repository.dart';
import 'package:pandai/services/local_database.dart';
import 'package:pandai/services/wiki_service.dart';
import 'package:pandai/state/app_state.dart';

import 'fakes.dart';

class FakeIdentifier implements PlantIdentifier {
  FakeIdentifier(this.predictions);

  List<Prediction> predictions;
  int calls = 0;

  @override
  Future<IdentificationResult> identify(String imagePath) async {
    calls++;
    return IdentificationResult(predictions);
  }

  @override
  Future<void> dispose() async {}
}

class TestHarness {
  TestHarness({List<Prediction>? predictions})
    : database = MemoryDatabase(),
      clock = TestClock(DateTime(2026, 3, 10, 9)),
      photos = FakePhotoStore(),
      identifier = FakeIdentifier(
        predictions ?? const [Prediction('Helianthus annuus', 0.91)],
      ) {
    state = buildAppState(database: database, clock: clock, photos: photos);
    services = AppServices(
      loadIdentifier: () async => identifier,
      wiki: WikiService(
        client: MockClient((_) async => http.Response('{}', 404)),
      ),
      leaderboard: const DemoLeaderboardRepository(),
      cameras: () async => throw Exception('No camera in tests'),
    );
  }

  final MemoryDatabase database;
  final TestClock clock;
  final FakePhotoStore photos;
  final FakeIdentifier identifier;
  late final AppState state;
  late final AppServices services;

  Future<void> signIn() async {
    await state.completeOnboarding();
    await state.register(
      name: 'Sari',
      email: 'sari@school.id',
      password: 'secret1',
      grade: 4,
    );
  }

  /// Pumps the whole app at phone size with animations reduced.
  Future<void> pumpApp(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(PandaiApp(state: state, services: services));
    await tester.pump();
  }

  /// Pumps a single page inside the app's providers and theme.
  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      PandaiApp(state: state, services: services, home: page),
    );
    await tester.pump();
  }
}

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

/// Taps a tab in the bottom bar by its label.
Future<void> tapNav(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(ValueKey('nav-$label')));
  await tester.pumpAndSettle();
}
