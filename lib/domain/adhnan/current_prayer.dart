import 'package:logger/logger.dart';
import 'package:my_prayer/model/prayer_time.dart';

class GetCurrentPrayerUseCases {
  Future<PrayerTimeModel> getCurrentPrayer(
      List<PrayerTimeModel> prayers) async {
    DateTime now = DateTime.now();

    if (prayers.isEmpty) {
      return PrayerTimeModel(id: 0, name: "Subuh", time: "05:00", date: "");
    }

    for (int i = 0; i < prayers.length; i++) {
      PrayerTimeModel targetTime = prayers[i];
      DateTime target = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(targetTime.time.split(":")[0]),
        int.parse(targetTime.time.split(":")[1]),
      );
      Logger().d("$now $target ${targetTime.name} ${prayers.length}");

      if (target.hour > now.hour ||
          (target.hour == now.hour && target.minute > now.minute)) {
        return targetTime;
      }
    }

    return prayers.last;
  }
}
