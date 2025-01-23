import 'package:json_annotation/json_annotation.dart';

part 'prayer_times_month_response.g.dart';

@JsonSerializable()
class PrayerTimesMonthResponse {
  final int code;
  final String status;
  final List<Data> data;

  PrayerTimesMonthResponse(
      {required this.code, required this.status, required this.data});

  factory PrayerTimesMonthResponse.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimesMonthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PrayerTimesMonthResponseToJson(this);
}

@JsonSerializable()
class Data {
  final Timings timings;
  final DateModel date;

  Data({required this.timings, required this.date});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
  Map<String, dynamic> toJson() => _$DataToJson(this);
}

// Timings class
@JsonSerializable()
class Timings {
  final String Fajr;
  final String Sunrise;
  final String Dhuhr;
  final String Asr;
  final String Sunset;
  final String Maghrib;
  final String Isha;
  final String Imsak;
  final String Midnight;
  final String Firstthird;
  final String Lastthird;

  Timings({
    required this.Fajr,
    required this.Sunrise,
    required this.Dhuhr,
    required this.Asr,
    required this.Sunset,
    required this.Maghrib,
    required this.Isha,
    required this.Imsak,
    required this.Midnight,
    required this.Firstthird,
    required this.Lastthird,
  });

  factory Timings.fromJson(Map<String, dynamic> json) =>
      _$TimingsFromJson(json);
  Map<String, dynamic> toJson() => _$TimingsToJson(this);
}

@JsonSerializable()
class DateModel {
  // final String readable;
  // final int timestamp;
  final Gregorian gregorian;
  final Hijri hijri;

  DateModel({
    // required this.readable,
    // required this.timestamp,
    required this.gregorian,
    required this.hijri,
  });

  factory DateModel.fromJson(Map<String, dynamic> json) =>
      _$DateModelFromJson(json);

  Map<String, dynamic> toJson() => _$DateModelToJson(this);
}

@JsonSerializable()
class Gregorian {
  final String date;
  final String format;
  final String day;
  // final Weekday weekday;
  // final Month month;
  final String year;
  // final Designation designation;
  final bool lunarSighting;

  Gregorian({
    required this.date,
    required this.format,
    required this.day,
    // required this.weekday,
    // required this.month,
    required this.year,
    // required this.designation,
    required this.lunarSighting,
  });

  factory Gregorian.fromJson(Map<String, dynamic> json) =>
      _$GregorianFromJson(json);

  Map<String, dynamic> toJson() => _$GregorianToJson(this);
}

@JsonSerializable()
class Hijri {
  final String date;
  final String format;
  final String day;
  // final Weekday weekday;
  // final Month month;
  final String year;
  // final Designation designation;
  final List<String> holidays;
  final List<dynamic> adjustedHolidays; // Adjust if you know the data type.
  final String method;

  Hijri({
    required this.date,
    required this.format,
    required this.day,
    // required this.weekday,
    // required this.month,
    required this.year,
    // required this.designation,
    required this.holidays,
    required this.adjustedHolidays,
    required this.method,
  });

  factory Hijri.fromJson(Map<String, dynamic> json) => _$HijriFromJson(json);

  Map<String, dynamic> toJson() => _$HijriToJson(this);
}
