import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/common_use/common_use.dart';
import 'package:self_made_app/pages/travel_money_record.dart';
import 'package:self_made_app/color_theme/app_color.dart';
import 'package:self_made_app/color_theme/app_theme.dart';

class TravelCard extends StatelessWidget {
  final int keyNumber;

  const TravelCard({
    super.key,
    required this.keyNumber
  });

  @override
  Widget build(BuildContext context) {
    //Color preset
    final theme = Theme.of(context); 
    final colors = theme.colorScheme; 
    final textTheme = theme.textTheme; 
    final extra = theme.extension<AppExtraColors>()!; 

    //Initial travel box data
    final box = TravelboxMoneyData.get(keyNumber);
    late String nameOfTrip;
    late DateTime startDateOfTrip;
    late DateTime endDateOfTrip;
    late String placeOfTrip;
    late List<String>? partnersOfTrip;
    late String currency;
    late double rate;

    late double travelSoloHKDCost;
    late double travelGroupHKDCost;
    //late double travelTotalCost;
    
    (double,double) travelCost(String kind,){
      double hkd;
      double nonhkd;
      if(kind == "solo"){
        hkd = box.travelMoneyRecords.where((record) => record.currency == "HKD").fold(0.0, (sum, record) => sum + (record.separateCost["我"]?.amountPaid ?? 0.0));
        nonhkd = box.travelMoneyRecords.where((record) => record.currency != "HKD").fold(0.0, (sum, record) => sum + (record.separateCost["我"]?.amountPaid ?? 0.0));
      }
      else{
        hkd = box.travelMoneyRecords.where((record) => record.currency == "HKD").fold(0.0, (sum, record) => sum + record.amountCost);
        nonhkd = box.travelMoneyRecords.where((record) => record.currency != "HKD").fold(0.0, (sum, record) => sum + record.amountCost);
      }
      return  (hkd,nonhkd);
    }

    if(box != null){
      nameOfTrip = box.nameOfTrip;
      startDateOfTrip = box.startDateOfTrip;
      endDateOfTrip = box.endDateOfTrip;
      placeOfTrip = box.placeOfTrip;
      partnersOfTrip = box.partnersOfTrip;
      currency = box.currency;
      rate = box.rate;

      //Solo trip cost
      travelSoloHKDCost = travelCost("solo").$1 + travelCost("solo").$2 * rate;
      //Group trip cost
      partnersOfTrip!.length>1 ? 
      travelGroupHKDCost = travelCost("nonsolo").$1 + travelCost("nonsolo").$2 * rate : travelGroupHKDCost = 0;
    }
    if(box == null){
      return Text("No Data Found",style: textTheme.bodyMedium?.copyWith(color: extra.subText, ));// ⭐ 改色位
    }
    return SizedBox(
      width: 400,
      child: ElevatedButton (
        style: ElevatedButton.styleFrom(
          backgroundColor: extra.cardSoft, 
          foregroundColor: colors.onSurface, 
          shadowColor: extra.fabShadow, 
          surfaceTintColor: Colors.transparent, 
          elevation: 3,
          side: BorderSide(
            color: extra.border, 
          ),
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Theme(
                    data: AppTheme.getTheme(AppFlavorTheme.travel),
                    child: TravelMoneyRecordPage(RecordKey: keyNumber,),
                  )
                ));
        },
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  //Text('旅行名稱︰',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                  Text(
                    '旅行名稱︰',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      nameOfTrip,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface, 
                        fontSize: 16,
                      ),
                      minFontSize: 16,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  // Text('旅行日期︰',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                  Text(
                    '旅行日期︰',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      startDateOfTrip.toLocal().toIso8601String().split('T').first
                      + " - "
                      + endDateOfTrip.toLocal().toIso8601String().split('T').first,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface, 
                        fontSize: 16,
                      ),
                      minFontSize: 16,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text(
                    '旅行地點︰',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface, 
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      placeOfTrip,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface, 
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text(
                    '旅行成員︰',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface, 
                    ),
                  ),
                  if(partnersOfTrip == null || partnersOfTrip!.isEmpty || partnersOfTrip.length == 1)
                    Text('無',style: TextStyle(fontSize: 16),),
                  if(partnersOfTrip != null && partnersOfTrip!.isNotEmpty && partnersOfTrip.length > 1)
                  Expanded(
                    child: AutoSizeText(
                      partnersOfTrip.where((name)=> name != "我").join(', '),softWrap: false,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface, 
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text(
                    '貨幣匯率︰',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      "1.0 $currency : $rate HKD",
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.primary, 
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text(
                    partnersOfTrip!.length > 1 ? '個人消費︰' : "旅行消費︰",
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      "HKD\$ ${moneyUnitChange(travelSoloHKDCost)}",
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.primary, 
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if(partnersOfTrip!.length > 1 )...[
                SizedBox(height: 10,),
              Row(
                children: [
                  Text(
                    "團體消費︰",
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface, 
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      "HKD\$ ${moneyUnitChange(travelGroupHKDCost)}",
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.primary, 
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
 
              ]
            ]
          ),
        )
          ),
    );
  }
}