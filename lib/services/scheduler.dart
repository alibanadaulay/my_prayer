// ignore_for_file: non_constant_identifier_names

import 'package:cron/cron.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_prayer/domain/adhnan/create_prayers_notification.dart';
import 'package:my_prayer/domain/adhnan/month_prayers.dart';
import 'package:my_prayer/utils/permission_utils.dart';

class Scheduler {
  String EVERYDAY_CRON = '* 5 0 * * *';
  String FIRST_MONTH_CRON = '* 0 0 1 * *';

  final CreatePrayerNotification _createPrayerNotification;
  final GetMonthPrayer _getMonthPrayer;
  final PermissionUtils _permissionUtils = PermissionUtils();

  Scheduler(this._createPrayerNotification, this._getMonthPrayer);

  final cron = Cron();

  void initCron() {
    _setPrayerEveryMidnightTimesAlarm();
    _setFirstDayAtMonth();
  }

  void _setPrayerEveryMidnightTimesAlarm() async {
    cron.schedule(Schedule.parse(EVERYDAY_CRON), () async {
      _createPrayerNotification.createNotificaion([]);
    });
  }

  void _setFirstDayAtMonth() {
    cron.schedule(Schedule.parse(FIRST_MONTH_CRON), () async {
      Position? result = await _permissionUtils.getCurrentPosition();
      if (result != null) {
        Placemark? placemark = await _permissionUtils.getCityName(result);
        if (placemark != null) {
          _getMonthPrayer.getMonthPrayer(
              placemark.locality ?? "", placemark.isoCountryCode!);
        }
      }
    });
  }
}
