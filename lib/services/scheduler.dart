// ignore_for_file: non_constant_identifier_names

import 'package:cron/cron.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:my_prayer/domain/adhnan/create_prayers_notification.dart';
import 'package:my_prayer/domain/adhnan/month_prayers.dart';
import 'package:my_prayer/domain/adhnan/today_prayers.dart';
import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/services/native_birdge.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Scheduler {
  String EVERYDAY_CRON = '* 5 0 * * *';
  String FIRST_MONTH_CRON = '* 0 0 1 * *';

  final CreatePrayerNotification _createPrayerNotification;
  final GetMonthPrayer _getMonthPrayer;
  final GetTodayPrayer _getTodayPrayer;

  String _city = "";
  String _isoCity = "";

  Scheduler(this._createPrayerNotification, this._getMonthPrayer,
      this._getTodayPrayer);

  final cron = Cron();

  void initCron() {
    _setPrayerEveryMidnightTimesAlarm();
    _setFirstDayAtMonth();
  }

  void _setPrayerEveryMidnightTimesAlarm() async {
    cron.schedule(Schedule.parse(EVERYDAY_CRON), () async {
      FirebaseAnalytics.instance.logEvent(name: "start_set_alarm_midnight");
      await _getCityName();
      await _createPrayerNotification.createNotificaion([]);
      await _setPrayerTiemToWidget();
      FirebaseAnalytics.instance.logEvent(name: "success_set_alarm_midnight");
    });
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _city = prefs.getString("city") ?? "";
    _isoCity = prefs.getString("isoCity") ?? "";
  }

  void _setFirstDayAtMonth() {
    cron.schedule(Schedule.parse(FIRST_MONTH_CRON), () async {
      await _getCityName();
      _getMonthPrayer.getMonthPrayer(_city, _isoCity);
    });
  }
}
