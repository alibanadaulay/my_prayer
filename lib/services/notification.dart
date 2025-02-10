import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logger/logger.dart';
import 'package:my_prayer/model/prayre_notification_model.dart';
import 'package:my_prayer/utils/calender_utils.dart';
import 'package:my_prayer/utils/prefes_utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse details) {
  unawaited(NotificationService.updateDate(details.payload));
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveBackgroundNotificationResponse(
      NotificationResponse details) async {}

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        updateDate(details.payload);
      },
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );
  }

  static Future<void> updateDate(String? payload) async {
    if (payload != null) {
      PrefesUtils.getInstance();
      List<String> part = payload.split('.');
      PrefesUtils.setString(PrefesUtils.currentPrayer, part[0]);
      String hijriDate = "${await CalenderUtils.getHijriDate(part[1])}H";
      PrefesUtils.setString(PrefesUtils.arabicDate, hijriDate);
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotification() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  static Future<void> cancelAllPendingNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> cancelNotificationById(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  @pragma('vm:entry-point')
  static Future<void> scheduleAlarm(
      PrayreNotificationModel prayerNotificationModel) async {
    tz.initializeTimeZones();

    if (DateTime.now().isAfter(prayerNotificationModel.dateTime)) {
      return;
    }
    List<PendingNotificationRequest> pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (var notification in pendingNotifications) {
      if (notification.id == prayerNotificationModel.id) {
        return;
      }
    }
    Logger().i(
        "${prayerNotificationModel.name}, sound : ${prayerNotificationModel.isSound}");

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'prayer_notification_id', 'Alarm Notifications',
            channelDescription: 'Channel for alarm notifications',
            importance: Importance.max,
            priority: Priority.high,
            autoCancel: true,
            enableVibration: prayerNotificationModel.isSound,
            playSound: prayerNotificationModel.isSound,
            sound: RawResourceAndroidNotificationSound(
                prayerNotificationModel.soundName),
            icon: "@drawable/app_icon");

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    var time = tz.TZDateTime.from(prayerNotificationModel.dateTime,
        tz.getLocation(await FlutterTimezone.getLocalTimezone()));
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      prayerNotificationModel.id,
      prayerNotificationModel.name,
      "Sudah masuk waktu ${prayerNotificationModel.name}",
      time,
      payload:
          "${prayerNotificationModel.name}.${prayerNotificationModel.time}",
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    Logger().i(
        "${prayerNotificationModel.name} ${androidPlatformChannelSpecifics.channelId} : $time");
  }
}
