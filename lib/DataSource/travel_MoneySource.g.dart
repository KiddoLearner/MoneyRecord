// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_MoneySource.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaidMoneyAdapter extends TypeAdapter<PaidMoney> {
  @override
  final int typeId = 4;

  @override
  PaidMoney read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaidMoney(
      amountPaid: fields[0] as double,
      isPaid: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PaidMoney obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.amountPaid)
      ..writeByte(1)
      ..write(obj.isPaid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaidMoneyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TravelMoneyRecordAdapter extends TypeAdapter<TravelMoneyRecord> {
  @override
  final int typeId = 3;

  @override
  TravelMoneyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TravelMoneyRecord(
      typeCost: fields[0] as String,
      nameCost: fields[1] as String,
      amountCost: fields[2] as double,
      dateCost: fields[3] as DateTime,
      separateCost: (fields[4] as Map).cast<String, PaidMoney>(),
      currency: fields[5] == null ? 'HKD' : fields[5] as String,
      whoPaid: fields[6] == null ? '我' : fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TravelMoneyRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.typeCost)
      ..writeByte(1)
      ..write(obj.nameCost)
      ..writeByte(2)
      ..write(obj.amountCost)
      ..writeByte(3)
      ..write(obj.dateCost)
      ..writeByte(4)
      ..write(obj.separateCost)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.whoPaid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelMoneyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TravelMoneyDataAdapter extends TypeAdapter<TravelMoneyData> {
  @override
  final int typeId = 2;

  @override
  TravelMoneyData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TravelMoneyData(
      nameOfTrip: fields[0] as String,
      startDateOfTrip: fields[1] as DateTime,
      endDateOfTrip: fields[2] as DateTime,
      placeOfTrip: fields[3] as String,
      partnersOfTrip:
          fields[4] == null ? ['我'] : (fields[4] as List).cast<String>(),
      travelMoneyRecords: (fields[5] as List).cast<TravelMoneyRecord>(),
      currency: fields[6] == null ? 'HKD' : fields[6] as String,
      rate: fields[7] == null ? 1.0 : fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TravelMoneyData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.nameOfTrip)
      ..writeByte(1)
      ..write(obj.startDateOfTrip)
      ..writeByte(2)
      ..write(obj.endDateOfTrip)
      ..writeByte(3)
      ..write(obj.placeOfTrip)
      ..writeByte(4)
      ..write(obj.partnersOfTrip)
      ..writeByte(5)
      ..write(obj.travelMoneyRecords)
      ..writeByte(6)
      ..write(obj.currency)
      ..writeByte(7)
      ..write(obj.rate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelMoneyDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
