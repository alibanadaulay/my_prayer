import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:my_prayer/common/adhan_dio.dart';
import 'package:my_prayer/main.dart';
import 'package:my_prayer/model/db/db_config.dart';
import 'package:my_prayer/model/db/prayer_db.dart';
import 'package:my_prayer/model/json/prayer_times_month_response.dart';
import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/model/prayre_notification_model.dart';
import 'package:my_prayer/services/notification.dart';
import 'package:my_prayer/utils/prefes_utils.dart';

class Scheduler {
  static String _city = "";
  static String _isoCity = "";

  Future<void> initScheduler() async {
    _setPrayerEveryMidnightTimesAlarm();
    _setFirstDayAtMonth();
  }

  Future<void> _setPrayerEveryMidnightTimesAlarm() async {
    try {
      Duration initialDelay = await _getUntilMidnight();
      final int alarmId = 0;
      await AndroidAlarmManager.periodic(
          const Duration(days: 1), alarmId, _alarmMidnightCallback,
          exact: true,
          wakeup: true,
          startAt: DateTime.now().add(initialDelay),
          rescheduleOnReboot: true);
    } catch (e) {
      Logger().d("_alarmMidnightCallback $e");
    }
  }

  static Future<void> _alarmMidnightCallback() async {
    try {
      Logger().d("_alarmMidnightCallback");
      List<PrayerTimeModel> prayerTimes = await _getListPrayerTime();
      await _generateNotification(prayerTimes);
      await _setPrayerTiemToWidget(prayerTimes);
    } catch (e) {}
  }

  Future<void> _setFirstDayAtMonth() async {
    Duration initialDelay = await _getMidnightDayOne();
    final int alarmId = 1;
    await AndroidAlarmManager.periodic(
      const Duration(days: 30),
      alarmId,
      () async {
        await _getCityName();
        _getPrayerForOneMonth();
      },
      startAt: DateTime.now().add(initialDelay),
      exact: true,
      wakeup: false,
    );
  }

  Future<Duration> _getUntilMidnight() async {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day, 19, 50);
    return nextMidnight.difference(now);
  }

  Future<Duration> _getMidnightDayOne() async {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month + 1, 1);
    return nextMidnight.difference(now);
  }

  static Future<void> _setPrayerTiemToWidget(
      List<PrayerTimeModel> prayerTimes) async {
    Map<String, String> prayerTimesMap = {
      'Fajr': prayerTimes[0].time,
      'Sunrise': prayerTimes[1].time,
      'Dhuhr': prayerTimes[2].time,
      'Asr': prayerTimes[3].time,
      'Maghrib': prayerTimes[4].time,
      'Isha': prayerTimes[5].time,
    };

    PrefesUtils.setString("prayerTimes", jsonEncode(prayerTimesMap));
    Logger().i("setStringPlatform");
  }

  static Future<void> _getCityName() async {
    _city = await PrefesUtils.getString(PrefesUtils.cityParam);
    _isoCity = await PrefesUtils.getString(PrefesUtils.isoCityParam);
  }

  static Future<List<PrayerTimeModel>> _getListPrayerTime() async {
    if (!Hive.isBoxOpen(PRAYER)) {
      await hiveInit(); // Reinitialize if necessary
    }
    Box<PrayerDb> box = await Hive.openBox(PRAYER);

    PrayerDb? prayerDb =
        box.get(DateFormat("DD-MM-yyyy").format(DateTime.now()));
    if (prayerDb != null) {
      List<PrayerTimeModel> prayerTimes = [];
      for (PrayerModel timeModel in prayerDb.prayersModel) {
        prayerTimes.add(PrayerTimeModel(
            id: timeModel.id,
            name: timeModel.prayerName,
            time: timeModel.prayerTime.replaceAll(RegExp(r" \([^)]+\)"), "")));
      }
      return prayerTimes;
    }

    return [];
  }

  static Future<void> _generateNotification(
      List<PrayerTimeModel> prayerTimeList) async {
    final DateTime dateTime = DateTime.now();
    NotificationServive.cancelAllPendingNotification();
    for (PrayerTimeModel item in prayerTimeList) {
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
      PrayreNotificationModel prayreNotificationModel = PrayreNotificationModel(
          id: item.id,
          isSound: await PrefesUtils.getBool(item.name),
          dateTime: prayerTime,
          soundName: item.name == "Subuh" ? "fajr_adhan" : "adhan",
          name: item.name);
      NotificationServive.scheduleAlarm(prayreNotificationModel);
    }
  }

  static void _getPrayerForOneMonth() async {
    DateTime today = DateTime.now();

    String adhanUrl =
        "calendarByCity/${today.year}/${today.month}?city=$_city&country=$_isoCity&method=20&shafaq=general";
    final response = await AdhanClientDio().dio.get(adhanUrl);
    PrayerTimesMonthResponse data =
        PrayerTimesMonthResponse.fromJson(response.data);

    if (!Hive.isBoxOpen(PRAYER)) {
      await hiveInit();
    }
    Box<PrayerDb> box = await Hive.openBox(PRAYER);
    box.clear();
    await _saveMonthPrayer(data, box).onError((error, stackTrace) {
      box.close();
      return null;
    });
    box.close();
  }

  static Future<void> _saveMonthPrayer(
      PrayerTimesMonthResponse data, Box<PrayerDb> box) async {
    for (PrayerTimesMonthResponseData item in data.data) {
      List<PrayerModel> prayerModels = [];
      prayerModels.add(PrayerModel(
        id: 0,
        prayerName: "Subuh",
        prayerTime: item.timings.Fajr,
      ));
      prayerModels.add(PrayerModel(
        id: 1,
        prayerName: "Sunrise",
        prayerTime: item.timings.Sunrise,
      ));

      prayerModels.add(PrayerModel(
        id: 2,
        prayerName: "Dzuhur",
        prayerTime: item.timings.Dhuhr,
      ));

      prayerModels.add(PrayerModel(
        id: 3,
        prayerName: "Ashar",
        prayerTime: item.timings.Asr,
      ));

      prayerModels.add(PrayerModel(
        id: 4,
        prayerName: "Maghrib",
        prayerTime: item.timings.Maghrib,
      ));

      prayerModels.add(PrayerModel(
        id: 5,
        prayerName: "Isha",
        prayerTime: item.timings.Isha,
      ));

      PrayerDb prayerDb = PrayerDb(
          date: item.date.gregorian.date,
          city: _city,
          isCountry: _isoCity,
          prayersModel: prayerModels);

      await box.put(item.date.gregorian.date, prayerDb);
    }
  }
}
