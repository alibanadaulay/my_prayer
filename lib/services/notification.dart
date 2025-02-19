import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:my_prayer/model/prayre_notification_model.dart';
import 'package:my_prayer/services/native_birdge.dart';
import 'package:my_prayer/utils/calender_utils.dart';
import 'package:my_prayer/utils/prefes_utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse details) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String uuid = Uuid().v4();
  String pattern = "dd-MM-yyyy hh:mm:ss";
  final DateTime dateTime = DateTime.now();
  FirebaseAnalytics.instance.logEvent(
    name: 'onBackgroundNotificationResponseStart',
    parameters: {
      'payload': details.payload ?? 'unknown',
      'notification_id': details.id.toString(),
      'time': DateFormat(pattern).format(dateTime),
      'uuid': uuid
    },
  );

  try {
    await NotificationService.updateDate(details.payload, details.id, false);
    FirebaseAnalytics.instance.logEvent(
      name: 'onBackgroundNotificationResponseSuccess',
      parameters: {
        'payload': details.payload ?? 'unknown',
        'notification_id': details.id.toString(),
        'time': DateFormat(pattern).format(dateTime),
        'uuid': uuid
      },
    );
  } catch (e, stack) {
    FirebaseCrashlytics.instance.recordError(e, stack);
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
        updateDate(details.payload, details.id, false);
      },
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );
  }

  static Future<void> updateDate(
      String? payload, int? id, bool isFromWorkManager) async {
    if (payload == null) {
      return;
    }
    await PrefesUtils.getInstance();
    String? time;
    if (isFromWorkManager) {
      time = payload;
    } else {
      List<String> part = payload.split('.');
      time = part[1];
    }
    int nextPrayerId = (id ?? 0) + 1;
    if (nextPrayerId > 5) {
      nextPrayerId = 0;
    }
    await PrefesUtils.setInt(PrefesUtils.currentPrayer, nextPrayerId);
    String hijriDate = "${await CalenderUtils.getHijriDate(time)}H";
    await PrefesUtils.setString(PrefesUtils.arabicDate, hijriDate);
    NativeBridge.triggerUpdate();
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
  }
}
