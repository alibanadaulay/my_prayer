import 'dart:async';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_prayer/domain/adhnan/create_prayer_notification.dart';
import 'package:my_prayer/domain/adhnan/create_prayers_notification.dart';
import 'package:my_prayer/domain/adhnan/current_prayer.dart';
import 'package:my_prayer/domain/adhnan/month_prayers.dart';
import 'package:my_prayer/domain/adhnan/today_prayers.dart';
import 'package:my_prayer/features/state_ui.dart';
import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/utils/calender_utils.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_prayer/utils/prefes_utils.dart';

class HomeViewModel extends ChangeNotifier {
  String locationName = " ";
  String arabicDate = "28 Rabiul Awwal 1445 H";
  String _todayDate = "";
  String remainingTime = "00:00:00";
  String timePrayer = "-";
  String currenPrayer = "-";
  int prayerId = 1;
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
  final CreatePrayersNotification _createPrayersNotification;
  final GetMonthPrayer _getMonthPrayer;
  final CreatePrayerNotification _createPrayerNotification;

  HomeViewModel(
      this._permissionUtils,
      this._todayPrayer,
      this._currentPrayer,
      this._createPrayersNotification,
      this._getMonthPrayer,
      this._createPrayerNotification);

  void init() async {
    getHijriDate(null);
    await _setLocationName("");
    _getMonthPrayer.getMonthPrayer(locationName, _isoCountryCode ?? "ID");
    _setupPrayer();
  }

  Future<void> getHijriDate(String? date) async {
    arabicDate = "${await CalenderUtils.getHijriDate(date)}H";
    PrefesUtils.setString(PrefesUtils.arabicDate, arabicDate);
  }

  Future<void> _getTodayPrayer() async {
    _prayerListState = ViewState.loading;
    notifyListeners();
    try {
      prayerTimes = await _todayPrayer.getTodayPrayer(
          locationName, _isoCountryCode ?? "-");
      await getHijriDate(prayerTimes[4].time);
      _prayerListState = ViewState.success;
      notifyListeners();
    } catch (e) {
      _prayerListState = ViewState.error;
    }
  }

  void _setupPrayer() async {
    await _getTodayPrayer();
    await _getCurrentPrayer();
    await _calculateCurrentTimeWithPrayerTime();
    _sendPrayerTimeToNative();
    _createPrayersNotification.createNotificaion(prayerTimes);

    _countDownPrayer();
  }

  Future<void> _getCurrentPrayer() async {
    PrayerTimeModel result = await _currentPrayer.getCurrentPrayer(prayerTimes);

    currenPrayer = result.name;
    timePrayer = result.time;
    _todayDate = result.date;
    await _addCurrentToList(result);
    notifyListeners();
    PrefesUtils.setInt(PrefesUtils.currentPrayer, result.id);
  }

  Future<void> _addCurrentToList(PrayerTimeModel prayerTimeModel) async {
    if (prayerTimes.isNotEmpty) {
      prayerTimes = prayerTimes.map((item) {
        if (item.id == prayerTimeModel.id) {
          item.isNextPrayer = true;
          return item;
        }
        item.isNextPrayer = false;
        return item;
      }).toList();
    }
  }

  void setNewLocation() async {
    await _setLocationName("");

    _setupPrayer();
  }

  void recalculatedRemainingPrayerTime() {
    _calculateCurrentTimeWithPrayerTime();
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
      saveCityName();
    }
  }

  Future<void> _calculateCurrentTimeWithPrayerTime() async {
    final DateTime now = DateTime.now();

    DateTime? targetTime =
        await _getTargetTime(currenPrayer == "Subuh", timePrayer);

    if (targetTime == null) {
      return;
    }

    seconds = targetTime.difference(now).inSeconds;
  }

  Future<DateTime?> _getTargetTime(bool isFajr, String hourMinute) async {
    final DateTime now = DateTime.now();
    if (hourMinute.isEmpty) {
      return null;
    }

    List<String> parts = hourMinute.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int nextDay = 0;
    if (isFajr &&
        _todayDate == DateFormat("dd-MM-yyyy").format(DateTime.now())) {
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

  Future<void> _sendPrayerTimeToNative() async {
    if (prayerTimes.isEmpty) {
      return;
    }

    Map<String, String> prayerTimesMap = {
      'Fajr': prayerTimes[0].time,
      'Sunrise': prayerTimes[1].time,
      'Dhuhr': prayerTimes[2].time,
      'Asr': prayerTimes[3].time,
      'Maghrib': prayerTimes[4].time,
      'Isha': prayerTimes[5].time,
    };

    PrefesUtils.setString("prayerTimes", jsonEncode(prayerTimesMap));
  }

  void updateNotificationPrayer(
      int id, String name, bool isSound, String time) async {
    if (isSound != await PrefesUtils.getBool(name)) {
      await PrefesUtils.setBool(name, isSound);
      _createPrayerNotification.createNotification(id, name, time);
    }
  }

  void saveCityName() async {
    PrefesUtils.setString(PrefesUtils.cityParam, locationName);
    PrefesUtils.setString(PrefesUtils.isoCityParam, _isoCountryCode ?? "-");
  }

  void _countDownPrayer() {
    if (_remainingTimeTimer != null && _remainingTimeTimer?.isActive == true) {
      _remainingTimeTimer!.cancel();
      _remainingTimeTimer = null;
    }
    _remainingTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      if (seconds <= 0) {
        timer.cancel();
        _recalculateNextPrayer();
      } else {
        remainingTime = _formatSecondsToHHMM(seconds);
        notifyListeners();
      }
    });
  }

  void _recalculateNextPrayer() async {
    await _getCurrentPrayer();
    await _calculateCurrentTimeWithPrayerTime();
    _countDownPrayer();
  }

  String _formatSecondsToHHMM(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final second = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$second';
  }
}
