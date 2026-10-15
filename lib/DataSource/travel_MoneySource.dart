import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:self_made_app/Boxes/box_money.dart';
part 'travel_MoneySource.g.dart';

class TravelMoneySource {
  static const String selfName = "我";
  List<String> _normalizePartners(List<String>? partners){
    final rawList = partners ?? const [];
    final cleaned = rawList.map((e)=> e.trim()).where((e)=>e.isNotEmpty).toList();
    final seen = <String>{};
    final uniqueList = <String>[];

    //Make sure "我" at the first place
    uniqueList.add(selfName);
    seen.add(selfName);

    for(final name in cleaned){
      if(!seen.contains(name)){
        uniqueList.add(name);
        seen.add(name);
      }
    }
    return uniqueList;
  }
  
  Future<int> createTravelMoneyData(String name, DateTime startDate, DateTime endDate, String place, List<String>? partners, {String currency = "HKD", double rate = 1.0}) async{
    //final partList = partners ?? const [];
    final partList = _normalizePartners(partners);
    //late int keyNumber;

    TravelMoneyData data = TravelMoneyData(nameOfTrip: name, startDateOfTrip: startDate, endDateOfTrip: endDate, placeOfTrip: place, partnersOfTrip: partList, currency: currency, rate: rate,);
    //Save to hive
    return await TravelboxMoneyData.add(data);

    //Debug用
    // print("Trip:  " + "Trip name:" + data.nameOfTrip + " - Place: "+ data.placeOfTrip + " - Date: "+data.dateOfTrip.start.toString() + " - " + data.dateOfTrip.end.toString() + " - Partners: " + data.partnersOfTrip.toString());
  }

  Future<void> fixAllOldTravelData() async {
    for (int i = 0; i < TravelboxMoneyData.length; i++) {
      final trip = TravelboxMoneyData.getAt(i);
      if (trip == null) continue;

      bool changed = false;

      trip.partnersOfTrip ??= [];
      if (!trip.partnersOfTrip!.contains("我")) {
        trip.partnersOfTrip!.insert(0, "我");
        changed = true;
      }

      for (final record in trip.travelMoneyRecords) {
        record.separateCost.putIfAbsent(
          "我",
          () => PaidMoney(amountPaid: 0),
        );
      }

      if (changed) {
        await TravelboxMoneyData.putAt(i, trip);
      }
    }
  }

  
}

@HiveType(typeId: 4)
class PaidMoney{
  @HiveField(0) double amountPaid;
  @HiveField(1) bool isPaid;

  PaidMoney({
    required this.amountPaid,
    this.isPaid = false,
  });

  //JSON file setting for packing and unpacking the data
  Map<String, dynamic> toJson() { //Packing data by using JSON
    return {
      'amountPaid': amountPaid,
      'isPaid': isPaid,
    };
  }

  factory PaidMoney.fromJson(Map<String, dynamic> json) { //Unpacking data from JSON
    return PaidMoney(
      amountPaid: (json['amountPaid'] as num).toDouble(),
      isPaid: json['isPaid'] ?? false,
    );
  }
}


@HiveType(typeId: 3)
class TravelMoneyRecord{
  @HiveField(0) String typeCost;
  @HiveField(1) String nameCost;
  @HiveField(2) double amountCost;
  @HiveField(3) DateTime dateCost;
  @HiveField(4) Map<String, PaidMoney> separateCost;
  @HiveField(5, defaultValue: "HKD") String currency;
  @HiveField(6, defaultValue: "我") String whoPaid;

  TravelMoneyRecord({
    required this.typeCost,
    required this.nameCost,
    required this.amountCost,
    required this.dateCost,
    required this.separateCost,
    this.currency = "HKD",
    this.whoPaid = "我",
  });

  //JSON file setting for packing and unpacking the data
  Map<String, dynamic> toJson() { //Packing data by using JSON
    return {
      'typeCost': typeCost,
      'nameCost': nameCost,
      'amountCost': amountCost,
      'dateCost': dateCost.toIso8601String(),
      'separateCost': separateCost.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'currency': currency,
      'whoPaid': whoPaid
    };
  }

  factory TravelMoneyRecord.fromJson(Map<String, dynamic> json) { //Unpacking data from JSON
    final rawSeparate = Map<String, dynamic>.from(json['separateCost'] ?? {});

    return TravelMoneyRecord(
      typeCost: json['typeCost'],
      nameCost: json['nameCost'],
      amountCost: (json['amountCost'] as num).toDouble(),
      dateCost: DateTime.parse(json['dateCost']),
      separateCost: rawSeparate.map(
        (key, value) => MapEntry(
          key,
          PaidMoney.fromJson(Map<String, dynamic>.from(value)),
        ),
      ),
      currency: json['currency'] ?? 'HKD',
      whoPaid: json['whoPaid'] ?? '我'
    );
  }
}

@HiveType(typeId: 2)
class TravelMoneyData{
  @HiveField(0) String nameOfTrip;
  @HiveField(1) DateTime startDateOfTrip;
  @HiveField(2) DateTime endDateOfTrip;
  @HiveField(3) String placeOfTrip;
  @HiveField(4, defaultValue: const ["我"]) List<String> partnersOfTrip;
  @HiveField(5) List<TravelMoneyRecord> travelMoneyRecords;
  @HiveField(6, defaultValue: "HKD") String currency;
  @HiveField(7, defaultValue: 1.0) double rate;

  TravelMoneyData({
    required this.nameOfTrip,
    required this.startDateOfTrip,
    required this.endDateOfTrip,
    required this.placeOfTrip,
    this.partnersOfTrip = const ["我"],
    this.travelMoneyRecords = const [],
    this.currency = "HKD",
    this.rate = 1.0,
  });

  //JSON file setting for packing and unpacking the data
  Map<String, dynamic> toJson() { //Packing data by using JSON
    return {
      'nameOfTrip': nameOfTrip,
      'startDateOfTrip': startDateOfTrip.toIso8601String(),
      'endDateOfTrip': endDateOfTrip.toIso8601String(),
      'placeOfTrip': placeOfTrip,
      'partnersOfTrip': partnersOfTrip ?? [],
      'travelMoneyRecords': travelMoneyRecords.map((e) => e.toJson()).toList(),
      'currency': currency,
      'rate': rate,
    };
  }

  factory TravelMoneyData.fromJson(Map<String, dynamic> json) { //Unpacking data from JSON
    final rawRecords = (json['travelMoneyRecords'] as List? ?? []);
    final rawPartners = (json['partnersOfTrip'] as List? ?? []).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    final seen = <String>[];
    final normalizedPartners = <String>["我"];
    seen.add("我");
    for (final name in rawPartners) {
      if (!seen.contains(name)) {
        normalizedPartners.add(name);
        seen.add(name);
      }
    }

    return TravelMoneyData(
      nameOfTrip: json['nameOfTrip'],
      startDateOfTrip: DateTime.parse(json['startDateOfTrip']),
      endDateOfTrip: DateTime.parse(json['endDateOfTrip']),
      placeOfTrip: json['placeOfTrip'],
      partnersOfTrip: normalizedPartners,
      //(json['partnersOfTrip'] as List? ?? []).map((e) => e.toString()).toList(),
      travelMoneyRecords: rawRecords
      .map((e) => TravelMoneyRecord.fromJson(Map<String, dynamic>.from(e)))
      .toList(),
      currency: json['currency'] ?? 'HKD',
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

