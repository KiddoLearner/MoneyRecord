

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:self_made_app/Boxes/box_money.dart';
part 'MoneySource.g.dart';


class MoneySource {
  //final money_record_box = Hive.box('MoneySource');

  static final MoneySource instance = MoneySource._internal(); // 唯一實例
  MoneySource._internal(); // 私有建構函數，只能自己 class 用
  List<MoneyData> MoneyDataSource = [];
  List<double> get TypesMoney => [
    /* 衣著 */ boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '衣著').fold(0.0, (sum, item) => sum + item.amountCost),
    /* 飲食 */ boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '飲食').fold(0.0, (sum, item) => sum + item.amountCost),
    /* 交通 */ boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '交通').fold(0.0, (sum, item) => sum + item.amountCost),
    /* 娛樂 */ boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '娛樂').fold(0.0, (sum, item) => sum + item.amountCost),
    /* 其他 */ boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '其他').fold(0.0, (sum, item) => sum + item.amountCost),
  ];

  void createMoneyData(String type, String name,double amount, DateTime date){
    MoneyData data = MoneyData(typeCost: type, nameCost: name, amountCost: amount, dateCost: date);
    boxMoneyData.add(data); //Save to hive
    MoneyDataSource.add(data);
    if(date.month == DateTime.now().month && date.year == DateTime.now().year){
      switch(type){
      case '衣著':
       TypesMoney[0] += amount;
      break;
      case '飲食':
        TypesMoney[1] += amount;
      break;
      case '交通':
        TypesMoney[2] += amount;
      break;
      case '娛樂':
        TypesMoney[3] += amount;
      break;
      case '其他':
        TypesMoney[4] += amount;
      break;
    }
    }

    //Debug用
    for (var element in MoneyDataSource) {
      print(element.nameCost + element.amountCost.toString() + element.dateCost.toString()+ element.typeCost);
      print("${MoneyDataSource.length} items in total\nCloths: ${TypesMoney[0]}\nEat: ${TypesMoney[1]}\nTraffic: ${TypesMoney[2]}\nEntertainment: ${TypesMoney[3]}"
      );
    }
  }
  List<double> TotalCosumeOnMonth(DateTime dateNyear){
    return [
    /* 衣著 */boxMoneyData.values.where((item) => item.dateCost.month == dateNyear.month && item.dateCost.year == dateNyear.year && item.typeCost == '衣著').fold(0.0, (sum, item) => sum + item.amountCost),
    /* 飲食 */boxMoneyData.values.where((item) => item.dateCost.month == dateNyear.month && item.dateCost.year == dateNyear.year && item.typeCost == '飲食').fold(0.0, (sum, item) => sum + item.amountCost),
    /* 交通 */boxMoneyData.values.where((item) => item.dateCost.month == dateNyear.month && item.dateCost.year == dateNyear.year && item.typeCost == '交通').fold(0.0, (sum, item) => sum + item.amountCost),
    /* 娛樂 */boxMoneyData.values.where((item) => item.dateCost.month == dateNyear.month && item.dateCost.year == dateNyear.year && item.typeCost == '娛樂').fold(0.0, (sum, item) => sum + item.amountCost),
    /* 其他 */boxMoneyData.values.where((item) => item.dateCost.month == dateNyear.month && item.dateCost.year == dateNyear.year && item.typeCost == '其他').fold(0.0, (sum, item) => sum + item.amountCost)
      ];
  }

  //Call by Detail Page
  void modifyRecord(){
    /* 衣著 */ TypesMoney[0] = boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '衣著').fold(0.0, (sum, item) => sum + item.amountCost);
    /* 飲食 */ TypesMoney[1] = boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '飲食').fold(0.0, (sum, item) => sum + item.amountCost);
    /* 交通 */ TypesMoney[2] = boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '交通').fold(0.0, (sum, item) => sum + item.amountCost);
    /* 娛樂 */ TypesMoney[3] = boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '娛樂').fold(0.0, (sum, item) => sum + item.amountCost);
    /* 其他 */ TypesMoney[4] = boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '其他').fold(0.0, (sum, item) => sum + item.amountCost);
    
}

}



@HiveType(typeId: 1)
class MoneyData{
  @HiveField(0)
  String typeCost; 

  @HiveField(2)
  String nameCost;
  
  @HiveField(3)
  double amountCost;

  @HiveField(4)
  DateTime dateCost;

  //Comment for the record added later
  //String Comment;
  MoneyData({required this.typeCost, required this.nameCost, required this.amountCost, required this.dateCost});

  //JSON file setting for packing and unpacking the data
  Map<String, dynamic> toJson() { //For packing the data
    return {
      'typeCost': typeCost,
      'nameCost': nameCost,
      'amountCost': amountCost,
      'dateCost': dateCost.toIso8601String(),
    };
  }

  factory MoneyData.fromJson(Map<String, dynamic> json) { //For unpacking the data
    return MoneyData(
      typeCost: json['typeCost'],
      nameCost: json['nameCost'],
      amountCost: (json['amountCost'] as num).toDouble(),
      dateCost: DateTime.parse(json['dateCost']),
    );
  }

}