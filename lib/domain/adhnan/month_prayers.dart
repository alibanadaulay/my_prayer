import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:my_prayer/common/adhan_dio.dart';
import 'package:my_prayer/model/db/db_config.dart';
import 'package:my_prayer/model/db/prayer_db.dart';
import 'package:my_prayer/model/json/prayer_times_month_response.dart';

class GetMonthPrayer {
  final AdhanClientDio _adhanClientDio;

  late Box<PrayerDb> _box;

  GetMonthPrayer(this._adhanClientDio);

  late DateTime _today;
  String _city = "";
  String _isoCoutry = "";

  Future<void> getMonthPrayer(String city, String isoCoutry) async {
    _today = DateTime.now();
    _city = city;
    _isoCoutry = isoCoutry;
    _box = await Hive.openBox(PRAYER);

    bool result = await checkIfPrayersAvailable();
    if (result) {
      _box.close();
      return;
    }

    await _box.clear();

    String adhanUrl =
        "calendarByCity/${_today.year}/${_today.month}?city=$city&country=$isoCoutry&method=20&shafaq=general";
    final response = await _adhanClientDio.dio.get(adhanUrl);
    PrayerTimesMonthResponse data =
        PrayerTimesMonthResponse.fromJson(response.data);
    await saveMonthPrayer(data);
    _box.close();
  }

  Future<bool> checkIfPrayersAvailable() async {
    final date = DateFormat('dd-MM-yyyy').format(_today);
    PrayerDb? prayerModel = _box.get(date);
    return prayerModel != null && prayerModel.city == _city;
  }

  Future<void> saveMonthPrayer(PrayerTimesMonthResponse data) async {
    for (PrayerTimesMonthResponseData item in data.data) {
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

      await _box.put(item.date.gregorian.date, prayerDb);
    }
  }
}
