import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:my_prayer/model/prayre_notification_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationServive {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
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
        Logger().i("Receiver Notification ${details.id} ${details.input}");
      },
      onDidReceiveBackgroundNotificationResponse: (details) {
        Logger().i("Receiver Notification ${details.id}");
      },
    );
  }

  Future<List<PendingNotificationRequest>> getPendingNotification() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelAllPendingNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleAlarm(
      PrayreNotificationModel prayerNotificationModel) async {
    if (DateTime.now().isAfter(prayerNotificationModel.dateTime)) {
      return;
    }
    final List<PendingNotificationRequest> pendingNotifications =
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
            playSound: prayerNotificationModel.isSound,
            sound: RawResourceAndroidNotificationSound(
                prayerNotificationModel.soundName),
            icon: "@drawable/app_icon");

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    var time = tz.TZDateTime.from(
        prayerNotificationModel.dateTime, tz.getLocation('Asia/Jakarta'));
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      prayerNotificationModel.id,
      prayerNotificationModel.name,
      "Sudah masuk waktu ${prayerNotificationModel.name}",
      time,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
