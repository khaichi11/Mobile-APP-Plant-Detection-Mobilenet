import 'package:shared_preferences/shared_preferences.dart';

/// Minimal key-value database used for all app data. Pandai keeps everything
/// on the device, so no server or API key is needed. A cloud backend can be
/// added later by implementing this interface.
abstract interface class LocalDatabase {
  String? read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SharedPreferencesDatabase implements LocalDatabase {
  SharedPreferencesDatabase._(this._prefs);

  static Future<SharedPreferencesDatabase> open() async {
    return SharedPreferencesDatabase._(await SharedPreferences.getInstance());
  }

  final SharedPreferences _prefs;

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> delete(String key) => _prefs.remove(key);
}

/// In-memory database for tests and previews.
class MemoryDatabase implements LocalDatabase {
  MemoryDatabase([Map<String, String>? initial]) : data = {...?initial};

  final Map<String, String> data;

  @override
  String? read(String key) => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);
}
