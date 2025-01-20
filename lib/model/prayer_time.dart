class PrayerTimeModel {
  String name;
  String time;
  bool isNextPrayer;

  PrayerTimeModel({
    required this.name,
    required this.time,
    this.isNextPrayer = false,
  });
}