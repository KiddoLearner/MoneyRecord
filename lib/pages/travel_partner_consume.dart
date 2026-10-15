import 'dart:async';
import 'package:flutter/material.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';
import 'package:self_made_app/color_theme/app_color.dart';
import 'package:self_made_app/common_use/common_use.dart';

class TravelPartnerConsume extends StatefulWidget {
  final int recordKey;

  const TravelPartnerConsume({
    super.key,
    required this.recordKey,
  });

  @override
  State<TravelPartnerConsume> createState() => TravelPartnerConsumeState();
}

class TravelPartnerConsumeState extends State<TravelPartnerConsume> {
  late StreamSubscription _boxSubscription;

  List<String> partnerList = <String>[];

  List<TravelMoneyRecord> travelConsumeRecords = <TravelMoneyRecord>[];

  // 呢個係整理後最終要顯示喺 UI 嘅結果。
  Map<String, Map<String, double>> tiedResult = {};


  @override
  void initState() {
    super.initState();

    //一入頁先讀一次資料，將 partnerList / records / tiedResult 一次過準備好。
    _updatedAndReload();

    // 監聽 Hive box 指定 key 嘅變化。
    // 當資料被修改後，自動重新整理畫面。
    _boxSubscription =
        TravelboxMoneyData.watch(key: widget.recordKey).listen((event) {
      if (mounted) {
        _updatedAndReload();
      }
    });
  }

  @override
  void dispose() {
    _boxSubscription.cancel();
    super.dispose();
  }

  void _updatedAndReload() {
    final travelWholeRecord = TravelboxMoneyData.get(widget.recordKey);
    // 如果資料已經被刪除，直接返回上一頁/指定頁。
    if (travelWholeRecord == null) {    
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/travel_page', (route) => false);
      }
      return;
    }

    final newPartnerList = List<String>.from(travelWholeRecord.partnersOfTrip);
    final newTravelConsumeRecords = List<TravelMoneyRecord>.from(travelWholeRecord.travelMoneyRecords);

    // 先按 whoPaid 將 record 分組。
    
    final grouped = _groupRecordsByPayer(
      newPartnerList,
      newTravelConsumeRecords,
    );

    // 根據 partnerList + grouped records 計出最終欠款矩陣。
    final currencyRate = travelWholeRecord.rate;
    final result = tiedUpList(newPartnerList, grouped, currencyRate);

    if (!mounted) return;

    // 一次 setState 更新全部畫面需要嘅資料。
    setState(() {
      partnerList = newPartnerList;
      travelConsumeRecords = newTravelConsumeRecords;
      tiedResult = result;
    });
  }

  Map<String, List<TravelMoneyRecord>> _groupRecordsByPayer(
    List<String> partners,
    List<TravelMoneyRecord> records,
  ) {
    final tempList = <String, List<TravelMoneyRecord>>{};

    //先預設所有 partner 都有一個 entry。
    for (final name in partners) {
      tempList[name] = <TravelMoneyRecord>[];
    }

    //用 putIfAbsent 比 if(tempList[key] != null) 更穩陣。
    // 即使某筆資料入面 whoPaid 唔喺 partnerList 預設名單，都照樣可以建立 key 再 add。
    for (final record in records) {
      tempList.putIfAbsent(record.whoPaid, () => <TravelMoneyRecord>[]);
      tempList[record.whoPaid]!.add(record);
    }

    return tempList;
  }

  Map<String, Map<String, double>> tiedUpList(
    List<String> partnerList,
    Map<String, List<TravelMoneyRecord>> groupedRecords,
    double currencyRate
  ) {
    final omg = <String, Map<String, double>>{};
    for (final name in partnerList) {
      omg[name] = <String, double>{};

      for (final partner in partnerList) {
        if (name != partner) {
          omg[name]![partner] = 0.0;
        }
      }
    }

    groupedRecords.forEach((payer, records) {
      if (!omg.containsKey(payer)) {
        omg[payer] = <String, double>{};
      }
      for (final record in records) {
        final String currency = record.currency; 
        record.separateCost.forEach((partner, money) {
          if(payer == partner) return;
          if (payer != partner) {
            final current = omg[payer]![partner] ?? 0.0;
            omg[payer]![partner] = current + (money.isPaid ? 0.0 : currency == "HKD"? money.amountPaid : money.amountPaid * currencyRate);
          }
        });
      }
    });

    // 補齊所有漏咗嘅 partner key，避免顯示時出現缺 key
    for (final payer in partnerList) {
      omg[payer] ??= <String, double>{};
      for (final partner in partnerList) {
        if (payer != partner) {
          omg[payer]!.putIfAbsent(partner, () => 0.0);
        }
      }
    }

    return omg;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // 轉成 List，因為 ListView.builder 係 index-based，
    final outerEntries = tiedResult.entries.toList();

    return 
          outerEntries.isEmpty
          ? const Center(
              child: Text('暫時冇資料'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: outerEntries.length,
              itemBuilder: (context, index) {
                final personEntry = outerEntries[index];
                final personName = personEntry.key;
                final debtMap = personEntry.value;

                // [新加] 內層 Map 一樣轉成 List，方便用第二層 ListView.builder 顯示。
                final innerEntries = debtMap.entries.toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          personName + " - 收款人",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        //  用內層 ListView.builder 顯示「呢個人對其他人嘅欠款」                        
                        ListView.builder(
                          itemCount: innerEntries.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, innerIndex) {
                            final debtEntry = innerEntries[innerIndex];
                            final partnerName = debtEntry.key;
                            final price = debtEntry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      partnerName,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: Text(
                                      '需還款 = \$HKD${moneyUnitChange(price)}',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: price == 0
                                            ? Colors.grey.shade700
                                            : Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
  }
}