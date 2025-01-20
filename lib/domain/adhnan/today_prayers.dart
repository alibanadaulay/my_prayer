import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_prayer/model/json/prayer_time_response.dart';
import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/utils/connection_utils.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class GetTodayPrayer{

  final Dio _dio = Dio();
  final PermissionUtils _permissionUtils = PermissionUtils();
  final ConnectionUtils connectionUtil = ConnectionUtils();

  Position? _position;
  String _date = "";
  String _country = "";
  String _isoCoutry = "";


  Future<List<PrayerTimeModel>> getTodayPrayer(String country, String isCountryCode) async{
    Position? position = await _permissionUtils.getCurrentPosition();
    if(position == null){
      return [];
    }
    _position = position;
    _date = DateFormat('DD-MM-YYYY ').format(DateTime.now());
    _country = country;
    _isoCoutry = isCountryCode;


    if(await connectionUtil.getConnection()){
      return _getPrayersFromRemote();
    } else {
      return _getPrayersFromLocal();
    }
  
  } 

  Future<List<PrayerTimeModel>> _getPrayersFromLocal() async{
      Map<String, DateTime> todayPrayer = {};
      List<PrayerTimeModel> list = [];
      bool isNextPrayerFound = false;

      final params = CalculationMethod.umm_al_qura.getParameters();
      params.madhab = Madhab.shafi;
      final prayerTimes = PrayerTimes.today(Coordinates(_position!.latitude, _position!.longitude), params);

    todayPrayer["Subuh"] = prayerTimes.fajr;
    todayPrayer["Sunrise"] = prayerTimes.sunrise;
    todayPrayer["Dzuhur"] = prayerTimes.dhuhr;
    todayPrayer["Ashar"] = prayerTimes.asr;
    todayPrayer["Maghrib"] = prayerTimes.maghrib;
    todayPrayer["Isha"] = prayerTimes.isha;


     for (var entry in todayPrayer.entries) {
      if(!isNextPrayerFound){
        isNextPrayerFound = entry.value.isAfter(DateTime.now());
      }

      list.add(PrayerTimeModel(
          name: entry.key,
          time: DateFormat('HH:mm').format(entry.value),
          isNextPrayer: isNextPrayerFound));
    }
    return list;
  }

  Future<List<PrayerTimeModel>> _getPrayersFromRemote( ) async{
    List<PrayerTimeModel> list = [];
    String baseUrl = "https://api.aladhan.com/v1";
    String adhanUrl = "$baseUrl/timingsByCity/$_date?city=$_country&country=$_isoCoutry&method=3&shafaq=general";
    final  response  = await _dio.get(adhanUrl);
    PrayerTimesResponse prayerTime = PrayerTimesResponse.fromJson(response.data);

    Logger().d(adhanUrl);

    list.add(PrayerTimeModel(name: "Subuh", time: prayerTime.data.timings.Fajr));
    list.add(PrayerTimeModel(name: "Sunrise", time: prayerTime.data.timings.Sunrise));
    list.add(PrayerTimeModel(name: "Dzuhur", time: prayerTime.data.timings.Dhuhr));
    list.add(PrayerTimeModel(name: "Ashar", time: prayerTime.data.timings.Asr));
    list.add(PrayerTimeModel(name: "Maghrib", time: prayerTime.data.timings.Maghrib));
    list.add(PrayerTimeModel(name: "Isha", time: prayerTime.data.timings.Isha));
    Logger().d(list);

    return list;
  }
  
}