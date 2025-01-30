class PrayerTimeModel {
  int id;
  String name;
  String time;
  bool isNextPrayer;
  bool isSound;

  PrayerTimeModel({
    required this.id,
    required this.name,
    required this.time,
    this.isSound = false,
    this.isNextPrayer = false,
  });
}
