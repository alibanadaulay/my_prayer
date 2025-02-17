import 'dart:async';
import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
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
import 'package:my_prayer/utils/calender_utils.dart';
import 'package:my_prayer/utils/prefes_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
Future<void> onAlarmEverySixHourCallback(bool fromWorkmanager) async {
  if (!fromWorkmanager) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
  String uuid = Uuid().v4();
  String pattern = "dd-MM-yyyy hh:mm:ss";
  final DateTime dateTime = DateTime.now();

  FirebaseAnalytics.instance.logEvent(
    name: 'onAlarmEverySixHourCallbackStart',
    parameters: {
      'time': DateFormat(pattern).format(dateTime),
      'uuid': uuid,
      'is_from_workmanager': fromWorkmanager.toString()
    },
  );
  await Scheduler.handleAlarmEverySixHour();
  final DateTime lastTime = DateTime.now();

  FirebaseAnalytics.instance
      .logEvent(name: 'onAlarmEverySixHourCallbackSuccess', parameters: {
    'time': DateFormat(pattern).format(lastTime),
    'uuid': uuid,
    'is_from_workmanager': fromWorkmanager.toString()
  });
}

@pragma('vm:entry-point')
Future<void> alarmFirstDayAtNewMonth(bool fromWorkmanager) async {
  if (!fromWorkmanager) {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();
  }
  String uuid = Uuid().v4();
  String pattern = "dd-MM-yyyy hh:mm:ss";
  final DateTime dateTime = DateTime.now();

  FirebaseAnalytics.instance.logEvent(
    name: 'alarmFirstDayAtNewMonthStart',
    parameters: {
      'time': DateFormat(pattern).format(dateTime),
      'uuid': uuid,
      'is_from_workmanager': fromWorkmanager.toString()
    },
  );

  try {
    await Scheduler.getPrayerForOneMonth();
    final DateTime successDt = DateTime.now();
    FirebaseAnalytics.instance.logEvent(
      name: 'alarmFirstDayAtNewMonthSuccess',
      parameters: {
        'time': DateFormat(pattern).format(successDt),
        'uuid': uuid,
        'is_from_workmanager': fromWorkmanager.toString()
      },
    );
  } catch (e, stack) {
    FirebaseCrashlytics.instance.recordError(e, stack);
  } finally {
    await Scheduler.setFirstDayAtMonth();
  }
}

@pragma('vm:entry-point')
void handlerWorkManager() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'midnight_alarm':
          await onAlarmEverySixHourCallback(true);

        default:
          await alarmFirstDayAtNewMonth(true);
      }
      return Future.value(true);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      return Future.error(e);
    }
  });
}

class Scheduler {
  static String _city = "";
  static String _isoCity = "";
  static List<String> hours = ['00', '03', '06', '09', '12', '15', '18', '21'];
  static const String midnightAlarm = "midnight_alarm";
  static const String firstDayNewMonth = "firstDayNewMonth";

  static const int midnightAlarmId = 0;
  static const int firstDayNewMonthId = 1;

  static const int _delaySetPrayerTme = 3;

  static Workmanager? _workmanager;

  static Future<void> initScheduler() async {
    _workmanager = Workmanager();
    await _workmanager!
        .initialize(handlerWorkManager, isInDebugMode: true)
        .whenComplete(() {
      setWorkMangerThreeHour();
    });
    _setPrayerEveryMidnightTimesAlarm();
    AndroidAlarmManager.cancel(2);
    setFirstDayAtMonth();
  }

  static void setWorkMangerThreeHour() async {
    Duration initialDelay = await _getUntilMidnight();
    await workMangerThreeHours(initialDelay);
  }

  static Future<void> _setPrayerEveryMidnightTimesAlarm() async {
    try {
      int alarmId = await PrefesUtils.getInt(PrefesUtils.midnightAlarmId);
      if (alarmId != midnightAlarmId) {
        await _generateMidnightAlarm(midnightAlarmId);
        PrefesUtils.setInt(PrefesUtils.midnightAlarmId, midnightAlarmId);
      }
    } catch (e) {
      Logger().e("_alarmMidnightCallback $e");
    }
  }

  static Future<void> _testAlarm(int alarmId) async {
    DateTime now = DateTime.now();
    DateTime delay =
        DateTime(now.year, now.month, now.day, now.hour, now.minute + 3);
    Duration initialDelay = delay.difference(now);
    await AndroidAlarmManager.periodic(
        const Duration(minutes: 5), alarmId, onAlarmEverySixHourCallback,
        exact: true,
        wakeup: true,
        startAt: DateTime.now().add(initialDelay),
        rescheduleOnReboot: true);
  }

  static Future<void> _generateMidnightAlarm(int midnightAlarmId) async {
    Duration initialDelay = await _getUntilMidnight();
    DateTime now = DateTime.now();

    await workMangerThreeHours(initialDelay);
    await AndroidAlarmManager.periodic(
        const Duration(hours: _delaySetPrayerTme), midnightAlarmId, () {
      onAlarmEverySixHourCallback(false);
    },
        exact: true,
        wakeup: true,
        startAt: DateTime.now().add(initialDelay),
        rescheduleOnReboot: true);
  }

  static Future<void> workMangerThreeHours(Duration initialDelay) async {
    try {
      if (!await PrefesUtils.getBool(PrefesUtils.isWorkManagerThreeHour)) {
        await _workmanager!.registerPeriodicTask(
            midnightAlarmId.toString(), midnightAlarm,
            frequency: Duration(hours: _delaySetPrayerTme),
            initialDelay: initialDelay);
        PrefesUtils.setBool(PrefesUtils.isWorkManagerThreeHour, true);
      } else {}
    } catch (e, stack) {
      Logger().e("$e -- ${stack.toString()}");
    }
  }

  static Future<void> handleAlarmEverySixHour() async {
    try {
      List<PrayerTimeModel> prayerTimes = await _getListPrayerTime();
      if (prayerTimes.isEmpty) {
        return;
      }
      PrefesUtils.getInstance();
      await _generateNotification(prayerTimes);
      await _setPrayerTiemToWidget(prayerTimes);
      await _setArabicDate(prayerTimes[4].time);
    } catch (e) {
      Logger().e("_alarmMidnightCallback $e");
    }
  }

  static Future<void> setFirstDayAtMonth() async {
    DateTime nextMonth = await _getMidnightDayOne();
    Duration nextMonthDuration = nextMonth.difference(DateTime.now());
    Workmanager().registerOneOffTask(
        firstDayNewMonthId.toString(), firstDayNewMonth,
        initialDelay: nextMonthDuration);
    await AndroidAlarmManager.oneShotAt(nextMonth, firstDayNewMonthId, () {
      alarmFirstDayAtNewMonth(false);
    }, exact: true, wakeup: false);
  }

  static Future<Duration> _getUntilMidnight() async {
    DateTime now = DateTime.now();
    DateTime? temp;

    for (String time in hours) {
      DateTime compare =
          DateTime(now.year, now.month, now.day, int.parse(time), 5);

      if (compare.isAfter(now) && (temp == null || compare.isBefore(temp))) {
        temp = compare;
      }
    }

    if (temp != null) {
      return temp.difference(now);
    }
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1, 00, 05);

    return nextMidnight.difference(now);
  }

  static Future<DateTime> _getMidnightDayOne() async {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month + 1, 1);
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

    PrefesUtils.setString(PrefesUtils.prayerTimes, jsonEncode(prayerTimesMap));
  }

  static Future<void> _setArabicDate(String date) async {
    try {
      String arabicDate = "${await CalenderUtils.getHijriDate(date)}H";
      PrefesUtils.setString(PrefesUtils.arabicDate, arabicDate);
    } catch (e) {
      Logger().e("_setArabicDate $e");
    }
  }

  static Future<void> _getCityName() async {
    _city = await PrefesUtils.getString(PrefesUtils.cityParam);
    _isoCity = await PrefesUtils.getString(PrefesUtils.isoCityParam);
  }

  static Future<List<PrayerTimeModel>> _getListPrayerTime() async {
    try {
      if (!Hive.isAdapterRegistered(0)) {
        await hiveInit();
      }
      Box<PrayerDb> box = await Hive.openBox(PRAYER);

      String date = DateFormat("dd-MM-yyyy").format(DateTime.now());
      PrayerDb? prayerDb = box.get(date);

      if (prayerDb != null) {
        List<PrayerTimeModel> prayerTimes = [];
        for (PrayerModel timeModel in prayerDb.prayersModel) {
          prayerTimes.add(PrayerTimeModel(
              id: timeModel.id,
              date: date,
              name: timeModel.prayerName,
              time:
                  timeModel.prayerTime.replaceAll(RegExp(r" \([^)]+\)"), "")));
        }
        return prayerTimes;
      }
    } catch (e) {
      Logger().e("_getListPrayerTime $e");
      return [];
    }

    return [];
  }

  static Future<void> _generateNotification(
      List<PrayerTimeModel> prayerTimeList) async {
    final DateTime dateTime = DateTime.now();
    try {
      NotificationService.initialize();
      NotificationService.cancelAllPendingNotification();
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
        PrayreNotificationModel prayreNotificationModel =
            PrayreNotificationModel(
                id: item.id,
                isSound: await PrefesUtils.getBool(item.name),
                dateTime: prayerTime,
                time: item.time,
                soundName: item.name == "Subuh" ? "fajr_adhan" : "adhan",
                name: item.name);
        NotificationService.scheduleAlarm(prayreNotificationModel);
      }
    } catch (e) {
      Logger().e("_generateNotification $e");
    }
  }

  static Future<void> getPrayerForOneMonth() async {
    DateTime today = DateTime.now();

    String adhanUrl =
        "calendarByCity/${today.year}/${today.month}?city=$_city&country=$_isoCity&method=20&shafaq=general";
    final response = await AdhanClientDio().dio.get(adhanUrl);
    PrayerTimesMonthResponse data =
        PrayerTimesMonthResponse.fromJson(response.data);

    Logger().i("isAdapterRegis ${!Hive.isAdapterRegistered(0)}");
    if (!Hive.isAdapterRegistered(0)) {
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
