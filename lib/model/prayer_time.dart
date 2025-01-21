class PrayerTimeModel {
  int id;
  String name;
  String time;
  bool isNextPrayer;

  PrayerTimeModel({
    required this.id,
    required this.name,
    required this.time,
    this.isNextPrayer = false,
  });
}
