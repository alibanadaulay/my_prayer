import 'package:my_prayer/model/prayre_notification_model.dart';
import 'package:my_prayer/services/notification.dart';
import 'package:my_prayer/utils/prefes_utils.dart';

class CreatePrayerNotification {
  Future<void> createNotification(int id, String name, String time) async {
    List<String> parts = time.split(':');
    late DateTime dateTime = DateTime.now();

    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    DateTime prayerTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      hours,
      minutes,
    );

    PrayreNotificationModel prayerNotificationModel = PrayreNotificationModel(
        id: id,
        time: time,
        isSound: await PrefesUtils.getBool(name),
        dateTime: prayerTime,
        soundName: name == "Subuh" ? "fajr_adhan_mecca" : "adhan_mecca",
        name: name);

    await NotificationService.cancelNotificationById(id);
    await NotificationService.scheduleAlarm(prayerNotificationModel);
  }
}
