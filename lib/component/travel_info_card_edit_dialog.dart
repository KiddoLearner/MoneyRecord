import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';
import 'package:self_made_app/common_use/common_use.dart';

class TravelInfoCardEditDialog extends StatefulWidget {
  final String initialName;
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final String initialLocation;
  final List<String> initialPartners;
  final int keyNumber;
  final String currency;
  final double rate;
  TravelInfoCardEditDialog({
    super.key,
    required this.initialName,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.initialLocation,
    required this.initialPartners,
    required this.keyNumber,
    required this.currency,
    required this.rate
    });

  @override
  State<TravelInfoCardEditDialog> createState() => _TravelInfoCardEditDialogState();
  
}

class _TravelInfoCardEditDialogState extends State<TravelInfoCardEditDialog> {

  //Form Settings
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;

  late DateTime travelStartDate;
  late DateTime travelEndDate;

  //Rate & Currency Settings
  late TextEditingController _rate_controller;
  late TextEditingController _currency_controller;


  //Partner Settings
  late List<String> _travel_partners = [];
  final List<TextEditingController> _partnerControllers = [];
  final List<FocusNode> _partnerFocusNodes = [];
  final List<bool> _partnerAbleButton = [];
  final List<String> _newAddPartnerName = [];
  final List<String> _savedPartnerNames = [];
  late List<TravelMoneyRecord> newRecords = TravelboxMoneyData.get(widget.keyNumber).travelMoneyRecords;

  void _addPartnerField() {
    if(_partnerControllers.isEmpty || _partnerControllers.last.text.isNotEmpty) {
      setState(() {
      final focusNode =FocusNode();
      final controller = TextEditingController();
      final bool flag = true;
      focusNode.addListener(() {
        if(!focusNode.hasFocus){
          final index = _partnerFocusNodes.indexOf(focusNode);
          if( _partnerControllers[index].text.isEmpty && _partnerAbleButton[index] == false){
            //_removePartnerField(index);
            _deletePartnerField(index);
          }
        }
      });

      _partnerControllers.add(controller);
      _partnerFocusNodes.add(focusNode);
      _partnerAbleButton.add(flag);
      _savedPartnerNames.add('');

      WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
    });
    }
  }

  void _deletePartnerField(int index){
    if (index < 0 || index >= _partnerControllers.length) return;

  final deletedName = _savedPartnerNames[index].trim();

  // 先更新 newRecords，將 separateCost 入面呢個 partner 移除
  if (deletedName.isNotEmpty) {
    final updatedRecords = newRecords.map((record) {
      final newSeparateCost = Map<String, PaidMoney>.from(record.separateCost);
      newSeparateCost.remove(deletedName);

      return TravelMoneyRecord(
        typeCost: record.typeCost,
        nameCost: record.nameCost,
        amountCost: record.amountCost,
        dateCost: record.dateCost,
        separateCost: newSeparateCost,
        currency: record.currency,
        whoPaid: record.whoPaid
      );
    }).toList();

    newRecords = updatedRecords;
  }

  // 再刪 UI field
  _removePartnerField(index);
  }

  void _removePartnerField(int index) {
    if(index < 0 || index >= _partnerControllers.length) return;
    final controller = _partnerControllers[index];
    final focusNode = _partnerFocusNodes[index];

    setState(() {
      _partnerControllers.removeAt(index);
      _partnerFocusNodes.removeAt(index);
      _partnerAbleButton.removeAt(index);
      _savedPartnerNames.removeAt(index);
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
      focusNode.dispose();
  });
  }

  void _initPartnerList(){
    for (var partner in widget.initialPartners) {
      final controller = TextEditingController(text: partner);
      final focusNode = FocusNode();
      final flag = false;
      focusNode.addListener(() {
        if(!focusNode.hasFocus){
          final index = _partnerFocusNodes.indexOf(focusNode);
          if( _partnerControllers[index].text.isEmpty){
            _removePartnerField(index);
          }
        }
      });
      _travel_partners.add(partner);
      _partnerControllers.add(controller);
      _partnerFocusNodes.add(focusNode);
      _partnerAbleButton.add(flag);
      _savedPartnerNames.add(partner);
    }
    
    
  }

Future<void> _deleteTravelRecord(int keyNumber) async{
    await TravelboxMoneyData.delete(keyNumber);
    if(mounted){
    //   Navigator.of(context).pop();
    //   Future.delayed(Duration(milliseconds: 100), () {
    //   if (mounted) {
    //     Navigator.pushNamedAndRemoveUntil(context, '/travel_page', (route) => false);
    //   }
    // });
    Navigator.pushNamedAndRemoveUntil(context, '/travel_page', (route) => false);
    //Navigator.of(context).pop('deleted');
    }
    
  }

  void _change_partner_name (String original_name, String new_name){
    final temp_for_update_name = TravelboxMoneyData.get(widget.keyNumber);
    if(temp_for_update_name == null) return;
    final ready_to_newRecords = <TravelMoneyRecord>[];
    for(var temp in temp_for_update_name.travelMoneyRecords){
      final newSeparateCost = Map<String, PaidMoney>.from(temp.separateCost);
      if(newSeparateCost.containsKey(original_name) && original_name != null){
        newSeparateCost[new_name] = newSeparateCost[original_name]!;
        newSeparateCost.remove(original_name);
      }
      else if((original_name == '' || original_name == null) && new_name.isNotEmpty){
        PaidMoney addNew = PaidMoney(amountPaid: 0, isPaid: true);
        newSeparateCost[new_name] = addNew;
      }
      ready_to_newRecords.add(
        TravelMoneyRecord(
          typeCost: temp.typeCost,
          nameCost: temp.nameCost,
          amountCost: temp.amountCost,
          currency: temp.currency,
          dateCost: temp.dateCost,
          separateCost: newSeparateCost,
          whoPaid: temp.whoPaid)
      );
    }

    newRecords = ready_to_newRecords;

   
  }

  void _change_currency(String changedCurrency){
    for(var record in newRecords){
      if(record.currency == widget.currency){
        record.currency = changedCurrency.toUpperCase();
      }
    }
  }

  void _ShowDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("確認刪除"),
          content: Text("確定要刪除此筆記錄嗎？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog first
                _deleteTravelRecord(widget.keyNumber);
              },
              child: Text("刪除", style: TextStyle(color: Colors.red),),
            ),
          ],
        );
      },
    );
  }
  bool get isButtonEnabled => _partnerAbleButton.contains(true);

  bool _isPartnerListSame(List<String> initPartners, List<String> currentPartners){
    if(initPartners.length != currentPartners.length) return false;
    
    return Set.from(initPartners).difference(Set.from(currentPartners)).isEmpty &&
         Set.from(currentPartners).difference(Set.from(initPartners)).isEmpty;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _locationController = TextEditingController(text: widget.initialLocation);
    _currency_controller = TextEditingController(text: widget.currency);
    _rate_controller = TextEditingController(text: widget.rate.toString());
    travelStartDate = widget.initialStartDate;
    travelEndDate = widget.initialEndDate;
    _initPartnerList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    for (var controller in _partnerControllers) {
    controller.dispose();
  }
  for (var focusNode in _partnerFocusNodes) {
    focusNode.dispose();
  }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool snackbar_msg = false;
    String? dialogErrMsg;
    return StatefulBuilder(
      builder: (BuildContext dialogContext, StateSetter setDialogState){
          return AlertDialog(
          title: Text('編輯旅行資訊'),
          content: Container(
            width: MediaQuery.of(context).size.width * 1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey),
              color: Colors.grey[200],
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  child:
                      TextFormField(
                          // controller: _nameController..text = widget.initialName, //change later
                        controller: _nameController,
                        style: TextStyle(color: Colors.black),
                        maxLength: 20,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: '旅行名稱',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: '旅行名稱',
                          // filled: true,
                          // fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[600]!,  
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
        
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return '請輸入旅行名稱';
                          }
                          return null;
                        },
                      ),
                  ),
        
                SizedBox(height: 10,),
        
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: InputDecorator(
                      decoration: InputDecoration(
                      labelText: '旅行日期',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[600]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final DateTimeRange? newDateRange = await pickDateRange(
                            context,
                            DateTimeRange( /// 改返個date做initial value
                              start: widget.initialStartDate,
                              end: widget.initialEndDate,
                            ),
                          );
                          if (newDateRange != null && 
                              (newDateRange.start != widget.initialStartDate || newDateRange.end != widget.initialEndDate)) {
                            setState(() {
                              travelStartDate = newDateRange.start;
                              travelEndDate = newDateRange.end;
                            });
                          }
                        },
                        child: Text(
                            travelStartDate.toLocal().toIso8601String().split('T').first
                            + " - "
                            + travelEndDate.toLocal().toIso8601String().split('T').first, //change later
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                    )
                    )
                    
                  )
                ),
        
                SizedBox(height: 10,),
        
                Container(
                  padding: EdgeInsets.all(8.0),
                  child:
                      TextFormField(
                          // controller: _locationController..text = widget.initialLocation, //change later
                          controller: _locationController,
                          style: TextStyle(color: Colors.black),
                        maxLength: 20,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: '旅行地點',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: '旅行地點',
                          // filled: true,
                          // fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[600]!,  
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return '請輸入旅行地點';
                          }
                          return null;
                        },
                      ),
                  ),
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: InputDecorator(
                      decoration: InputDecoration(
                      labelText: '貨幣匯率',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[600]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        child: Row(
                          children: [
                            Text(
                              '1',
                              style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(width: 10,),
                            Expanded(
                              child: TextFormField(
                                maxLength: 30,
                                controller: _currency_controller,
                                decoration: InputDecoration(
                                  hintText: "貨幣",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  counterText: '',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: Colors.grey),
                                  ),
                                  errorStyle: TextStyle(
                                    fontSize: 10,
                                    //height: 0.01,
                                  ),
                                ),
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return '請輸入貨幣';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text(
                              ':',style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: TextFormField(
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                ],
                                maxLength: 30,
                                controller: _rate_controller,
                                decoration: InputDecoration(
                                  hintText: "匯率",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  counterText: '',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: Colors.grey),
                                  ),
                                  errorStyle: TextStyle(
                                    fontSize: 10,
                                    //height: 0.01,
                                  ),
                                ),
                                validator: (value){
                                  if(value == null || value.isEmpty || double.tryParse(value) == null){
                                    return '請輸入匯率';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text('港幣',style: TextStyle(fontSize: 18),)
                          ],
                      ),
                    )
                    )
                    
                  )
                ),
                SizedBox(height: 10,),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 400,
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '同行人士',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[600]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                          ..._partnerControllers.asMap().entries.map((entry){
                            int index = entry.key;
                            TextEditingController controller = entry.value;
                            String temp_for_check = controller.text;
                            if(temp_for_check == "我"){
                              return SizedBox.shrink();
                            }
                            
                            //print('testing the temp name if works on creating: ' + temp_for_check);
                            return
                            Column(
                            children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    readOnly: !_partnerAbleButton[index],
                                    style: const TextStyle(color: Colors.black),
                                    controller: controller,
                                    focusNode: _partnerFocusNodes[index],
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      counterText: '',
                                      // filled: true,
                                      // fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                        // color: Colors.grey[600]!,
                                        width: 2,
                                        ),
                                      ),
                                      
                                      ),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                SizedBox(
                                  width: 50,
                                  child: _partnerAbleButton[index] ? 
                                    Row(
                                      children: [
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap:(){
                                              // if(controller.text != temp_for_check && controller.text.isNotEmpty){
                                              //   _change_partner_name(temp_for_check, controller.text);
                                              // }
                                                final oldName = _savedPartnerNames[index];
                                                final newName = controller.text.trim();
        
                                                if (newName != oldName && newName.isNotEmpty) {
                                                  _change_partner_name(oldName, newName);
                                                  _savedPartnerNames[index] = newName;
                                                }
        
                                              setState(() {
                                                _partnerAbleButton[index] = false;
                                                //check_all_button();
                                              });
                                              
                                            },
                                            child: Icon(Icons.check_box,color: Colors.green),
                                          )
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap:(){
                                              //print('button test');
                                              //_removePartnerField(index);
                                              _deletePartnerField(index);
                                            },
                                            child: Icon(Icons.delete, color: Colors.red),
                                          )
                                        )
                                      ]
                                    )
                                  :
                                  Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap:(){
                                          setState(() {
                                            _partnerAbleButton[index] = true;
                                            //check_all_button();
                                          });
                                        },
                                        child: Icon(Icons.edit),
                                    )
                                  )
                                  ),
                                ]),
                                SizedBox(height: 10,)
                            ]);
                          }).toList(),
                          if (dialogErrMsg != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            dialogErrMsg!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                          Container(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.zero
                              ),
                              onPressed: _addPartnerField,
                              icon: Icon(Icons.add),
                              label: Text('新增同行人士',
                                style: TextStyle(fontSize: 14, color: Colors.black),),
                            ),
                          ),
                          ],
                      
                        ),
                      ),
                    ),
                ),
              ],
            ),
            ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: 
              isButtonEnabled ? 
              null:
              () {
                String password = 'Failed';
                List<String> input_travel_partners = _partnerControllers
                      .map((controller) => controller.text)
                      .where((name) => name.isNotEmpty)
                      .toList();
        
                if(_formKey.currentState!.validate() == false || _nameController.text.isEmpty || _locationController.text.isEmpty || _currency_controller.text.isEmpty || _rate_controller.text.isEmpty || double.tryParse(_rate_controller.text) == null){
                        return;
                }
        
                _travel_partners = _partnerControllers
                  .map((controller) => controller.text.trim())
                  .where((name) => name.isNotEmpty)
                  .toList();
        
                final seenName = <String>{};
                String? duplicatedName;
                for (final name in _travel_partners) {
                  if (seenName.contains(name)) {
                    duplicatedName = name;
                    break;
                  }
                  seenName.add(name);
                }
        
                if (duplicatedName != null) {
                  setDialogState(() {
                    dialogErrMsg = '❌ 不能有重覆名稱！';
                  });
                  return;
                } else {
                  setDialogState(() {
                    dialogErrMsg = null;
                  });
                }
                final partnerListChanged = _isPartnerListSame(_travel_partners, input_travel_partners);
                  if (_nameController.text != widget.initialName
                    || _locationController.text != widget.initialLocation
                    || travelStartDate != widget.initialStartDate
                    || travelEndDate != widget.initialEndDate
                    || _currency_controller.text != widget.currency
                    || double.tryParse(_rate_controller.text) != widget.rate
                    || partnerListChanged
                    ) {
                      TravelMoneyData? value = TravelboxMoneyData.get(widget.keyNumber);
                      if(value != null){
                        if(_currency_controller.text != widget.currency)
                          _change_currency(_currency_controller.text);
                        final TravelMoneyData editedValue = TravelMoneyData(
                          nameOfTrip: _nameController.text,
                          startDateOfTrip: travelStartDate,
                          endDateOfTrip: travelEndDate,
                          placeOfTrip: _locationController.text,
                          partnersOfTrip: input_travel_partners,
                          travelMoneyRecords: newRecords,
                          currency: _currency_controller.text.toUpperCase(),
                          rate: double.parse(_rate_controller.text),
                        );
                        TravelboxMoneyData.put(widget.keyNumber, editedValue);
                        password = "Edited";
                      }
                      Navigator.of(context).pop({
                        'name': _nameController.text,
                        'startDate': travelStartDate,
                        'endDate': travelEndDate,
                        'location': _locationController.text,
                        'partners': input_travel_partners,
                        'currency': _currency_controller,
                        'rate': double.parse(_rate_controller.text),
                        'Result': password
                    });
                      
                    }
                    else{
                      Navigator.of(context).pop();
                    }
                },
              child: Text('保存'),
            ),
            TextButton(
              onPressed: () {
                _ShowDeleteConfirmationDialog(context);
                
              },
              child: Text('刪除', style: TextStyle(color: Colors.red),
            )),
          ],
        );
      },
    );
  }
}