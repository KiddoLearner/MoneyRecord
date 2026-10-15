import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';
import 'package:self_made_app/color_theme/app_color.dart';
import 'package:self_made_app/component/drawer.dart';
import 'package:self_made_app/component/travel_card.dart';
import 'package:self_made_app/component/travel_dialog_create_record.dart';
import 'package:self_made_app/pages/travel_money_record.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({Key? key}) : super(key: key);

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {

void showCreateRecordDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return TravelDialogCreateRecord();
    },
  );
}

  //Used for update the old data which without "我"
  final TravelMoneySource _travelMoneySource = TravelMoneySource();
  Future<void> _initPage() async {
    await _travelMoneySource.fixAllOldTravelData();

    if (!mounted) return;
    _refreshItems();
  }

  List<int> items = [];
  late StreamSubscription _boxSubscription;
  @override
  void initState() {
    super.initState();
    // ✅ PARTNER LIST UPDATE:
    _initPage();
    // Initialize the list of items
    _refreshItems();
    // Listen for changes in the Hive box
    _boxSubscription = TravelboxMoneyData.watch().listen((event) {
      _refreshItems();
    });

  }

  @override
  void dispose() {
    _boxSubscription.cancel();
    super.dispose();
  }

  void _refreshItems() {
    setState(() {
      final entries = <MapEntry<int, TravelMoneyData>>[];
      // Debug: print box keys
      try {
        // convert to list to avoid lazy iterable issues
        final keysList = TravelboxMoneyData.keys.toList();
        // ignore: avoid_print
        print('TravelboxMoneyData.keys: $keysList');
      } catch (_) {}

      for (var key in TravelboxMoneyData.keys) {
        final value = TravelboxMoneyData.get(key);
        if (value != null) {
          entries.add(MapEntry(key as int, value));
        }
      }

      entries.sort((a, b) => b.value.startDateOfTrip.compareTo(a.value.startDateOfTrip));
      items = entries.map((entry) => entry.key).toList();

      // Debug: print entries and items
      try {
        // ignore: avoid_print
        print('Travel entries count: ${entries.length}, items: $items');
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final colors = Theme.of(context).colorScheme; 
    final textTheme = Theme.of(context).textTheme; 
    final extra = Theme.of(context).extension<AppExtraColors>()!; 

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        backgroundColor: colors.surface, 
        foregroundColor: colors.onSurface, 
        scrolledUnderElevation: 0
      ),
      drawer: Drawer(backgroundColor: colors.surface, child: MyDrawer(),),
      drawerEdgeDragWidth: 30,
      body: 
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 40.0,right: 40,bottom: 20),
          child: Column(
            children: [
              Text("旅行消費",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
              SizedBox(height: 20,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.grey[200],
                  // foregroundColor: Colors.black,
                  backgroundColor: extra.chart3, 
                  foregroundColor: colors.onSurface,
                  surfaceTintColor: Colors.transparent, 
                  shadowColor: extra.fabShadow, 
                  elevation: 3,
                  side: BorderSide(color: extra.border,), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: (){
                  showCreateRecordDialog(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 400,
                    height: 100,
                    child: 
                    screenWidth < 400? 
                    Center(
                      child: ListTile(
                        leading: Icon(Icons.travel_explore_outlined,size: 30,),
                        title: Text(
                            '新增旅行項目',style: textTheme.titleMedium?.copyWith( 
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                              overflow: TextOverflow.ellipsis
                            ),),
                        trailing: Icon(Icons.touch_app_outlined,size: 10,),
                      ),
                    )
                   : Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '新增旅行項目',style: textTheme.titleMedium?.copyWith( 
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),), 
                        Positioned(
                          left: 10,
                          bottom: 15,
                          child: 
                          Icon(
                          Icons.travel_explore_outlined
                          ,size: 80,
                          
                          )
                        ),
                        Positioned(
                          right: 35,
                          bottom: 10,
                          child: 
                          Transform.rotate
                          (angle: 270,
                          child: Icon(
                            Icons.touch_app_outlined
                            ,size: 50,
                            
                          )
                          ),
                          
                        )
                                            
                      ],
                    ),
                  ),
                ),
                ),
              SizedBox(height: 20,),
              //Expanded(
                //child: 
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.isEmpty ? 1 : items.length,
                    itemBuilder: (context, index) {
                      if (items.isEmpty) {
                        return Center(
                          child: Text("暫時沒有旅行紀錄", style: textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            color: extra.subText,
                          ),),
                        );
                      } else {
                        return Column(
                          children: [
                            TravelCard(keyNumber: items[index]),
                            SizedBox(height: 10,)
                          ],
                        );
                      }
                    }
                  )
              //,),
              
            ],
          ),
        ),
      )
      
    );
  }
}