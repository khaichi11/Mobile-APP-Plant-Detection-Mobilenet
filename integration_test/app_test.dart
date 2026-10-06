import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pandai/app.dart';
import 'package:pandai/data/game_levels.dart';
import 'package:pandai/data/plant_catalog.dart';
import 'package:pandai/data/story_levels.dart';
import 'package:pandai/services/account_repository.dart';
import 'package:pandai/services/app_services.dart';
import 'package:pandai/services/classifier/plant_identifier.dart';
import 'package:pandai/services/leaderboard_repository.dart';
import 'package:pandai/services/local_database.dart';
import 'package:pandai/services/photo_store.dart';
import 'package:pandai/services/wiki_service.dart';
import 'package:pandai/state/app_state.dart';
import 'package:pandai/ui/collection/plant_detail_page.dart';
import 'package:pandai/ui/games/adventure/adventure_map_page.dart';
import 'package:pandai/ui/games/adventure/story_player_page.dart';
import 'package:pandai/ui/games/memory/memory_game_page.dart';
import 'package:pandai/ui/games/plant_parts/plant_parts_page.dart';
import 'package:pandai/ui/games/puzzle/puzzle_page.dart';
import 'package:pandai/ui/learn/learn_page.dart';
import 'package:pandai/ui/scanner/scan_result_page.dart';

/// Copies a bundled plant photo to a file, like a photo from the camera.
Future<String> photoFile(String plantId) async {
  final data = await rootBundle.load(plantById(plantId).photoAsset);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/scan_$plantId.jpg');
  await file.writeAsBytes(data.buffer.asUint8List());
  return file.path;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the on-device model recognises the guide plants', (
    tester,
  ) async {
    final identifier = await TfliteIdentifier.load();
    var top1 = 0;
    var top5 = 0;
    for (final plant in plantCatalog) {
      final result = await identifier.identify(await photoFile(plant.id));
      if (result.best.label == plant.scientificName) top1++;
      if (result.predictions.any((p) => p.label == plant.scientificName)) {
        top5++;
      }
    }
    await identifier.dispose();
    debugPrint(
      'Model accuracy on guide photos: top-1 $top1, top-5 $top5 '
      'of ${plantCatalog.length}',
    );
    // Reference run with the same preprocessing in Python: 26 and 38.
    expect(top1, greaterThanOrEqualTo(22));
    expect(top5, greaterThanOrEqualTo(34));
  });

  testWidgets('screenshots of the main screens', (tester) async {
    final database = MemoryDatabase();
    final state = AppState(
      database: database,
      accounts: AccountRepository(database),
      photos: PhotoStore(),
    );
    final services = AppServices(
      loadIdentifier: TfliteIdentifier.load,
      wiki: WikiService(),
      leaderboard: const DemoLeaderboardRepository(),
      cameras: availableCameras,
    );

    await state.completeOnboarding();
    await binding.convertFlutterSurfaceToImage();

    Future<void> settle([int frames = 12]) async {
      for (var i = 0; i < frames; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> shoot(String name) async {
      await settle();
      await binding.takeScreenshot(name);
    }

    // Welcome screen.
    await tester.pumpWidget(PandaiApp(state: state, services: services));
    await shoot('01_welcome');

    // A student with some progress.
    await state.register(
      name: 'Sari',
      email: 'sari@school.id',
      password: 'tumbuhan',
      grade: 4,
    );
    for (final id in [
      'hibiscus',
      'frangipani',
      'mimosa',
      'sunflower',
      'papaya',
      'canna',
    ]) {
      await state.recordScan(plantById(id).scientificName);
      await state.addToCollection(
        scientificName: plantById(id).scientificName,
        sourceImagePath: await photoFile(id),
        confidence: 0.82,
      );
    }
    for (final level in storyLevels.take(4)) {
      await state.completeStoryLevel(level.id, level == storyLevels[1] ? 2 : 3);
    }
    await state.completePuzzle(1, stars: 3, moves: 41);
    await state.completePuzzle(2, stars: 2, moves: 96);
    await state.completeMemory(1, 3);
    await state.markLessonRead('photosynthesis');
    await settle();

    BuildContext appContext() => tester.element(find.byType(Navigator).first);
    Future<void> open(Widget page) async {
      Navigator.of(
        appContext(),
      ).push(MaterialPageRoute<void>(builder: (_) => page));
      await settle();
    }

    Future<void> back() async {
      Navigator.of(appContext()).pop();
      await settle(8);
    }

    await shoot('02_home');

    Future<void> scrollHomeTo(String text) async {
      await tester.dragUntilVisible(
        find.text(text),
        find.byType(ListView).first,
        const Offset(0, -250),
      );
      await settle(4);
    }

    Future<void> tapTab(String label) async {
      await tester.tap(find.byKey(ValueKey('nav-$label')));
      await settle(6);
    }

    await scrollHomeTo('Today\'s missions');
    await shoot('03_home_games');

    await scrollHomeTo('Leaderboard');
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await shoot('04_home_leaderboard');

    await open(const LearnPage());
    await shoot('05_get_to_know_plants');
    await back();

    await open(ScanResultPage(imagePath: await photoFile('hibiscus')));
    await shoot('06_scan_result');
    await back();

    await tapTab('Collection');
    await shoot('07_collection');

    await open(const PlantDetailPage.catalog('mangrove'));
    await shoot('08_plant_detail');
    await back();

    await open(const AdventureMapPage());
    await shoot('09_adventure_map');
    await back();

    await open(StoryPlayerPage(level: storyLevels.first));
    await shoot('10_story');
    await back();

    await open(PuzzlePage(level: puzzleLevels.first));
    await shoot('11_puzzle');
    await back();

    await open(MemoryGamePage(level: memoryLevels[3]));
    await tester.tap(find.bySemanticsLabel('Hidden card').at(0));
    await settle(4);
    await shoot('12_memory');
    await back();

    await open(const PlantPartsPage());
    await tester.tap(find.text('Flower'));
    await settle(2);
    await tester.tap(find.bySemanticsLabel('Empty label spot').first);
    await shoot('13_build_a_plant');
    await back();

    await tapTab('Profile');
    await shoot('14_profile');

    await tapTab('Settings');
    await shoot('15_settings');
  });
}
