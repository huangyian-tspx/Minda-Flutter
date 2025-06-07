import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;
  LocalStorageService(this._prefs);

  Future<void> saveData<T>(String key, T value) async {
    switch (T) {
      case String:
        await _prefs.setString(key, value as String);
        break;
      case int:
        await _prefs.setInt(key, value as int);
        break;
      case bool:
        await _prefs.setBool(key, value as bool);
        break;
      case double:
        await _prefs.setDouble(key, value as double);
        break;
      default:
        throw Exception("Unsupported type");
    }
  }

  T? readData<T>(String key) {
    return _prefs.get(key) as T?;
  }

  Future<bool> removeData(String key) async {
    return await _prefs.remove(key);
  }
} 