import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/services/notification.dart';

class CreatePrayerNotification {
  final NotificationServive _notificationService;

  CreatePrayerNotification(this._notificationService);

  void createNotificaion(List<PrayerTimeModel> prayers) {
    final DateTime dateTime = DateTime.now();

    for (PrayerTimeModel item in prayers) {
      List<String> parts = item.time.split(':');

      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      DateTime prayerTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        hours,
        minutes,
      );
      _notificationService.scheduleAlarm(prayerTime, item.id, item.name);
    }
  }
}
