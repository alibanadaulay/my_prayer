import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_prayer/domain/adhnan/current_prayer.dart';
import 'package:my_prayer/domain/adhnan/today_prayers.dart';
import 'package:my_prayer/features/state_ui.dart';
import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/services/notification.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:geolocator/geolocator.dart';

class HomeViewModel extends ChangeNotifier {
  String locationName = " ";
  String arabicDate = "28 Rabiul Awwal 1445 H";
  String date = "Senin , 28 Maret 2022";
  String remainingTime = "00:00:00";
  String timePrayer = "-";
  String currenPrayer = "-";
  int seconds = 0;
  List<PrayerTimeModel> prayerTimes = [];
  String? _isoCountryCode = "";
  Placemark? _placemark;
  Timer? _remainingTimeTimer;

  ViewState _prayerListState = ViewState.idle;
  ViewState get prayerListState => _prayerListState;

  final PermissionUtils _permissionUtils;
  final GetTodayPrayer _todayPrayer;
  final GetCurrentPrayerUseCases _currentPrayer;
  final NotificationServive _notificationServive;

  HomeViewModel(this._permissionUtils, this._todayPrayer, this._currentPrayer,
      this._notificationServive);

  void init() async {
    arabicDate = "${HijriCalendar.now().toFormat("dd MMMM yyyy")}H";
    _setupPrayer();
  }

  Future<void> _getTodayPrayer() async {
    _prayerListState = ViewState.loading;
    notifyListeners();
    try {
      prayerTimes = await _todayPrayer.getTodayPrayer(
          locationName, _isoCountryCode ?? "-");
      _prayerListState = ViewState.success;
      notifyListeners();
    } catch (e) {
      _prayerListState = ViewState.error;
    }
  }

  void _setupPrayer() async {
    await _setLocationName("");
    await _getTodayPrayer();
    await _getCurrentPrayer();
    await _calculateCurrentTimeWithPrayerTime();

    _countDownPrayer();
  }

  Future<void> _getCurrentPrayer() async {
    PrayerTimeModel result = await _currentPrayer.getCurrentPrayer(prayerTimes);
    currenPrayer = result.name;
    timePrayer = result.time;
    notifyListeners();

    DateTime targetTime =
        await _getTargetTime(result.name == "Subuh", timePrayer);

    _notificationServive.scheduleAlarm(targetTime, result.id, result.name);
  }

  void setNewLocation() {
    _setupPrayer();
  }

  Future<void> _setLocationName(String name) async {
    if (name.isEmpty) {
      Position? result = await _permissionUtils.getCurrentPosition();
      if (result == null) {
        locationName = "Mampang";
      } else {
        await _getPlaceMark(result);
      }
      notifyListeners();
      return;
    }
    locationName = name;
    notifyListeners();
  }

  Future<void> _getPlaceMark(Position position) async {
    _placemark = await _permissionUtils.getCityName(position);
    if (_placemark != null) {
      locationName = _placemark!.locality ?? "";
      _isoCountryCode = _placemark!.isoCountryCode;
    }
  }

  Future<void> _calculateCurrentTimeWithPrayerTime() async {
    final DateTime now = DateTime.now();

    DateTime targetTime =
        await _getTargetTime(currenPrayer == "Subuh", timePrayer);

    seconds = targetTime.difference(now).inSeconds;
  }

  Future<DateTime> _getTargetTime(bool isFajr, String hourMinute) async {
    final DateTime now = DateTime.now();

    List<String> parts = hourMinute.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int nextDay = 0;
    if (isFajr) {
      nextDay = 1;
    }

    DateTime targetTime = DateTime(
      now.year,
      now.month,
      now.day + nextDay,
      hours,
      minutes,
    );

    return targetTime;
  }

  void _countDownPrayer() {
    if (_remainingTimeTimer?.isActive == true) {
      return;
    }
    _remainingTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      if (seconds < 0) {
        timer.cancel();
        _countDownPrayer();
      } else {
        remainingTime = _formatSecondsToHHMM(seconds);
        notifyListeners();
      }
    });
  }

  String _formatSecondsToHHMM(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final second = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$second';
  }
}
