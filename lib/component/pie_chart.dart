import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:self_made_app/DataSource/MoneySource.dart';

class MyPieChart extends StatefulWidget {
  final DateTime selectedDate;
  const MyPieChart({super.key,required this.selectedDate});
  @override
  State<MyPieChart> createState() => _MyPieChartState();
}

class _MyPieChartState extends State<MyPieChart>{
late DateTime selectedDate;

@override
void initState(){
  super.initState();
}

@override
void dispose(){
  super.dispose();
}
  
@override
Widget build(BuildContext context) {
  selectedDate = widget.selectedDate;
  final List<double> consumeOnMonth = MoneySource.instance.TotalCosumeOnMonth(selectedDate);

  if(consumeOnMonth[0] + consumeOnMonth[1] + consumeOnMonth[2] + consumeOnMonth[3] + consumeOnMonth[4] == 0){
    return PieChart(
      PieChartData(sections: [
          PieChartSectionData(
          title: '衣著',
          value: 1,
          color: Colors.blueGrey,
        ),
          PieChartSectionData(
          title: '飲食',
          value: 1,
          color: Colors.redAccent,
        ),
          PieChartSectionData(
          title: '交通',
          value: 1,
          color: Colors.greenAccent,
        ),
          PieChartSectionData(
          title: '娛樂',
          value: 1,
          color: Colors.yellowAccent,
        ),
          PieChartSectionData(
          title: '其他',
          value: 1,
          color: Colors.orangeAccent,
        ),

        ]
      ),
  );
    

  }

  return PieChart(
      PieChartData(sections: [
          PieChartSectionData(
          title: '衣著',
          value: consumeOnMonth[0],
          color: Colors.blueGrey,
        ),
          PieChartSectionData(
          title: '飲食',
          value: consumeOnMonth[1],
          color: Colors.redAccent,
        ),
          PieChartSectionData(
          title: '交通',
          value: consumeOnMonth[2],
          color: Colors.greenAccent,
        ),
          PieChartSectionData(
          title: '娛樂',
          value: consumeOnMonth[3],
          color: Colors.yellowAccent,
        ),
          PieChartSectionData(
          title: '其他',
          value: consumeOnMonth[4],
          color: Colors.orangeAccent,
        ),

        ]
      ),
  );
}

}