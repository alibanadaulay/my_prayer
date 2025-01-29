// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times_month_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrayerTimesMonthResponse _$PrayerTimesMonthResponseFromJson(
        Map<String, dynamic> json) =>
    PrayerTimesMonthResponse(
      code: (json['code'] as num).toInt(),
      status: json['status'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              PrayerTimesMonthResponseData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PrayerTimesMonthResponseToJson(
        PrayerTimesMonthResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'status': instance.status,
      'data': instance.data,
    };

PrayerTimesMonthResponseData _$PrayerTimesMonthResponseDataFromJson(
        Map<String, dynamic> json) =>
    PrayerTimesMonthResponseData(
      timings: Timings.fromJson(json['timings'] as Map<String, dynamic>),
      date: DateModel.fromJson(json['date'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PrayerTimesMonthResponseDataToJson(
        PrayerTimesMonthResponseData instance) =>
    <String, dynamic>{
      'timings': instance.timings,
      'date': instance.date,
    };

Timings _$TimingsFromJson(Map<String, dynamic> json) => Timings(
      Fajr: json['Fajr'] as String,
      Sunrise: json['Sunrise'] as String,
      Dhuhr: json['Dhuhr'] as String,
      Asr: json['Asr'] as String,
      Sunset: json['Sunset'] as String,
      Maghrib: json['Maghrib'] as String,
      Isha: json['Isha'] as String,
      Imsak: json['Imsak'] as String,
      Midnight: json['Midnight'] as String,
      Firstthird: json['Firstthird'] as String,
      Lastthird: json['Lastthird'] as String,
    );

Map<String, dynamic> _$TimingsToJson(Timings instance) => <String, dynamic>{
      'Fajr': instance.Fajr,
      'Sunrise': instance.Sunrise,
      'Dhuhr': instance.Dhuhr,
      'Asr': instance.Asr,
      'Sunset': instance.Sunset,
      'Maghrib': instance.Maghrib,
      'Isha': instance.Isha,
      'Imsak': instance.Imsak,
      'Midnight': instance.Midnight,
      'Firstthird': instance.Firstthird,
      'Lastthird': instance.Lastthird,
    };

DateModel _$DateModelFromJson(Map<String, dynamic> json) => DateModel(
      gregorian: Gregorian.fromJson(json['gregorian'] as Map<String, dynamic>),
      hijri: Hijri.fromJson(json['hijri'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DateModelToJson(DateModel instance) => <String, dynamic>{
      'gregorian': instance.gregorian,
      'hijri': instance.hijri,
    };

Gregorian _$GregorianFromJson(Map<String, dynamic> json) => Gregorian(
      date: json['date'] as String,
      format: json['format'] as String,
      day: json['day'] as String,
      year: json['year'] as String,
      lunarSighting: json['lunarSighting'] as bool,
    );

Map<String, dynamic> _$GregorianToJson(Gregorian instance) => <String, dynamic>{
      'date': instance.date,
      'format': instance.format,
      'day': instance.day,
      'year': instance.year,
      'lunarSighting': instance.lunarSighting,
    };

Hijri _$HijriFromJson(Map<String, dynamic> json) => Hijri(
      date: json['date'] as String,
      format: json['format'] as String,
      day: json['day'] as String,
      year: json['year'] as String,
      holidays:
          (json['holidays'] as List<dynamic>).map((e) => e as String).toList(),
      adjustedHolidays: json['adjustedHolidays'] as List<dynamic>,
      method: json['method'] as String,
    );

Map<String, dynamic> _$HijriToJson(Hijri instance) => <String, dynamic>{
      'date': instance.date,
      'format': instance.format,
      'day': instance.day,
      'year': instance.year,
      'holidays': instance.holidays,
      'adjustedHolidays': instance.adjustedHolidays,
      'method': instance.method,
    };
