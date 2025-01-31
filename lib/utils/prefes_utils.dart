import 'package:shared_preferences/shared_preferences.dart';

class PrefesUtils {
  static const String cityParam = "city";
  static const String isoCityParam = "isoCity";

  static SharedPreferencesAsync? _preferences;

  static Future<void> init() async {
    SharedPreferences.setPrefix("my_prayer_prefs");
    _preferences = SharedPreferencesAsync();
  }

  /// Save a String value
  static Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  /// Get a String value
  static Future<String> getString(String key) async {
    return await _preferences?.getString(key) ?? "";
  }

  /// Save an int value
  static Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  /// Get an int value
  static int? getInt(String key) {
    // return _preferences?.getInt(key);
  }

  /// Save a bool value
  static Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  /// Get a bool value
  static Future<bool> getBool(String key) async {
    return await _preferences?.getBool(key) ?? false;
  }

  /// Save a double value
  static Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  /// Get a double value
  static double? getDouble(String key) {
    // return _preferences?.getDouble(key);
  }

  /// Save a List<String>
  static Future<void> setStringList(String key, List<String> value) async {
    await _preferences?.setStringList(key, value);
  }

  /// Get a List<String>
  static List<String>? getStringList(String key) {
    // return _preferences?.getStringList(key);
  }

  /// Remove a specific key
  static Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  /// Clear all data
  static Future<void> clear() async {
    await _preferences?.clear();
  }
}
