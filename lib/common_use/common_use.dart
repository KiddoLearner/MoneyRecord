
// For Money Unit Change in K, M, B
import 'package:flutter/material.dart';

String moneyUnitChange(double money){
  double changedMoney = money/1000;
  switch(changedMoney){
    case >= 1 && < 1000:
    return changedMoney.toStringAsFixed(2) + 'K';
    case >= 1000 && < 1000000:
    return (changedMoney/1000).toStringAsFixed(2) + 'M';
    case >= 1000000:
    return (changedMoney/1000000).toStringAsFixed(2) + 'B';
    default:
    return money.toStringAsFixed(2);
  }
}

/*======Color Cards=======*/
  List<Color> colorsOfCards=[
    Colors.blueGrey,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.yellowAccent,
    Colors.orangeAccent,
  ];
/*===========================*/
/*=======Type of Cards=======*/
  List<String> typesOfCards=[
      '衣著',
      '飲食',
      '交通',
      '娛樂',
      '其他',
    ];
/*===========================*/

IconData typeIcon(String type){
    switch(type){
      case '衣著':
        return Icons.checkroom;
      case '飲食':
        return Icons.restaurant;
      case '交通':
        return Icons.directions_car;
      case '娛樂':
        return Icons.sports_esports;
      case '其他':
        return Icons.category;
      default:
        return Icons.help;
      }
    }

// For Date Range Picker
Future<DateTimeRange?> pickDateRange(BuildContext context, DateTimeRange initialDateRange) async {
  final DateTimeRange? newDateRange = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    //initialDateRange: initialDateRange,
  );
  return newDateRange;
}

Future<DateTime?> showADatePicker(BuildContext context, DateTime initalDateTime) async {
  final DateTime? newDateTime = await showDatePicker(
    context: context,
    //initialDate: DateTime.now(),
    firstDate: DateTime(1900), 
    lastDate: DateTime(2100)
    ).then((value){
      if(value != null){
        return value;
      }
    });
  return newDateTime;
}

//the selected date ONLY For home_page & detail_page to communicate
DateTime date = DateTime.now();
void changeBridgeDate (DateTime monthNyear){
  date = DateTime(monthNyear.year,monthNyear.month,1);
}
