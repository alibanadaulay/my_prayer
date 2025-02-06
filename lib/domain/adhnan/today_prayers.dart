import 'package:geolocator/geolocator.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_prayer/common/adhan_dio.dart';
import 'package:my_prayer/model/db/db_config.dart';
import 'package:my_prayer/model/db/prayer_db.dart';
import 'package:my_prayer/model/json/prayer_time_response.dart';
import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/utils/connection_utils.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:my_prayer/utils/prefes_utils.dart';

class GetTodayPrayer {
  final AdhanClientDio _adhanClientDio;
  final PermissionUtils _permissionUtils = PermissionUtils();
  final ConnectionUtils connectionUtil = ConnectionUtils();

  Position? _position;
  String _date = "";
  String _country = "";
  String _isoCoutry = "";

  GetTodayPrayer(this._adhanClientDio);

  Future<List<PrayerTimeModel>> getTodayPrayer(
      String country, String isCountryCode) async {
    Position? position = await _permissionUtils.getCurrentPosition();
    if (position == null) {
      return [];
    }
    _position = position;
    _date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _country = country;
    _isoCoutry = isCountryCode;

    List<PrayerTimeModel> prayerTimesFromDbLocal = await _getFromLocalDb();

    if (prayerTimesFromDbLocal.isNotEmpty) {
      return prayerTimesFromDbLocal;
    }

    if (await connectionUtil.getConnection()) {
      return _getPrayersFromRemote();
    } else {
      return _getPrayersFromLocal();
    }
  }

  Future<List<PrayerTimeModel>> _getPrayersFromLocal() async {
    Map<String, DateTime> todayPrayer = {};
    List<PrayerTimeModel> list = [];
    bool isNextPrayerFound = false;

    final params = CalculationMethod.umm_al_qura.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(
        Coordinates(_position!.latitude, _position!.longitude), params);

    todayPrayer["Subuh"] = prayerTimes.fajr;
    todayPrayer["Sunrise"] = prayerTimes.sunrise;
    todayPrayer["Dzuhur"] = prayerTimes.dhuhr;
    todayPrayer["Ashar"] = prayerTimes.asr;
    todayPrayer["Maghrib"] = prayerTimes.maghrib;
    todayPrayer["Isha"] = prayerTimes.isha;

    int i = 0;
    for (var entry in todayPrayer.entries) {
      if (!isNextPrayerFound) {
        isNextPrayerFound = entry.value.isAfter(DateTime.now());
      }

      list.add(PrayerTimeModel(
          id: i,
          name: entry.key,
          time: DateFormat('HH:mm').format(entry.value),
          isSound: await PrefesUtils.getBool(entry.key),
          date: DateFormat("dd-MM-yyyy").format(DateTime.now()),
          isNextPrayer: isNextPrayerFound));
      i++;
    }
    return list;
  }

  Future<List<PrayerTimeModel>> _getPrayersFromRemote() async {
    List<PrayerTimeModel> list = [];
    String adhanUrl =
        "timingsByCity/$_date?city=$_country&country=$_isoCoutry&method=20&shafaq=general";
    final response = await _adhanClientDio.dio.get(adhanUrl);
    PrayerTimesResponse prayerTime =
        PrayerTimesResponse.fromJson(response.data);

    list.add(PrayerTimeModel(
        isSound: await PrefesUtils.getBool("Subuh"),
        id: 0,
        name: "Subuh",
        date: DateFormat("dd-MM-yyyy").format(DateTime.now()),
        time: prayerTime.data.timings.Fajr));
    list.add(PrayerTimeModel(
        isSound: await PrefesUtils.getBool("Sunrise"),
        id: 1,
        name: "Sunrise",
        date: DateFormat("dd-MM-yyyy").format(DateTime.now()),
        time: prayerTime.data.timings.Sunrise));
    list.add(PrayerTimeModel(
        isSound: await PrefesUtils.getBool("Dzuhur"),
        id: 2,
        name: "Dzuhur",
        date: DateFormat("dd-MM-yyyy").format(DateTime.now()),
        time: prayerTime.data.timings.Dhuhr));
    list.add(PrayerTimeModel(
        isSound: await PrefesUtils.getBool("Ashar"),
        id: 3,
        name: "Ashar",
        date: DateFormat("dd-MM-yyyy").format(DateTime.now()),
        time: prayerTime.data.timings.Asr));
    list.add(PrayerTimeModel(
        isSound: await PrefesUtils.getBool("Maghrib"),
        id: 4,
        name: "Maghrib",
        date: DateFormat("dd-MM-yyyy").format(DateTime.now()),
        time: prayerTime.data.timings.Maghrib));
    list.add(PrayerTimeModel(
        isSound: await PrefesUtils.getBool("Isha"),
        id: 5,
        name: "Isha",
        date: DateFormat("dd-MM-yyyy").format(DateTime.now()),
        time: prayerTime.data.timings.Isha));

    return list;
  }

  Future<List<PrayerTimeModel>> _getFromLocalDb() async {
    final date = DateTime.now();

    Box<PrayerDb> box = await Hive.openBox(PRAYER);
    PrayerDb? prayerDb = box.get(DateFormat('dd-MM-yyyy').format(date));
    if (prayerDb != null) {
      List<PrayerTimeModel> prayerTimes = [];
      for (PrayerModel timeModel in prayerDb.prayersModel) {
        prayerTimes.add(PrayerTimeModel(
            id: timeModel.id,
            date: prayerDb.date,
            isSound: await PrefesUtils.getBool(timeModel.prayerName),
            name: timeModel.prayerName,
            time: timeModel.prayerTime.replaceAll(RegExp(r" \([^)]+\)"), "")));
      }
      box.close();
      return prayerTimes;
    }

    return [];
  }
}
