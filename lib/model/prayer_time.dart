class PrayerTimeModel {
  int id;
  String name;
  String time;
  String date;
  bool isNextPrayer;
  bool isSound;

  PrayerTimeModel({
    required this.id,
    required this.name,
    required this.time,
    required this.date,
    this.isSound = false,
    this.isNextPrayer = false,
  });
}
