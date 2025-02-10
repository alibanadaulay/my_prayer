import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class NativeBirdge {
  static const MethodChannel _channel = MethodChannel('prayer_widget_channel');

  static Future<void> updatePrayerWidget(Map<String, String> prayerData) async {
    try {
      await _channel.invokeMethod('updatePrayerWidget', prayerData);
    } catch (e) {
      Logger().e("Failed to update widget: $e");
    }
  }

  static Future<void> logCurrentDate() async {
    try {
      await _channel.invokeMethod('logCurrentDate', "");
    } catch (e) {
      Logger().e("Failed to update widget: $e");
    }
  }
}
