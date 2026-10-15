import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/common_use/common_use.dart';
import 'package:self_made_app/component/drawer.dart';
import 'package:self_made_app/component/pie_chart.dart';
import 'package:self_made_app/component/bar_chart.dart';
import 'package:self_made_app/DataSource/MoneySource.dart';
import 'package:self_made_app/pages/detail_page.dart';
import 'package:self_made_app/pages/money_record_page.dart';
import 'package:self_made_app/color_theme/app_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage>{
  int _selectedPage = 0;
  late String highestSpending = indexOfMax();
  late int maxIndex;

  //Year & Month settings
  DateTime selectedDate = DateTime.now();
  void _showCupertinoDatePicker() {
    DateTime tempDate = selectedDate;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => SafeArea(
        child: ClipRect(
          child: Container(
            height: 140,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.monthYear,
                    initialDateTime: selectedDate,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate;
                    },
                  ),
                ),
                TextButton(
                  child: AutoSizeText('確認',maxLines: 1,minFontSize: 5,),
                  onPressed: () {
                    setState(() {
                      selectedDate = tempDate;
                      changeBridgeDate(selectedDate);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  String indexOfMax(){
    final List<String> typeNames = ['衣著', '飲食', '交通', '娛樂', '其他'];
    maxIndex = MoneySource.instance.TypesMoney.indexWhere(
      (v) => v == MoneySource.instance.TypesMoney.reduce((a, b) => a > b ? a : b)
    );
    return typeNames[maxIndex];
  }

  void _navigateBottomBar(int index){
    setState(() {
      _selectedPage = index;
    });
  }

late StreamSubscription _boxSubscription;

    @override
    void initState() {
      super.initState();

      _boxSubscription = boxMoneyData.watch().listen((event) {
        if(mounted) {
          setState(() {
            highestSpending = indexOfMax();
          });
        }
      });
    }
  
  @override
  void dispose() {
    _boxSubscription.cancel();
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    //color shortcuts
    final colors = Theme.of(context).colorScheme; 
    final textTheme = Theme.of(context).textTheme; 
    final extra = Theme.of(context).extension<AppExtraColors>()!; 

    //MoneySource data
    final List<double> consumeOnMonth = MoneySource.instance.TotalCosumeOnMonth(selectedDate);

    final List<Widget> pages = [
    
    SingleChildScrollView(
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: MaterialButton(
                  onPressed: (){
                    _showCupertinoDatePicker();
                  },
                  color: extra.chart1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                  child: Text(
                        '${selectedDate.year}年${selectedDate.month}月消費統計圖表', 
                        //style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        style: textTheme.titleLarge?.copyWith( 
                          fontWeight: FontWeight.bold,
                        ),
                    ),
                ),
                  //child: Text(DateTime.now().year.toString() + ' - ' + DateTime.now().month.toString() + ' - ' + DateTime.now().day.toString()),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    //color: Colors.blueAccent,
                    color: extra.chart3,
                    border: Border.all(
                      color: extra.border, 
                    ),
                  ),
                  height: 300,
                  width: 500,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (consumeOnMonth[0] + consumeOnMonth[1] + consumeOnMonth[2] + consumeOnMonth[3] + consumeOnMonth[4] == 0) 
                        Text(
                          '本月尚無消費紀錄''\n請點擊下方＋新增消費紀錄', 
                          textAlign: TextAlign.center,
                          //style: TextStyle(
                          style: textTheme.bodyMedium?.copyWith( 
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            //color: Colors.black,
                            color: colors.onSurface,
                            decoration: TextDecoration.underline
                          )
                        )
                      else
                      Text(
                        '本月消費最多在' + highestSpending
                        + "\n該類別佔總消費" 
                        //+ (MoneySource.instance.TypesMoney.reduce((a, b) => a > b ? a : b)/MoneySource.instance.TypesMoney.fold(0.0, (a,b) => a+b)*100).toStringAsFixed(2)
                        + (MoneySource.instance.TotalCosumeOnMonth(selectedDate).reduce((a, b) => a > b ? a : b)/MoneySource.instance.TotalCosumeOnMonth(selectedDate).fold(0.0, (a,b) => a+b)*100).toStringAsFixed(2)
                        + "%",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith( 
                          color: colors.onSurface,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MyPieChart(selectedDate: selectedDate),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 300,
                width: 500,
                child: bar_chart(money: consumeOnMonth),
              ),
            ],
          ),
      ),
    ),
      DetailPage(),
      ];

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0
        //leading: IconButton(onPressed: (){}, icon: Icon(Icons.menu)),
      ),
      drawer: Drawer(
        child: MyDrawer(),
      ),
      drawerEdgeDragWidth: 30,
      //backgroundColor: Colors.white,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(bottom:false, child:  pages.elementAt(_selectedPage)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await Navigator.push(context, MaterialPageRoute(builder: (context)=> const MoneyRecordPage()));
          setState(() {
          });
        },
        // backgroundColor: Colors.amber,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        tooltip: 'Add Record',
        child: Icon(Icons.add),
        ),
        
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              //color: Colors.grey,
              color: extra.border, 
              width: 0.8,
            ),
          ),
          // color: Colors.white, 
          color: colors.surface
        ),
        child: Theme(
          //data: ThemeData(
          data: Theme.of(context).copyWith( 
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedPage,
          onTap: _navigateBottomBar,
          type: BottomNavigationBarType.fixed,
          //selectedItemColor: Colors.teal,
          selectedItemColor: colors.primary, 
          unselectedItemColor: extra.subText,
          backgroundColor: colors.surface, 
          items:[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '主頁'),
          
          BottomNavigationBarItem(icon: Icon(Icons.info), label: '詳情'),
            ]),
        ),
      ),
    );
  }
}
