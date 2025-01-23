import 'package:hive_ce/hive.dart';

part 'prayer_db.g.dart';

@HiveType(typeId: 0)
class PrayerDb extends HiveObject {
  @HiveField(0)
  final String isCountry;
  @HiveField(1)
  final String city;
  @HiveField(2)
  final String date;
  @HiveField(3)
  final List<PrayerModel> prayersModel;

  PrayerDb(
      {required this.city,
      required this.isCountry,
      required this.date,
      required this.prayersModel});
}

@HiveType(typeId: 1)
class PrayerModel extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String prayerName;
  final String prayerTime;

  PrayerModel(
      {required this.id, required this.prayerName, required this.prayerTime});
}
