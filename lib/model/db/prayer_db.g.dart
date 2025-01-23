// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerDbAdapter extends TypeAdapter<PrayerDb> {
  @override
  final int typeId = 0;

  @override
  PrayerDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerDb(
      fields[1] as String,
      fields[0] as String,
      fields[2] as String,
      (fields[3] as List).cast<PrayerModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, PrayerDb obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isCountry)
      ..writeByte(1)
      ..write(obj.city)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.prayersModel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrayerModelAdapter extends TypeAdapter<PrayerModel> {
  @override
  final int typeId = 1;

  @override
  PrayerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerModel(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.prayerName)
      ..writeByte(1)
      ..write(obj.prayerTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
