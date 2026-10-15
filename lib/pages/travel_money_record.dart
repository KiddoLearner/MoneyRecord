import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';
import 'package:self_made_app/common_use/common_use.dart';
import 'package:self_made_app/component/travel_card_of_detail_record.dart';
import 'package:self_made_app/component/travel_dialog_create_single_consumption.dart';
import 'package:self_made_app/component/travel_info_card.dart';
import 'package:self_made_app/component/travel_one_record_card.dart';
import 'package:self_made_app/pages/travel_partner_consume.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:self_made_app/color_theme/app_color.dart';

class TravelMoneyRecordPage extends StatefulWidget {
  final int RecordKey;
  const TravelMoneyRecordPage({super.key, required this.RecordKey});

  @override
  State<TravelMoneyRecordPage> createState() => _TravelMoneyRecordPage();
}

class _TravelMoneyRecordPage extends State<TravelMoneyRecordPage> {

  //Page controller
  int _currentPage = 0;
  late final PageController _controller;
  // late DateTimeRange dateRange =DateTimeRange(
  //     start: TravelboxMoneyData.get(widget.RecordKey)!.startDateOfTrip,
  //     end: TravelboxMoneyData.get(widget.RecordKey)!.endDateOfTrip,
  //   );
  // late List<TravelMoneyRecord> wholeList = TravelboxMoneyData.get(widget.RecordKey).travelMoneyRecords;
  DateTimeRange? dateRange;
  List<TravelMoneyRecord> wholeList = [];

  //Hive Listener
  late StreamSubscription _boxSubscription;

  void _TravelDialogCreateSingleConsumption(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return TravelDialogCreateSingleConsumption(partnerNames: TravelboxMoneyData.get(widget.RecordKey).partnersOfTrip, keyNumber: widget.RecordKey,);
      }
    );
  }

  /*===Infinite Scroll Setup===*/
  final ValueNotifier<bool> selectionModeVN = ValueNotifier(false);
  final ValueNotifier<Set<int>> selectedIndexesVN = ValueNotifier(<int>{});
  final ValueNotifier<bool> isLoadingVN = ValueNotifier(false);

  List<FilteredItem> _filteredItems = [];
  //bool _isLoading = false;
  int _page = 1;
  final int _pageSize = 5;
  //final ScrollController _scrollController = ScrollController();

  //temp for update
  List<FilteredItem> _buildFilteredItems(List<TravelMoneyRecord> source, int currentPage) {
    final allItems = <FilteredItem>[];

    for (int i = 0; i < source.length; i++) {
      final item = source[i];
      if (item.typeCost == typesOfCards[currentPage]) {
        allItems.add(FilteredItem(item, i));
      }
    }

    allItems.sort((a, b) => b.data.dateCost.compareTo(a.data.dateCost));
    return allItems;
  }

  

  void _LoadFilteredItems() {
  if (isLoadingVN.value) return;
  isLoadingVN.value = true;

  final newFilteredItems = _buildFilteredItems(wholeList, _currentPage);

  setState(() {
    _filteredItems = newFilteredItems;
    _page = 1;
  });

  isLoadingVN.value = false;
}

void _resetAndLoadItems() {
  final newFilteredItems = _buildFilteredItems(wholeList, _currentPage);

  setState(() {
    _filteredItems = newFilteredItems;
    _page = 1;
  });
}

  void _loadNextPage() async{
    if(isLoadingVN.value) return;

    if(_page * _pageSize >= _filteredItems.length){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("沒有更多紀錄了"),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _page++;
    });
  }

  void UpdatedAndReload() {
  final data = TravelboxMoneyData.get(widget.RecordKey);

  if (data == null) {
    if (mounted) {
      try {
        _boxSubscription.cancel();
      } catch (_) {}
      Navigator.of(context).pushNamedAndRemoveUntil('/travel_page', (route) => false);
    }
    return;
  }

  final newWholeList = data.travelMoneyRecords;
  final newFilteredItems = _buildFilteredItems(newWholeList, _currentPage);

  if (!mounted) return;

  setState(() {
    wholeList = newWholeList;
    _filteredItems = newFilteredItems;
    _page = 1;
  });
}

  List<FilteredItem> _getVisibleItems() {
    final startIndex = 0;
    final endIndex = (_page * _pageSize).clamp(0, _filteredItems.length);
    return _filteredItems.sublist(startIndex, endIndex);
  }

  //Multi Selection settings
  void toggleSelection(int index) {
  final current = {...selectedIndexesVN.value};
  if (current.contains(index)) {
    current.remove(index);
    selectedIndexesVN.value = current;
    if (current.isEmpty) {
      selectionModeVN.value = false;
    }
  } else {
    current.add(index);
    selectedIndexesVN.value = current;
  }
}

void startSelection(int index) {
  final current = {...selectedIndexesVN.value};
  current.add(index);
  selectedIndexesVN.value = current;
  selectionModeVN.value = true;
}

void clearSelection() {
  selectedIndexesVN.value = <int>{};
  selectionModeVN.value = false;
}
  
  Future<void> _deleteMultiRecord(BuildContext context, {Set<dynamic> indexlist = const {},}) async {
  final trip = TravelboxMoneyData.get(widget.RecordKey);
  if (trip == null) return;

  final currentList = List<TravelMoneyRecord>.from(trip.travelMoneyRecords);

  //if (selectionMode && indexlist.isNotEmpty) {
  if (selectionModeVN.value && indexlist.isNotEmpty) {
    final toDelete = indexlist.whereType<int>().toSet();

    trip.travelMoneyRecords = [
      for (int i = 0; i < currentList.length; i++)
        if (!toDelete.contains(i)) currentList[i]
    ];
  //} else if (!selectionMode) {
  } 

  await TravelboxMoneyData.put(widget.RecordKey, trip);

  if (mounted) {
    clearSelection();
    UpdatedAndReload();
  }
}

  void _ShowDeleteConfirmationDialog(BuildContext context,{Set<dynamic>? indexlist}) {
    final colors = Theme.of(context).colorScheme; 
    final extra = Theme.of(context).extension<AppExtraColors>()!; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), 
            side: BorderSide(color: extra.border), 
          ),
          title: Text("確認刪除",style: TextStyle(color: colors.onSurface,  ),),
          content: 
          //selectionMode?
          Text("確定要刪除這些記錄嗎？",style: TextStyle(color: extra.subText, ),)
          ,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
              child: Text("取消",style: TextStyle(color: colors.primary, ),),
            ),
            TextButton(
              onPressed: () {
                //selectionMode?
                selectionModeVN.value ?
                _deleteMultiRecord(context, indexlist: indexlist ?? {}): //Chose the records
                _deleteMultiRecord(context); //Delete the records between the date range
                Navigator.of(context).pop();
              },
              child: Text("刪除", style: TextStyle(color: colors.error,),),
            ),
          ],
        );
      },
    );
  }
  /*===========================*/


  /*=======Chosen Page========*/
  int _selectedPage = 0;
  void _navigateBottomBar(int index){
    setState(() {
      _selectedPage = index;
    });
  }
  /*===========================*/
  @override
  void initState() {
    super.initState();
    _controller = PageController();
    final data = TravelboxMoneyData.get(widget.RecordKey);
    if (data != null) {
      dateRange = DateTimeRange(
        start: data.startDateOfTrip,
        end: data.endDateOfTrip,
      );
      wholeList = data.travelMoneyRecords;
    }
    _LoadFilteredItems();
    //Change when update in travel box
    _boxSubscription = TravelboxMoneyData.watch(key: widget.RecordKey).listen((event) {
      if (mounted) {
        UpdatedAndReload();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _boxSubscription.cancel();    
    selectionModeVN.dispose();
    selectedIndexesVN.dispose();
    isLoadingVN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final colors = theme.colorScheme; 
    final textTheme = theme.textTheme;
    final extra = theme.extension<AppExtraColors>()!;

    if (TravelboxMoneyData.get(widget.RecordKey) == null) {
      // record deleted, show placeholder or pop
      return Scaffold(
        backgroundColor: colors.background, 
        body: Center(child: Text("紀錄已被刪除", style: textTheme.bodyLarge?.copyWith(fontSize: 18,color: extra.subText,),)), 
      );
    }
    
    // Ensure dateRange is initialized
    if (dateRange == null) {
      return Scaffold(
        backgroundColor: colors.background, 
        body: Center(child: Text("載入中...", style: textTheme.bodyLarge?.copyWith(fontSize: 18,color: extra.subText, ),)),
      );
    }
    
    final visibleItems = _getVisibleItems();
    final hasMore = _page * _pageSize < _filteredItems.length;

    /*===========Pages===========*/
    final List<Widget> pages=[
      /*===========Page1===========*/
      SingleChildScrollView(
        child: Column(
                children: [
                  TravelInfoCard(recordKey: widget.RecordKey),
              
                  SizedBox(
                    height: 200,
                    child: PageView(
                      controller: _controller,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                          _resetAndLoadItems();
                        });
                      },
                      children: [
                        TravelCardOfDetailRecord(colorCard: colorsOfCards[0], typeCard: typesOfCards[0], dateRange: dateRange!, records: wholeList),
                        TravelCardOfDetailRecord(colorCard: colorsOfCards[1], typeCard: typesOfCards[1], dateRange: dateRange!, records: wholeList),
                        TravelCardOfDetailRecord(colorCard: colorsOfCards[2], typeCard: typesOfCards[2], dateRange: dateRange!, records: wholeList),
                        TravelCardOfDetailRecord(colorCard: colorsOfCards[3], typeCard: typesOfCards[3], dateRange: dateRange!, records: wholeList),
                        TravelCardOfDetailRecord(colorCard: colorsOfCards[4], typeCard: typesOfCards[4], dateRange: dateRange!, records: wholeList),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 5,
                    effect: SwapEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      // activeDotColor: Colors.blue,
                      // dotColor: Colors.grey,
                      activeDotColor: colors.primary, 
                      dotColor: extra.borderStrong, 
                    ),
                  ),
                 
                    _filteredItems.isEmpty ?
                    Center(
                      child: Text("無相關紀錄",style: textTheme.bodyLarge?.copyWith(color: extra.subText, ),),
                    ) :
                    
                  
                    Padding(
                      padding: const EdgeInsets.only(top:10.0),
                      child: TapRegion(
                        onTapOutside: (_) {
                        //if (selectionMode) {
                        if(selectionModeVN.value){
                          clearSelection();
                        }
                      },
                        child: Column(
                          children: [                         
                          ValueListenableBuilder<bool>(
                            valueListenable: selectionModeVN,
                            builder: (context, selectionMode, _) {
                              return ValueListenableBuilder<Set<int>>(
                                valueListenable: selectedIndexesVN,
                                builder: (context, selectedIndexes, _) {
                                  if (!selectionMode) return const SizedBox.shrink();
        
                                  return ListTile(
                                    leading: const Icon(Icons.note_alt_outlined),
                                    title: Center(
                                      child: AutoSizeText(
                                        '已選擇${selectedIndexes.length}個紀錄',
                                        maxFontSize: 16,
                                        minFontSize: 5,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _ShowDeleteConfirmationDialog(context, indexlist: selectedIndexes);
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          ValueListenableBuilder<Set<int>>(
                            valueListenable: selectedIndexesVN,
                            builder: (context, selectedIndexes, _) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: selectionModeVN,
                                builder: (context, selectionMode, __) {
                                  return ValueListenableBuilder<bool>(
                                    valueListenable: isLoadingVN,
                                    builder: (context, isLoading, ___) {
                                      return PopScope(
                                        canPop: selectedIndexes.isEmpty,
                                        onPopInvokedWithResult: (didPop, result) {
                                          if (!didPop && selectedIndexes.isNotEmpty) {
                                            clearSelection();
                                          }
                                        },
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: visibleItems.length + (isLoading ? 1 : 0) + (hasMore ? 1 : 0),
                                          itemBuilder: (context, index) {
                                            if (isLoading && hasMore && index == visibleItems.length) {
                                              return Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      CircularProgressIndicator(color: colors.primary),
                                                      Text(
                                                        "載入中...",
                                                        style: textTheme.bodyMedium?.copyWith(color: extra.subText),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
        
                                            if (hasMore && index == visibleItems.length + (isLoading ? 1 : 0)) {
                                              return Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                  child: SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.4,
                                                    height: MediaQuery.of(context).size.height * 0.05,
                                                    child: ElevatedButton.icon(
                                                      icon: Icon(Icons.download, color: colors.onPrimary),
                                                      onPressed: _loadNextPage,
                                                      label: Text(
                                                        "載入更多",
                                                        style: TextStyle(color: colors.onPrimary),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: colors.primary,
                                                        foregroundColor: colors.onPrimary,
                                                        shadowColor: extra.fabShadow,
                                                        surfaceTintColor: Colors.transparent,
                                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
        
                                            if (index < visibleItems.length) {
                                              final filteredItem = visibleItems[index];
                                              final isSelected = selectedIndexes.contains(filteredItem.originalIndex);
        
                                              final bool separated;
                                              final bool allPaid;
        
                                              // if (filteredItem.data.separateCost.isEmpty ||
                                              //     !(filteredItem.data.separateCost.values.any((value) => value.amountPaid > 0))) {
                                              if(filteredItem.data.separateCost.values.where((value) => value.amountPaid > 0).take(2).length <= 1){
                                                separated = false;
                                                allPaid = true;
                                              } else {
                                                separated = true;
                                                allPaid = !filteredItem.data.separateCost.values.any((value) => value.isPaid == false);
                                              }
        
                                              return Column(
                                                children: [
                                                  ListTile(
                                                    leading: selectionMode
                                                        ? Icon(
                                                            isSelected
                                                                ? Icons.check_circle
                                                                : Icons.radio_button_unchecked,
                                                          )
                                                        : null,
                                                    onLongPress: () => startSelection(filteredItem.originalIndex),
                                                    onTap: () {
                                                      if (selectionMode) {
                                                        toggleSelection(filteredItem.originalIndex);
                                                      } else {
                                                        // 正常 click 行為
                                                      }
                                                    },
                                                    title: TravelOneRecordCard(
                                                      type: filteredItem.data.typeCost,
                                                      name: filteredItem.data.nameCost,
                                                      amount: filteredItem.data.amountCost,
                                                      currency: filteredItem.data.currency,
                                                      currencyList: [
                                                        TravelboxMoneyData.get(widget.RecordKey).currency,
                                                        "HKD"
                                                      ],
                                                      date: filteredItem.data.dateCost,
                                                      keyIndex: widget.RecordKey,
                                                      listKeyIndex: filteredItem.originalIndex,
                                                      separatedMap: filteredItem.data.separateCost,
                                                      separated: separated,
                                                      allPaid: allPaid,
                                                      whoPiad: filteredItem.data.whoPaid,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
        
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),                         
                        
                          ],
                        ),
                      ),
                    ),
                    //),
                  
                ],
              ),
      ),
    /*===========================*/
    /*===========Page2===========*/
      //Center(child:Text('testing'))
      TravelPartnerConsume(recordKey: widget.RecordKey),
    /*===========================*/
    ];
    /*===========================*/

    return Scaffold(
        backgroundColor: colors.surface, 
        appBar: AppBar(          
          title: Text(
            _selectedPage == 0?
            '旅行消費紀錄' : '同行人士欠款',
            style: TextStyle(
              color: Colors.black
            ),
          ),
          centerTitle: true,
          backgroundColor: colors.surface,
          foregroundColor: colors.onSurface, 
          scrolledUnderElevation: 0, 
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 0.0),
          child: pages.elementAt(_selectedPage)),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: 
      (TravelboxMoneyData.get(widget.RecordKey).partnersOfTrip.length>1)?
      FloatingActionButton(onPressed: (){
        _TravelDialogCreateSingleConsumption();
      },
        // backgroundColor: Colors.white,
        backgroundColor: colors.primary, 
        foregroundColor: colors.onPrimary, 
        child: Icon(Icons.add, color: colors.onPrimary,size: 40,),
      ) : null,
       bottomNavigationBar: Container(
        color: colors.surface, 
         child: SafeArea(
          top: false,
           child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    // color: Colors.grey,
                    color: extra.borderStrong,
                    width: 0.8,
                  ),
                ),
                // color: Colors.white,
                color: colors.surface, 
              ),
              child: Theme(
                data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              
              child: 
              (TravelboxMoneyData.get(widget.RecordKey).partnersOfTrip.length > 1)?
              BottomNavigationBar(
                currentIndex: _selectedPage,
                onTap: _navigateBottomBar,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: extra.chart1,
                items:[
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: '消費紀錄'),
                  BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark_sharp), label: '同行帳款'),
                ]):
                FloatingActionButton(onPressed: (){
                  _TravelDialogCreateSingleConsumption();
                },
                  // backgroundColor: Colors.white,
                  backgroundColor: colors.primary, 
                  foregroundColor: colors.onPrimary, 
                  child: Icon(Icons.add, color: colors.onPrimary,size: 40,),
              ),
              ),
            ),
         ),
       ),
      
    );
  }
}

class FilteredItem {
  final TravelMoneyRecord data;
  final int originalIndex;
  //final dynamic key;

  FilteredItem(this.data, this.originalIndex);
}