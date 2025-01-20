import 'package:json_annotation/json_annotation.dart';

part 'prayer_time_response.g.dart'; 

@JsonSerializable()
class PrayerTimesResponse {
  final int code;
  final String status;
  final Data data;

  PrayerTimesResponse({required this.code, required this.status, required this.data});

  factory PrayerTimesResponse.fromJson(Map<String, dynamic> json) => _$PrayerTimesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PrayerTimesResponseToJson(this);
}

@JsonSerializable()
class Data {
  final Timings timings;
  // final Date date;
  // final Meta meta;

  Data({required this.timings});

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

  factory Timings.fromJson(Map<String, dynamic> json) => _$TimingsFromJson(json);
  Map<String, dynamic> toJson() => _$TimingsToJson(this);
}