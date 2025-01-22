import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationServive {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    Logger().i(tz.local.currentTimeZone); // Check again

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

  Future<void> scheduleAlarm(
      DateTime scheduledTime, int id, String title, String isoCountry) async {
    final List<PendingNotificationRequest> pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

    Logger().i(scheduledTime.toString());
    Logger()
        .i(tz.TZDateTime.from(scheduledTime, tz.getLocation('Asia/Jakarta')));
    Logger().i(tz.TZDateTime.from(scheduledTime, tz.UTC));

    for (var notification in pendingNotifications) {
      if (notification.id == id) {
        await _flutterLocalNotificationsPlugin.cancel(id);
        Logger().d("notificationId is found ${notification.id}");
        // return;
      }
    }
    Logger().d("schedule Alaram $id");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'prayer_notification_id', 'Alarm Notifications',
            channelDescription: 'Channel for alarm notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: "@drawable/app_icon");

    // _flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()!
    //     .startForegroundService(
    //         1, 'Foreground service is running', 'Foreground service',
    //         notificationDetails: androidPlatformChannelSpecifics);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    var time =
        tz.TZDateTime.from(scheduledTime, tz.getLocation('Asia/Jakarta'));
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      "Sudah masuk waktu $title && $time",
      time,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    for (var notification in await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests()) {
      if (notification.id == id) {
        Logger().i("${notification.body}");
      }
    }
  }
}
