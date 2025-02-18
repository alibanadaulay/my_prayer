import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('prayer_widget_channel');

  static Future<void> updatePrayerWidget(Map<String, String> prayerData) async {
    try {
      await _channel.invokeMethod('updatePrayerWidget', prayerData);
    } catch (e) {
      Logger().e("Failed to update widget: $e");
    }
  }

  static Future<void> triggerUpdate() async {
    try {
      await _channel.invokeMethod('triggerUpdateWidget', '');
    } catch (e) {
      Logger().e("Failed to update widget: $e");
    }
  }
}
