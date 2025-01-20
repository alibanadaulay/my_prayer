import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_prayer/common/dio.dart';
import 'package:my_prayer/model/json/prayer_time_response.dart';

class GetTodayPrayer{

  Dio dio = Dio();
// final DioClient _dioClient;

  // GetTodayPrayer(this._dioClient);

  Future<Timings> getTodayPrayer(Position position, String date) async{
    String baseUrl = dotenv.env["ADHNAN_URL"] ?? "";
    String adhanUrl = "$baseUrl/nextPrayer/$date?latitude=${position.latitude}&${position.longitude}&method=3&shafaq=general&tune=5%2C3%2C5%2C7%2C9%2C-1%2C0%2C8%2C-6&timezonestring=UTC&calendarMethod=UAQ";
    final  response  = await dio.get(adhanUrl);
    PrayerTimesResponse prayerTime = PrayerTimesResponse.fromJson(response.data);
    return prayerTime.data.timings;
    // return;
  }
}