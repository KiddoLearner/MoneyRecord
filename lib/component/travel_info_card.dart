import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/common_use/common_use.dart';
import 'package:self_made_app/component/travel_info_card_edit_dialog.dart';
import 'package:self_made_app/color_theme/app_color.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TravelInfoCard extends StatefulWidget {
  final int recordKey;
  const TravelInfoCard({super.key, required this.recordKey});
  @override
  State<TravelInfoCard> createState() => _TravelInfoCardState();
}

class _TravelInfoCardState extends State<TravelInfoCard>{
  late String travelName;
  late DateTime startDate;
  late DateTime endDate;
  late String travelLocation;
  late List<String> travelMembers;
  late String currency;
  late double rate;
  late double travelHKDCost;
  late double travelNonHKDCost;
  late double travelTotalCost;
  late String consumeKind;
  final List<String> consumeKindList = ["個人消費","團體消費"];

  void initialData(){
    final travelData = TravelboxMoneyData.get(widget.recordKey);
    if (travelData != null) {
      travelName = travelData.nameOfTrip;
      startDate = travelData.startDateOfTrip;
      endDate = travelData.endDateOfTrip;
      //travelDate = "${travelData.startDateOfTrip.toLocal().toIso8601String().split('T').first} - ${travelData.endDateOfTrip.toLocal().toIso8601String().split('T').first}";
      travelLocation = travelData.placeOfTrip;
      travelMembers = travelData.partnersOfTrip ?? ["我"];
      currency = travelData.currency;
      rate = travelData.rate;
      if(travelData.partnersOfTrip.length == 1){ //Solo Trip used
        travelHKDCost = travelData.travelMoneyRecords.where((record)=>record.currency == "HKD").fold(0.0, (sum, record) => sum + record.amountCost);
        travelNonHKDCost = travelData.travelMoneyRecords.where((record)=>record.currency != "HKD").fold(0.0, (sum, record) => sum + record.amountCost);  
      }
      // travelTotalCost = travelData.travelMoneyRecords.fold(0.0, (sum, record) => sum + record.amountCost);
      else if (travelData.partnersOfTrip.length > 1) {
        travelHKDCost = travelData.travelMoneyRecords.where((record) => record.currency == "HKD").fold(0.0, (sum, record) => sum + (record.separateCost["我"]?.amountPaid ?? 0.0));
        travelNonHKDCost = travelData.travelMoneyRecords.where((record) => record.currency != "HKD").fold(0.0, (sum, record) => sum + (record.separateCost["我"]?.amountPaid ?? 0.0));
      }
      travelTotalCost = travelHKDCost + travelNonHKDCost * travelData.rate;
    }
  }

(double,double) travelCost(String kind,final box){
  double hkd;
  double nonhkd;
  if(kind == "個人消費"){
    hkd = box.travelMoneyRecords.where((record) => record.currency == "HKD").fold(0.0, (sum, record) => sum + (record.separateCost["我"]?.amountPaid ?? 0.0));
    nonhkd = box.travelMoneyRecords.where((record) => record.currency != "HKD").fold(0.0, (sum, record) => sum + (record.separateCost["我"]?.amountPaid ?? 0.0));
  }
  else{
    hkd = box.travelMoneyRecords.where((record) => record.currency == "HKD").fold(0.0, (sum, record) => sum + record.amountCost);
    nonhkd = box.travelMoneyRecords.where((record) => record.currency != "HKD").fold(0.0, (sum, record) => sum + record.amountCost);
  }
  return  (hkd,nonhkd);
}

//PageView
late final PageController _pageViewController;
  @override
  void initState(){
    super.initState();
    consumeKind = consumeKindList[0];
    _pageViewController = PageController();
    // Initialize travel info from Hive box using widget.recordKey
    //initialData();
  }

  @override
  void dispose(){
    _pageViewController.dispose();
    super.dispose();
  }

  AutoSizeText autoSizeText(String text,{double size = 14,TextStyle textStyle = const TextStyle(),var softWrap = null,int maxLine = 1}){
    return AutoSizeText(
      text,
      style: textStyle.copyWith(
        //color: Colors.black,
        fontSize: size
      ),
      minFontSize: 10,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      softWrap: softWrap,
    );
  }

  @override
  Widget build(BuildContext context){
    final travelData = TravelboxMoneyData.get(widget.recordKey);
    final colors = Theme.of(context).colorScheme; 
    //final textTheme = Theme.of(context).textTheme; 
    final extra = Theme.of(context).extension<AppExtraColors>()!; 

    initialData();
    return  Card(
      color: context.theme.cardColor, 
      shadowColor: extra.fabShadow, 
      shape: RoundedRectangleBorder( 
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: extra.border),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.card_travel,),
            title: autoSizeText(
              travelName,
              size: 20,
              textStyle: TextStyle(
                //fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.onSurface, 
                ),
              ), //改返做Travel Name 
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.date_range, size: 16,color: colors.primary,),
                    SizedBox(width: 5,),
                    Expanded(
                      child: autoSizeText('日期︰' 
                      + startDate.toLocal().toIso8601String().split('T').first
                      + " - "
                      + endDate.toLocal().toIso8601String().split('T').first,
                      ),
                    ), //改返做Travel Date
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16,color: colors.primary,),
                    SizedBox(width: 5,),
                    Expanded(child: autoSizeText('地點︰' + travelLocation)), 
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.people, size: 16,color: colors.primary,), 
                    SizedBox(width: 5,),
                    Flexible(child: autoSizeText('同行人士︰')), //改返做Travel Members
                    (travelMembers.isEmpty || travelMembers.length == 1) ?
                      autoSizeText('無') :
                    //if(travelMembers.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: autoSizeText(travelMembers.where((name)=> name != "我").join(', '),
                        softWrap: false),
                      ),
                    )
                  ],
                ),
                
                Row( //Solo Cost
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 2,
                      child: LayoutBuilder(
                        builder: (context,constraints){
                          final w = MediaQuery.sizeOf(context).width;

                          final dotSize = w < 399 ? 5.0 : w < 400 ? 8.0 : 12.0;
                          final dotSpacing = w < 10 ? 3.0 : w < 50 ? 4.0 : 6.0;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                                child: PageView(
                                  controller: _pageViewController,
                                  onPageChanged: (int page){
                                    setState(() {
                                      consumeKind = consumeKindList[page];
                                    });
                                  },
                                  children: [
                                    //autoSizeText("個人消費︰"),
                                    autoSizeText("個人消費︰"),
                                    if(travelMembers.length > 1)
                                    autoSizeText("團體消費︰")
                                  ],
                                ),
                              ),
                              SizedBox(height: 2,),
                              if(travelMembers.length > 1)
                              SmoothPageIndicator(
                                controller: _pageViewController,
                                count: 2,
                                effect: SwapEffect(
                                  spacing: dotSpacing*0.5,
                                  dotHeight: dotSize*0.5,
                                  dotWidth: dotSize*1.8,
                                  // activeDotColor: Colors.blue,
                                  // dotColor: Colors.grey,
                                  activeDotColor: colors.primary, 
                                  dotColor: extra.chart3, 
                                ),
                              ),
                            ],
                          );
                        }
                      ),
                    ),
                   
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: currency == "HKD"
                          ? [
                             
                              autoSizeText(
                                "HKD:\$${moneyUnitChange(travelCost(consumeKind,travelData).$1)}",
                                textStyle: TextStyle(color: colors.onSurface),
                              ),
                              
                            ]
                          : [
                              
                              autoSizeText(
                                "HKD:\$${moneyUnitChange(travelCost(consumeKind,travelData).$1)}",
                                textStyle: TextStyle(color: colors.onSurface),
                              ),
                              autoSizeText(
                                "$currency:\$${moneyUnitChange(travelCost(consumeKind,travelData).$2)}",
                                textStyle: TextStyle(color: colors.onSurface),
                              ),
                              autoSizeText(
                                "Total: HKD\$${moneyUnitChange(travelCost(consumeKind,travelData).$1 + travelCost(consumeKind,travelData).$2 * rate)}",
                                textStyle: TextStyle(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap, 
            ),
              icon: Icon(Icons.edit),
              onPressed: () async {
                final result = await showDialog(
                  context: context, 
                  builder: (context) => 
                  TravelInfoCardEditDialog(
                    initialName: travelName,
                    initialStartDate: startDate,
                    initialEndDate: endDate,
                    initialLocation: travelLocation,
                    initialPartners: travelMembers,
                    keyNumber: widget.recordKey,
                    currency: currency,
                    rate: rate,
                  ));
                if (result != null){
                  if(result['Result'] == 'Edited'){
                    setState(() {
                    travelName = result['name'];
                    startDate = result['startDate'];
                    endDate = result['endDate'];
                    travelLocation = result['location'];
                    travelMembers = result['partners'];
                    currency = result['currency'];
                    rate = result['rate'];
                  });
                  }
                }
              },
              ),
          ),
        ],
      ),
            
  );
  }
}