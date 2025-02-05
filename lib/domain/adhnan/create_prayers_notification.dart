import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:my_prayer/model/db/db_config.dart';
import 'package:my_prayer/model/db/prayer_db.dart';
import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/model/prayre_notification_model.dart';
import 'package:my_prayer/services/notification.dart';
import 'package:my_prayer/utils/prefes_utils.dart';

class CreatePrayersNotification {
  late DateTime _dateTime = DateTime.now();
  late List<PrayerTimeModel> _prayerTimeList;

  Future<void> createNotificaion(List<PrayerTimeModel> prayers) async {
    _dateTime = DateTime.now();
    _prayerTimeList = prayers;
    if (_prayerTimeList.isEmpty) {
      _prayerTimeList = await _getListPrayerTime();
    }

    NotificationService.cancelAllPendingNotification();
    for (PrayerTimeModel item in _prayerTimeList) {
      List<String> parts = item.time.split(':');

      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      DateTime prayerTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        hours,
        minutes,
      );
      PrayreNotificationModel prayreNotificationModel = PrayreNotificationModel(
          id: item.id,
          isSound: await PrefesUtils.getBool(item.name),
          dateTime: prayerTime,
          time: item.time,
          soundName: item.name == "Subuh" ? "fajr_adhan" : "adhan",
          name: item.name);
      NotificationService.scheduleAlarm(prayreNotificationModel);
    }
  }

  Future<List<PrayerTimeModel>> _getListPrayerTime() async {
    Box<PrayerDb> box = await Hive.openBox(PRAYER);

    PrayerDb? prayerDb = box.get(DateFormat("dd-MM-yyyy").format(_dateTime));
    if (prayerDb != null) {
      List<PrayerTimeModel> prayerTimes = [];
      for (PrayerModel timeModel in prayerDb.prayersModel) {
        prayerTimes.add(PrayerTimeModel(
            id: timeModel.id,
            date: prayerDb.date,
            name: timeModel.prayerName,
            time: timeModel.prayerTime.replaceAll(RegExp(r" \([^)]+\)"), "")));
      }
      return prayerTimes;
    }

    return [];
  }
}
