import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/DataSource/MoneySource.dart';
import 'package:self_made_app/common_use/common_use.dart';
import 'package:self_made_app/component/card_of_detail_record.dart';
import 'package:self_made_app/component/one_record_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:self_made_app/color_theme/app_color.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>{

  /*=====Date Range Picker Setup  */
    DateTimeRange dateRange = DateTimeRange(
    // start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    // end: DateTime(DateTime.now().year, DateTime.now().month +  1, 0),
    start: DateTime(date.year,date.month,1),
    end: DateTime(date.year,date.month + 1,0)
  );

  Future pickDateRange() async {
  final newDateRange = await showDateRangePicker(
    context: context,
    initialDateRange: dateRange,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  );

  if (newDateRange == null) {
    return;
  } else {
    setState((){
    dateRange = newDateRange;
    changeBridgeDate(newDateRange.start);
    _resetAndLoadItems();
    });
  }
}
  List dataList = [];

  int _currentPage = 0;
  late final _controller;

  /*===Infinite Scroll Setup===*/
  List<FilteredItem> _filteredItems = [];
  bool _isLoading = false;
  int _page = 1;
  final int _pageSize = 5;
  final ScrollController _scrollController = ScrollController();

  //Multi Selection settings
  bool selectionMode = false;
  int selectedItems = 0;
  final Set<dynamic> selectedIndexes = {};
  void toggleSelection(dynamic index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
        if (selectedIndexes.isEmpty) {
          selectionMode = false;
        }
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void startSelection(dynamic index) {
    setState(() {
      selectionMode = true;
      selectedIndexes.add(index);
    });
  }

  void clearSelection(){
    setState((){
      selectionMode = false;
      selectedIndexes.clear();
    });
  }

  Future<void> _deleteMultiRecord(BuildContext context,{Set<dynamic> indexlist = const {}}) async {
    if(selectionMode && indexlist.isNotEmpty){
      for(String index in indexlist){
        await boxMoneyData.delete(index);
      }
    }
    else if(!selectionMode){
      // for(var record in _filteredItems){
      //   await boxMoneyData.delete(record.key);
      // }
      final keysToDelete = _filteredItems.map((record) => record.key).toList();
      await boxMoneyData.deleteAll(keysToDelete);
    }
    MoneySource.instance.modifyRecord();
    clearSelection();
    //Navigator.of(context).pop(); // Close the dialog after deletion
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
          selectionMode?
          Text("確定要刪除這些記錄嗎？",style: TextStyle(color: extra.subText, ),):
          Text("確定要刪除這個月${typesOfCards[_currentPage]}的記錄嗎？",style: TextStyle(color: extra.subText, ),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
              child: Text("取消",style: TextStyle(color: colors.primary, ),),
            ),
            TextButton(
              onPressed: () {
                selectionMode?
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

//Data settings
  void _resetAndLoadItems() {
    setState(() {
      _filteredItems.clear();
    _page = 1;
    _isLoading = false;
    });
    _LoadFilteredItems();
  }

  void _LoadFilteredItems() async {
    if(_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final allItems = <FilteredItem>[];
    for(int i = 0; i < boxMoneyData.length; i++){
      var item = boxMoneyData.getAt(i);
      var key = boxMoneyData.keyAt(i);
      if(item.dateCost.isAfter(dateRange.start.subtract(const Duration(days: 1))) && item.dateCost.isBefore(dateRange.end.add(const Duration(days: 1)))&& item.typeCost == typesOfCards[_currentPage]){
        allItems.add(FilteredItem(item,i,key));
      }
    }

    setState(() {
      _filteredItems = allItems..sort((a, b) => b.data.dateCost.compareTo(a.data.dateCost));
      _isLoading = false;
      _page = 1;
    });
  }

  void _loadNextPage() async{
    if(_isLoading) return;

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

  void _onScroll() {
    if(_isLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  List<FilteredItem> _getVisibleItems() {
    final startIndex = 0;
    final endIndex = (_page * _pageSize).clamp(0, _filteredItems.length);
    return _filteredItems.sublist(startIndex, endIndex);
  }

  
  /*===========================*/

  late StreamSubscription _boxSubscription;

    @override
    void initState() {
      super.initState();
      _controller = PageController();
      _scrollController.addListener(_onScroll);
      _LoadFilteredItems();

      _boxSubscription = boxMoneyData.watch().listen((event) {
        if(mounted) {
          _resetAndLoadItems();
        }
      });
    }
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _boxSubscription.cancel();
    super.dispose();
  } 

  @override
  Widget build(BuildContext context){
    final visibleItems = _getVisibleItems();
    final hasMore = _page * _pageSize < _filteredItems.length;

    final colors = Theme.of(context).colorScheme; 
    final textTheme = Theme.of(context).textTheme; 
    final extra = Theme.of(context).extension<AppExtraColors>()!; 
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth > 1020 ? screenWidth * 2/3 : screenWidth*.6,
                    decoration: BoxDecoration(
                      //border: Border.all(color: Colors.grey),
                      border: Border.all(color: extra.border), 
                      borderRadius: BorderRadius.circular(10),
                      //color: Colors.lightBlue[50],
                      color: colors.primary, 
                    ),
                    child: MaterialButton(
                      onPressed: pickDateRange,
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month,color: colors.onSurface), 
                        Flexible(
                          child: Text(
                            '${dateRange.start.year}-${dateRange.start.month}-${dateRange.start.day}'
                            ' ~ '
                            '${dateRange.end.year}-${dateRange.end.month}-${dateRange.end.day}',
                            style: textTheme.bodyMedium?.copyWith(
                                color: colors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            ),
                        ),
                        IconButton(
                          icon:Icon(Icons.delete),
                          onPressed: (){_ShowDeleteConfirmationDialog(context);},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        )
                      ],
                    ),
                    )
                  ),
                  
                ],
              ),
      
              SizedBox(
                height: 200,
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index){
                    setState((){
                      _currentPage = index;
                      _resetAndLoadItems();
                    });
                  },
                  children: [
                    CardOfDetailRecord(colorCard: colorsOfCards[0], typeCard: typesOfCards[0],dateRange: dateRange),
                    CardOfDetailRecord(colorCard: colorsOfCards[1], typeCard: typesOfCards[1],dateRange: dateRange),
                    CardOfDetailRecord(colorCard: colorsOfCards[2], typeCard: typesOfCards[2],dateRange: dateRange),
                    CardOfDetailRecord(colorCard: colorsOfCards[3], typeCard: typesOfCards[3],dateRange: dateRange),
                    CardOfDetailRecord(colorCard: colorsOfCards[4], typeCard: typesOfCards[4],dateRange: dateRange),
                  ],
                  
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                count: 5,
                effect: SwapEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  //activeDotColor: Colors.blue,
                  //dotColor: Colors.grey,
                   activeDotColor: colors.primary, 
                  dotColor: extra.border, 
                ),
              ),
              
              //Expanded(
                //child: 
                _filteredItems.isEmpty ?
                Center(
                  child: Text("無相關紀錄",style: textTheme.bodyMedium?.copyWith(color: extra.subText,)),  
                ) :
                
      
                Padding(
                  padding: const EdgeInsets.only(top:10.0),
                  child: TapRegion(
                    onTapOutside: (_) {
                      if (selectionMode) {
                        clearSelection();
                      }
                    },
                    child: Column(
                      children: [
                        selectionMode?
                        ListTile(
                          leading: Icon(Icons.money),
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
                            icon:Icon(Icons.delete),
                            onPressed: (){
                              _ShowDeleteConfirmationDialog(context,indexlist:selectedIndexes);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                        ) : SizedBox.shrink(), 
                        //Expanded(
                          //child: 
                          SizedBox(
                            //height: 200,
                            child: PopScope(
                              canPop: !selectionMode,
                              onPopInvokedWithResult: (didPop, result) {
                                if (!didPop && selectionMode) {
                                  clearSelection();
                                }
                              },
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: visibleItems.length + (_isLoading ? 1 : 0) + (hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if(_isLoading && hasMore && index == visibleItems.length){
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            CircularProgressIndicator(color: colors.primary, ),
                                            Text("載入中...",style: textTheme.bodySmall?.copyWith(color: extra.subText, ),),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                              
                                  if(hasMore && index == visibleItems.length + (_isLoading ? 1 : 0)){
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.4,
                                          height: MediaQuery.of(context).size.height > 500?MediaQuery.of(context).size.height * 0.05 : MediaQuery.of(context).size.height * 0.1,
                                          child: ElevatedButton.icon(
                                              icon: Icon(Icons.download),
                                              onPressed: _loadNextPage,
                                              label: AutoSizeText(
                                                "載入更多",
                                                minFontSize: 10,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                ),
                                              style: ElevatedButton.styleFrom(
                                                      //backgroundColor: Colors.blue,
                                                      backgroundColor: colors.primary,
                                                      //foregroundColor: Colors.white,
                                                      foregroundColor: colors.onPrimary,
                                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                                                      shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                            )
                                            )),
                                        ),
                                      ),
                                    );
                                  }
                                              
                                  if(index < visibleItems.length){
                                    final filteredItem = visibleItems[index];
                                    final isSelected = selectedIndexes.contains(filteredItem.key);
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
                                          onLongPress: () => startSelection(filteredItem.key),
                                          onTap: () {
                                            if (selectionMode) {
                                              toggleSelection(filteredItem.key);
                                            } else {
                                              // 正常 click 行為
                                            }
                                          },
                                          title: OneRecordCard(
                                            type: filteredItem.data.typeCost,
                                            name: filteredItem.data.nameCost,
                                            amount: filteredItem.data.amountCost,
                                            date: filteredItem.data.dateCost,
                                            keyIndex: filteredItem.originalIndex,
                                          ),
                                        ),
                                        //SizedBox(height: 10,),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                              
                            ),
                          ),
                        //),
                    
                      ],
                    ),
                  ),
                ),
                //),
                  
            ],
          ),
        
      ),
    );
  }
}

class FilteredItem {
  final MoneyData data;
  final int originalIndex;
  final dynamic key;
  FilteredItem(this.data, this.originalIndex, this.key);
}