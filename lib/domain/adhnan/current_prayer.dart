import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_prayer/model/prayer_time.dart';


class GetCurrentPrayerUseCases{

  Future<PrayerTimeModel> getCurrentPrayer(List<PrayerTimeModel> prayers) async{
  TimeOfDay now = TimeOfDay.now();
  Logger().d(now);

  for(int i = 0 ; i < 5; i++){

  PrayerTimeModel targetTime = prayers[i];
     TimeOfDay target = TimeOfDay(
    hour: int.parse(targetTime.time.split(":")[0]),
    minute: int.parse(targetTime.time.split(":")[1]),
  );
    Logger().d(targetTime);


  if(target.hour > now.hour || (target.hour == now.hour && target.minute > now.minute)){
    return targetTime;
  }
  }

  return prayers.first;

  }
}