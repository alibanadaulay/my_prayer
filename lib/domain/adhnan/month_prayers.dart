import 'package:my_prayer/common/adhan_dio.dart';

class GetMonthPrayer {
  final AdhanClientDio _adhanClientDio;

  GetMonthPrayer(this._adhanClientDio);

  Future<void> getMonthPrayer(String country, String isoCoutry) async {
    DateTime today = DateTime.now();
    String adhanUrl =
        "calendarByCity/${today.year}/${today.month}?city=$country&country=$isoCoutry&method=3&shafaq=general";
    _adhanClientDio.dio.get(adhanUrl);
  }
}
