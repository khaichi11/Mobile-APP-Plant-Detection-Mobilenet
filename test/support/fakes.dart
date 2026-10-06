import 'package:pandai/services/account_repository.dart';
import 'package:pandai/services/local_database.dart';
import 'package:pandai/services/photo_store.dart';
import 'package:pandai/state/app_state.dart';

/// Stores nothing on disk; returns predictable paths.
class FakePhotoStore extends PhotoStore {
  final saved = <String>[];
  final deleted = <String>[];
  var _count = 0;

  @override
  Future<String> save(String sourcePath, {required String folder}) async {
    final path = '/fake/$folder/${_count++}.jpg';
    saved.add(path);
    return path;
  }

  @override
  Future<void> delete(String path) async => deleted.add(path);
}

/// A clock that tests can move forward.
class TestClock {
  TestClock(this.now);
  DateTime now;
  DateTime call() => now;
  void advance(Duration duration) => now = now.add(duration);
}

AppState buildAppState({
  MemoryDatabase? database,
  TestClock? clock,
  FakePhotoStore? photos,
}) {
  final db = database ?? MemoryDatabase();
  final time = clock ?? TestClock(DateTime(2026, 3, 10, 9));
  return AppState(
    database: db,
    accounts: AccountRepository(db, clock: time.call),
    photos: photos ?? FakePhotoStore(),
    clock: time.call,
  );
}
