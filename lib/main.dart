import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/account_repository.dart';
import 'services/app_services.dart';
import 'services/classifier/plant_identifier.dart';
import 'services/leaderboard_repository.dart';
import 'services/local_database.dart';
import 'services/photo_store.dart';
import 'services/wiki_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final database = await SharedPreferencesDatabase.open();
  final state = AppState(
    database: database,
    accounts: AccountRepository(database),
    photos: PhotoStore(),
  )..restoreSession();

  final services = AppServices(
    loadIdentifier: TfliteIdentifier.load,
    wiki: WikiService(),
    leaderboard: const DemoLeaderboardRepository(),
    cameras: availableCameras,
  );

  runApp(PandaiApp(state: state, services: services));
}
