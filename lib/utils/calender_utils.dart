import 'package:hijri/hijri_calendar.dart';

class CalenderUtils {
  static Future<String> getHijriDate(String? time) async {
    HijriCalendar todayHijri = HijriCalendar.now();

    DateTime now = DateTime.now();
    if (time == null) {
      return todayHijri.toFormat("dd MM yyyy");
    }
    List<String> parts = time.split(':');
    DateTime maghribTime = DateTime(
        now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));

    if (now.isAfter(maghribTime)) {
      todayHijri = HijriCalendar.fromDate(now.add(Duration(days: 1)));
    }
    return todayHijri.toFormat("dd MMMM yyyy");
  }
}
