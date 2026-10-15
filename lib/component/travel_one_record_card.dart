import 'package:flutter/material.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';
import 'package:self_made_app/component/dialog_record.dart';
import 'package:self_made_app/component/travel_one_record_card_edit.dart';


class TravelOneRecordCard extends StatelessWidget {
  final String type;
  final String name;
  final double amount;
  final String currency;
  final List<String> currencyList;
  final DateTime date;
  final int keyIndex;
  final int listKeyIndex;
  final bool separated;
  final bool allPaid;
  final Map<String, PaidMoney> separatedMap;
  final String whoPiad;

  const TravelOneRecordCard({
    super.key,
    required this.type,
    required this.name,
    required this.amount,
    required this.currency,
    required this.currencyList,
    required this.date,
    required this.keyIndex,
    required this.listKeyIndex,
    required this.separated,
    required this.allPaid,
    required this.separatedMap,
    required this.whoPiad
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(20),
      child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      padding: EdgeInsets.all(20),
      width: 300,
      child: 
      Stack(
        children: [
          Text(
            "種類︰" + type
            + "\n名稱︰" + name
            + "\n金額︰\$" + amount.toString() + "($currency)"
            + "\n日期︰" + date.year.toString()
            + '年' + date.month.toString()
            + '月' + date.day.toString()
            + '日'
            + ((separated && separatedMap.length>1)? "\n誰付︰$whoPiad" : ''),
            ),
          Positioned(
            right: -10,
            bottom: 0,
            child: ElevatedButton(
             
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  shape: CircleBorder(), // 圓形
                  padding: EdgeInsets.all(3),
                  minimumSize: Size(20, 20), // 固定大小
              ),
              child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size:  20,
                ),
              
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (context) =>TravelOneRecordCardEdit(
                    type: type,
                    name: name,
                    amount: amount,
                    currency: currency,
                    currencyList: currencyList,
                    date: date,
                    keyIndex: keyIndex,
                    listKeyIndex: listKeyIndex,
                    separatedMap: separatedMap,
                    whoPaid: whoPiad,
                  ),
                );
              },
          )
          ),

          if(separated && separatedMap.length>1)
          Positioned(
            right: 0,
            top: 0,
            child: allPaid? 
            Icon(Icons.money, color: Colors.green,)
             : Icon(Icons.money,color: Colors.red),
          )
          
        ],
      )
          
            
      ),
    );
  }
}
