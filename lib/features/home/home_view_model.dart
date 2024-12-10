import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  String locationName = "Pesanggrahan, Jakarta Selatan";
  String arabicDate = "28 Rabiul Awwal 1445 H";
  String date = "Senin , 28 Maret 2022";
  String remainingTime = "05:23";
  String timePrayer = "17:21";
  String currenPrayer = "Maghrib";
  int seconds = 0;
  Map<String, DateTime> todayPrayer = {};
  List<PrayerTime> prayerTimes = [];

  void init() {
    getTodayPrayer();
    getNextPrayer();
    countDownPrayer();
  }

  void setLocationName(String name) {
    if (name.isEmpty) {
      locationName = "Mampang, Jakarta Selatan";
      notifyListeners();
      return;
    }
    locationName = name;
    notifyListeners();
  }

  void countDownPrayer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      if (seconds < 0) {
        timer.cancel();
        getNextPrayer();
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

  void getTodayPrayer() {
    final myCoordinates = Coordinates(-6.245945250734133,
        106.82569952953673); // Replace with your own location lat, lng.
    final params = CalculationMethod.umm_al_qura.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    todayPrayer["Subuh"] = prayerTimes.fajr;
    todayPrayer["Sunrise"] = prayerTimes.sunrise;
    todayPrayer["Dzuhur"] = prayerTimes.dhuhr;
    todayPrayer["Ashar"] = prayerTimes.asr;
    todayPrayer["Maghrib"] = prayerTimes.maghrib;
    todayPrayer["Isha"] = prayerTimes.isha;
  }

  void getNextPrayer() {
    if (todayPrayer.isEmpty) {
      getTodayPrayer();
    }

    DateTime now = DateTime.now();

    String? nextPrayerName;
    DateTime? nextPrayerTime;

    for (var entry in todayPrayer.entries) {
      if (entry.value.isAfter(now)) {
        nextPrayerName = entry.key;
        nextPrayerTime = entry.value;
        break;
      }
    }
    currenPrayer = nextPrayerName!;
    timePrayer = DateFormat('HH:mm').format(nextPrayerTime!);
    seconds = calculateSecondsToTargetTime(nextPrayerTime);

    generateList();
  }

  void generateList() {
    prayerTimes.clear();
    for (var entry in todayPrayer.entries) {
      prayerTimes.add(PrayerTime(
          name: entry.key,
          time: DateFormat('HH:mm').format(entry.value),
          isNextPrayer: entry.key == currenPrayer));
    }
  }
}

class PrayerTime {
  String name;
  String time;
  bool isNextPrayer;

  PrayerTime({
    required this.name,
    required this.time,
    this.isNextPrayer = false,
  });
}
