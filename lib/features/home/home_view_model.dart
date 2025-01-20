import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:my_prayer/domain/adhnan/today_prayers.dart';
import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:geolocator/geolocator.dart';



class HomeViewModel extends ChangeNotifier {
  String locationName = " ";
  String arabicDate = "28 Rabiul Awwal 1445 H";
  String date = "Senin , 28 Maret 2022";
  String remainingTime = "05:23";
  String timePrayer = "17:21";
  String currenPrayer = "Maghrib";
  int seconds = 0;
  List<PrayerTimeModel> prayerTimes = [];
  String? _isoCountryCode = "";
  Placemark? _placemark;


  final PermissionUtils _permissionUtils;
  final GetTodayPrayer _todayPrayer;

  HomeViewModel(this._permissionUtils, this._todayPrayer);



  void init() async {
    Logger().i("init called");
   

    arabicDate = HijriCalendar.now().toFormat("dd MM yyyy");
    await _setLocationName("");
    await _getTodayPrayer();

    countDownPrayer();
  }

  Future<void> _getTodayPrayer() async {
  List<PrayerTimeModel>? temp = await _todayPrayer.getTodayPrayer(locationName,  _isoCountryCode ?? "-");
   if(temp != null){
      prayerTimes = temp;
      notifyListeners();
   }
  Logger().d(temp);
  }

  void setNewLocation(String name){
    _setLocationName(name);
  }

  Future<void> _setLocationName(String name) async{
    if (name.isEmpty) {
      Position? result = await _permissionUtils.getCurrentPosition();
      Logger().i(result);
      if(result == null){
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
    _placemark =  await _permissionUtils.getCityName(position);
    locationName = _placemark!.locality ?? "";
    _isoCountryCode = _placemark!.isoCountryCode;
  }


  void countDownPrayer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      if (seconds < 0) {
        timer.cancel();
        countDownPrayer();
      } else {
        remainingTime = formatSecondsToHHMM(seconds);
        notifyListeners();
      }
    });
  }

  int calculateSecondsToTargetTime(DateTime prayer) {
    final now = DateTime.now(); // Get the current time
    return prayer.difference(now).inSeconds;
  }

  DateTime getSecondFromPrayerTime(int hour, int minute, int second) {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute, second);
  }

  String formatSecondsToHHMM(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final second = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$second';
  }
}