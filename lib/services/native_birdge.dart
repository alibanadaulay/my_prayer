import 'package:flutter/services.dart';

class NativeBirdge {
  static const MethodChannel _channel = MethodChannel('prayer_widget_channel');

  static Future<void> updatePrayerWidget(Map<String, String> prayerData) async {
    try {
      await _channel.invokeMethod('updatePrayerWidget', prayerData);
    } catch (e) {
      print("Failed to update widget: $e");
    }
  }
}
