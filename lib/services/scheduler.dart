import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:my_prayer/domain/adhnan/create_prayers_notification.dart';
import 'package:my_prayer/domain/adhnan/month_prayers.dart';
import 'package:my_prayer/domain/adhnan/today_prayers.dart';
import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/services/native_birdge.dart';
import 'package:my_prayer/utils/prefes_utils.dart';

class Scheduler {
  final CreatePrayerNotification _createPrayerNotification;
  final GetMonthPrayer _getMonthPrayer;
  final GetTodayPrayer _getTodayPrayer;

  String _city = "";
  String _isoCity = "";

  Scheduler(this._createPrayerNotification, this._getMonthPrayer,
      this._getTodayPrayer);

  void initCron() {
    _setPrayerEveryMidnightTimesAlarm();
    _setFirstDayAtMonth();
  }

  void _setPrayerEveryMidnightTimesAlarm() async {
    Duration initialDelay = await _getUntilMidnight();
    final int alarmId = 0;
    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      alarmId,
      _alarmMidnightCallback,
      startAt: DateTime.now().add(initialDelay),
      exact: true,
      wakeup: false,
    );
  }

  void _alarmMidnightCallback() async {
    FirebaseAnalytics.instance.logEvent(name: "start_set_alarm_midnight");
    await _getCityName();
    await _createPrayerNotification.createNotificaion([]);
    await _setPrayerTiemToWidget();
    FirebaseAnalytics.instance.logEvent(name: "success_set_alarm_midnight");
  }

  void _setFirstDayAtMonth() async {
    Duration initialDelay = await _getMidnightDayOne();
    final int alarmId = 1;
    await AndroidAlarmManager.periodic(
      const Duration(days: 30),
      alarmId,
      () async {
        await _getCityName();
        _getMonthPrayer.getMonthPrayer(_city, _isoCity);
      },
      startAt: DateTime.now().add(initialDelay),
      exact: true,
      wakeup: false,
    );
  }

  Future<Duration> _getUntilMidnight() async {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 5);
    return nextMidnight.difference(now);
  }

  Future<Duration> _getMidnightDayOne() async {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month + 1, 1);
    return nextMidnight.difference(now);
  }

  Future<void> _setPrayerTiemToWidget() async {
    List<PrayerTimeModel> prayerTimes =
        await _getTodayPrayer.getTodayPrayer(_city, _isoCity);

    Map<String, String> prayerTimesMap = {
      'Fajr': prayerTimes[0].time,
      'Sunrise': prayerTimes[1].time,
      'Dhuhr': prayerTimes[2].time,
      'Asr': prayerTimes[3].time,
      'Maghrib': prayerTimes[4].time,
      'Isha': prayerTimes[5].time,
    };

    NativeBirdge.updatePrayerWidget(prayerTimesMap);
  }

  Future<void> _getCityName() async {
    _city = PrefesUtils.getString(PrefesUtils.cityParam);
    _isoCity = PrefesUtils.getString(PrefesUtils.isoCityParam);
  }
}
