import 'package:shared_preferences/shared_preferences.dart';

class PrefesUtils {
  static const String cityParam = "city";
  static const String isoCityParam = "isoCity";
  static const String midnightAlarmId = "midnightAlarmId";
  static const String arabicDate = "arabicDate";
  static const String prayerTimes = "prayerTimes";
  static const String currentPrayer = "currentPrayer";
  static const String isWorkManagerThreeHour = "isWorkManagerThreeHour";

  static PrefesUtils? _instance;
  static SharedPreferencesAsync? _preferences;

  PrefesUtils._internal();

  static Future<PrefesUtils> getInstance() async {
    if (_instance == null) {
      _instance = PrefesUtils._internal();
      SharedPreferences.setPrefix("my_prayer_prefs");
      _preferences = SharedPreferencesAsync();
    }
    return _instance!;
  }

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
  static Future<int> getInt(String key) async {
    return await _preferences?.getInt(key) ?? 0;
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
  static Future<double?> getDouble(String key) async {
    return await _preferences?.getDouble(key) ?? 0.toDouble();
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
