import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:my_prayer/common/adhan_dio.dart';
import 'package:my_prayer/model/db/prayer_db.dart';
import 'package:my_prayer/model/json/prayer_times_month_response.dart';

class GetMonthPrayer {
  final AdhanClientDio _adhanClientDio;

  late Box<PrayerDb> _box;

  GetMonthPrayer(this._adhanClientDio);

  final _today = DateTime.now();
  String _city = "";
  String _isoCoutry = "";

  Future<void> getMonthPrayer(String city, String isoCoutry) async {
    _city = city;
    _isoCoutry = isoCoutry;
    bool result = await checkIfPrayersAvailable();
    if (result) {
      _box.close();
      return;
    }

    _box.clear();

    String adhanUrl =
        "calendarByCity/${_today.year}/${_today.month}?city=$city&country=$isoCoutry&method=20&shafaq=general";
    final response = await _adhanClientDio.dio.get(adhanUrl);
    PrayerTimesMonthResponse data =
        PrayerTimesMonthResponse.fromJson(response.data);
    await saveMonthPrayer(data);
    _box.close();
  }

  Future<bool> checkIfPrayersAvailable() async {
    _box = await Hive.openBox("prayers");

    for (PrayerDb item in _box.values) {
      if (item.city == _city &&
          item.date == DateFormat("DD-MM-YYYY").format(_today)) {
        return false;
      }
    }
    return false;
  }

  Future<void> saveMonthPrayer(PrayerTimesMonthResponse data) async {
    for (Data item in data.data) {
      List<PrayerModel> prayerModels = [];
      prayerModels.add(PrayerModel(
        id: 0,
        prayerName: "Subuh",
        prayerTime: item.timings.Fajr,
      ));
      prayerModels.add(PrayerModel(
        id: 1,
        prayerName: "Sunrise",
        prayerTime: item.timings.Sunrise,
      ));

      prayerModels.add(PrayerModel(
        id: 2,
        prayerName: "Dzuhur",
        prayerTime: item.timings.Dhuhr,
      ));

      prayerModels.add(PrayerModel(
        id: 3,
        prayerName: "Ashar",
        prayerTime: item.timings.Asr,
      ));

      prayerModels.add(PrayerModel(
        id: 4,
        prayerName: "Maghrib",
        prayerTime: item.timings.Maghrib,
      ));

      prayerModels.add(PrayerModel(
        id: 5,
        prayerName: "Isha",
        prayerTime: item.timings.Isha,
      ));

      PrayerDb prayerDb = PrayerDb(
          date: item.date.gregorian.date,
          city: _city,
          isCountry: _isoCoutry,
          prayersModel: prayerModels);

      _box.add(prayerDb);
    }
  }
}
