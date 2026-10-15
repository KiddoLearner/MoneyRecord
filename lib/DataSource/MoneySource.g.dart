// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MoneySource.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoneyDataAdapter extends TypeAdapter<MoneyData> {
  @override
  final int typeId = 1;

  @override
  MoneyData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoneyData(
      typeCost: fields[0] as String,
      nameCost: fields[2] as String,
      amountCost: fields[3] as double,
      dateCost: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MoneyData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.typeCost)
      ..writeByte(2)
      ..write(obj.nameCost)
      ..writeByte(3)
      ..write(obj.amountCost)
      ..writeByte(4)
      ..write(obj.dateCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoneyDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
