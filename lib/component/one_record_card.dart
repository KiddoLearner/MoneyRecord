import 'package:flutter/material.dart';
import 'package:self_made_app/component/dialog_record.dart';
import 'package:self_made_app/color_theme/app_color.dart';


class OneRecordCard extends StatelessWidget {
  final String type;
  final String name;
  final double amount;
  final DateTime date;
  final int keyIndex;

  const OneRecordCard({
    super.key,
    required this.type,
    required this.name,
    required this.amount,
    required this.date,
    required this.keyIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final colors = theme.colorScheme; 
    final extra = theme.extension<AppExtraColors>()!;

    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(20),
      child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        //color: Colors.grey[200],
        color: extra.chart3,
      ),
      padding: EdgeInsets.all(20),
      width: 300,
      child: 
      Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30, bottom: 10), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 讓高度根據內容自適應
              children: [
                Text("種類︰$type"),
                Text("名稱︰$name"),
                Text("金額︰\$${amount.toString()}"),
                Text("日期︰${date.year}年${date.month}月${date.day}日"),
              ],
            ),
          ),
       
        Positioned(
              right: 0,   // 貼齊右邊內邊距
              bottom: 0,  // 貼齊底部內邊距
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.surface,
                  shape: const CircleBorder(), 
                  padding: const EdgeInsets.all(3),
                  minimumSize: const Size(20, 20),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 縮減 Material 預設的外圍點擊熱區，防止擠壓
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DialogRecord(
                      type: type,
                      name: name,
                      amount: amount,
                      date: date,
                      keyIndex: keyIndex,
                    ),
                  );
                },
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            )
          ],
      )
          
            
      ),
    );
  }
}
