import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:self_made_app/DataSource/MoneySource.dart';
import 'package:self_made_app/common_use/common_use.dart';
import 'package:self_made_app/component/bar_data.dart';
import 'dart:math' as math;
import 'package:self_made_app/color_theme/app_color.dart';

class bar_chart extends StatelessWidget{
  final List money;
  const bar_chart({super.key,required this.money});

   @override
  Widget build(BuildContext context) {
    //Colors shortcuts
    final colors = Theme.of(context).colorScheme; 
    final textTheme = Theme.of(context).textTheme; 
    final extra = Theme.of(context).extension<AppExtraColors>()!; 

    final List<Color> barColors = [
    const Color(0xFF607D8B),
    const Color(0xFFFF5252),
    const Color(0xFF69F0AE),
    const Color(0xFFFFFF00),
    const Color(0xFFFFAB40),
  ];
    BarData myBarData = BarData(
      cloths: money[0],
      eat: money[1],
      traffic: money[2],
      entertainment: money[3],
      others: money[4]);
      myBarData.initializeBarData();
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          width: 500,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            //color: Colors.deepOrangeAccent,
            color: extra.summaryCard, 
            border: Border.all(
              color: extra.border, 
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: Column(
              children: [
                Text(
                  "總共消費了\$" + money.fold(0.0, (a,b) => a+b).toStringAsFixed(2), 
                  //style: TextStyle(fontSize: 20),
                  style: textTheme.titleMedium?.copyWith( 
                    color: colors.onSurface,
                    fontSize: 20,
                  ),  
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0,),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.center,
                        rotationQuarterTurns: 1, //horizontal bar chart
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 100,
                            getTitlesWidget: (value, meta){
                              int index = value.toInt();
                              if(index>=0 && index<money.length){
                                return Transform.rotate(
                                    angle: -math.pi/2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "\$${moneyUnitChange(money[index])}",
                                        style: textTheme.bodySmall?.copyWith( 
                                          color: extra.subText,
                                        ),
                                        ),
                                    ),
                                );
                              }
                              return Text('data');
                            },
                            )),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false,reservedSize: 0)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false,reservedSize: 0)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(reservedSize: 40,showTitles: true,getTitlesWidget: (value,meta) =>getBottomTitles(value,meta,context)))
                        ),
                        //maxY: money.cast<double>().reduce(math.max), //change the class to double and find the max number
                        barTouchData: BarTouchData(enabled: false), //熄左個Bar touch show data
                        maxY: (money.cast<double>().fold(0.0, (a,b) => a+b)>0)?money.cast<double>().fold(0.0, (a,b) => a!+b):1,
                        minY: 0,
                        barGroups: myBarData.barData.map((data)=>BarChartGroupData(
                          x: data.x,
                          barRods: [
                            BarChartRodData(
                            toY: data.y,
                            color: barColors[data.x],
                            borderRadius: BorderRadius.circular(30),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              //toY: money.cast<double>().reduce(math.max),
                              toY:(money.cast<double>().fold(0.0, (a,b) => a+b)>0)?money.cast<double>().fold(0.0, (a,b) => a!+b):1,
                              //color: Colors.grey[300],
                              color: extra.border.withOpacity(0.45), 
                            ),
                            
                            ),
                          ],
                          )).toList()
                          ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
}

Widget getBottomTitles(double value, TitleMeta meta, BuildContext context){
  final colors = Theme.of(context).colorScheme;
  final extra = Theme.of(context).extension<AppExtraColors>()!;

  final style = TextStyle(
    // color: Colors.black,
    // fontWeight: FontWeight.w100,
    color: colors.onSurface, 
    fontWeight: FontWeight.w400, 
    fontSize: 14,
  );

  Widget text;
  switch(value.toInt()){
    case 0:
      text = Text('衣著',style: style);
      break;
    case 1:
      text = Text('飲食',style: style);
      break;
    case 2:
      text = Text('交通',style: style);
      break;
    case 3:
      text = Text('娛樂',style: style);
      break;
    case 4:
      text = Text('其他',style: style);
      break;
    default:
      text = Text('',style: style);
  }

  return SideTitleWidget(meta: meta, child: text);
}