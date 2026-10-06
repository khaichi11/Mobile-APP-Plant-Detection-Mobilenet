import 'package:camera/camera.dart';

import 'classifier/plant_identifier.dart';
import 'leaderboard_repository.dart';
import 'wiki_service.dart';

/// Services that screens use, gathered so tests can swap them for fakes.
class AppServices {
  AppServices({
    required Future<PlantIdentifier> Function() loadIdentifier,
    required this.wiki,
    required this.leaderboard,
    required this.cameras,
  }) : _loadIdentifier = loadIdentifier;

  final Future<PlantIdentifier> Function() _loadIdentifier;
  final WikiService wiki;
  final LeaderboardRepository leaderboard;

  /// Lists the device cameras. Throws when there is no camera support.
  final Future<List<CameraDescription>> Function() cameras;

  Future<PlantIdentifier>? _identifier;

  /// Loads the model once and reuses it. A failed load is retried next time.
  Future<PlantIdentifier> identifier() {
    final existing = _identifier;
    if (existing != null) return existing;
    final loading = _loadIdentifier();
    _identifier = loading;
    loading.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(_identifier, loading)) _identifier = null;
      },
    );
    return loading;
  }
}
