import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:self_made_app/DataSource/MoneySource.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';
import 'package:self_made_app/common_use/common_use.dart';

import '../Boxes/box_money.dart';

class TravelCardOfDetailRecord extends StatefulWidget {
  final Color colorCard;
  final String typeCard;
  final DateTimeRange dateRange;
  final List<TravelMoneyRecord> records;
  const TravelCardOfDetailRecord({super.key,required this.colorCard, required this.typeCard,required this.dateRange, required this.records});

  @override
  _CardOfDetailRecordState createState() => _CardOfDetailRecordState();
}

class _CardOfDetailRecordState extends State<TravelCardOfDetailRecord> {

  bool checkDateRange(DateTimeRange dateRange, DateTime dateToCheck){
    return dateToCheck.isAfter(dateRange.start.subtract(const Duration(days: 1))) && dateToCheck.isBefore(dateRange.end.add(const Duration(days: 1)));
  }

  AutoSizeText autoSizeText(String text,{double size = 14,TextStyle textStyle = const TextStyle(),int maxLine = 1}){
    return AutoSizeText(
      text,
      style: textStyle.copyWith(
        //color: Colors.black,
        fontSize: size
      ),
      minFontSize: 14,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsToShow = widget.records
      .where((item) => 
        //checkDateRange(widget.dateRange, item.dateCost) &&
        item.typeCost == widget.typeCard
      )
      .cast<TravelMoneyRecord>()
      .toList();
    return Card(
      color: widget.colorCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Center(
        child: Column(
          children: [
            ListTile(
              leading: Icon(typeIcon(widget.typeCard)),
              //leading: Icon(Icons.monetization_on),
              title: autoSizeText(widget.typeCard, size: 20,textStyle: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: autoSizeText('期間支出總額︰'),
              trailing: AutoSizeText(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //fontSize: 20,
                ),
                minFontSize: 20,
                maxLines: 1,
                stepGranularity: 1, // 每次縮細嘅幅度
                overflow: TextOverflow.ellipsis,
                '\$${moneyUnitChange(itemsToShow.where((item) => item.typeCost == widget.typeCard).fold(0.0, (sum, item) => sum + item.amountCost))}'),
              //trailing: Text('\$100'),
              
            ),
        
            if(itemsToShow.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(child: autoSizeText('本期最多支出的項目為︰',size: 16)),
                  Expanded(
                    child: AutoSizeText(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16
                        ),
                      minFontSize: 10,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      itemsToShow.reduce((curr, next) => curr.amountCost > next.amountCost ? curr : next).nameCost
                    ),
                  )
                ],
              ),
            )
            else
            Column(
              children: [
                Icon(Icons.wallet, size: 50, color: Colors.black,),
                autoSizeText(
                  '暫無該類別支出紀錄',
                  size: 30,
                  textStyle: TextStyle(
                    color: Colors.black
                  ),
                ),
              ],
            ),
            if(itemsToShow.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0,top: 10, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(child: autoSizeText('該支出用了︰',size: 16)),
                  Expanded(
                    child: AutoSizeText(
                      style: TextStyle(
                        color: Colors.black
                      ),
                      minFontSize: 16,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      '\$${moneyUnitChange(itemsToShow.reduce((curr, next) => curr.amountCost > next.amountCost ? curr : next).amountCost)}'
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//boxMoneyData.values.where((item) => item.dateCost.month == DateTime.now().month && item.dateCost.year == DateTime.now().year && item.typeCost == '衣著').fold(0.0, (sum, item) => sum + item.amountCost),