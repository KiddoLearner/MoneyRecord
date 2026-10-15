import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';
import 'package:self_made_app/common_use/common_use.dart';

class TravelOneRecordCardEdit extends StatefulWidget {
  final String type;
  final String name;
  final double amount;
  final String currency;
  final List<String> currencyList;
  final DateTime date;
  final int keyIndex;
  final int listKeyIndex;
  final Map<String, PaidMoney> separatedMap;
  final String whoPaid;

  const TravelOneRecordCardEdit({
    super.key,
    required this.type,
    required this.name,
    required this.amount,
    required this.currency,
    required this.currencyList,
    required this.date,
    required this.keyIndex,
    required this.listKeyIndex,
    required this.separatedMap,
    required this.whoPaid
  });

  @override
  State<TravelOneRecordCardEdit> createState() => _TravelOneRecordCardEdit();
}

class _TravelOneRecordCardEdit extends State<TravelOneRecordCardEdit> {
  late String chosenType;
  late TextEditingController nameController;
  late TextEditingController amountController;
  late DateTime _consumeDate;

  final List<TextEditingController> _partnerControllers = [];
  final List<TextEditingController> _partnerAmounts = [];
  final List<FocusNode> _partnerAmountsFN = [];
  final List<bool> _partnerCheckboxes = [];
  final List<bool> _partnerPaid = [];
  String whoPaid = "";

  String temp_for_focus_amount = "";

  late String _currencyChose;
  late List<String> _currencyKind;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    amountController = TextEditingController(text: widget.amount.toString());

    if (widget.separatedMap.isNotEmpty) {
      for (var data in widget.separatedMap.entries) {
        _partnerControllers.add(TextEditingController(text: data.key));
        _partnerAmounts.add(
          TextEditingController(text: data.value.amountPaid.toString()),
        );
        
        
        _partnerCheckboxes.add(data.value.isPaid);
        _partnerPaid.add(false);
      }
      int index = _partnerControllers.indexWhere((name)=>name.text == widget.whoPaid);
      if(index != -1){
        _partnerPaid[index] = true;
        _partnerCheckboxes[index] = true;
        whoPaid = _partnerControllers[index].text;
      }

      for(var data in _partnerAmounts){
        final node = FocusNode();
        node.addListener((){
        if(node.hasFocus){
          temp_for_focus_amount = data.text;
          if(double.tryParse(temp_for_focus_amount) == 0.0)
            data.text = '';
        }
        if(!node.hasFocus){
          if(data.text.isEmpty){
            if(double.tryParse(temp_for_focus_amount) != 0.0)
              data.text = temp_for_focus_amount;
            else
              data.text = '0';
          }
          temp_for_focus_amount = "0";
        }
      });
      _partnerAmountsFN.add(node);
      }
    }

    chosenType = widget.type;
    _consumeDate = widget.date;
    _currencyChose = widget.currency;
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();

    for (final controller in _partnerControllers) {
      controller.dispose();
    }
    for (final controller in _partnerAmounts) {
      controller.dispose();
    }
    for (final focusNode in _partnerAmountsFN) {
      focusNode.dispose();
    }

    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      counterText: '',
      label: Text(label,overflow: TextOverflow.ellipsis,),
      labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
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
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.blueGrey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _deleteRecord(int index) {
    final newWholeRecord = TravelboxMoneyData.get(widget.keyIndex);
    newWholeRecord.travelMoneyRecords.removeAt(index);
    TravelboxMoneyData.put(widget.keyIndex, newWholeRecord);
    Navigator.of(context).pop();
  }

  void _showDeleteConfirmationDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("確認刪除"),
          content: const Text("確定要刪除此筆記錄嗎？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteRecord(widget.listKeyIndex);
              },
              child: const Text(
                "刪除",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _changeRecordData(
    String type,
    String name,
    double amount,
    String currency,
    DateTime date,
    int index,
    Map<String, PaidMoney> separatedMap,
    String whoPaid,
  ) {
    final newWholeRecord = TravelboxMoneyData.get(widget.keyIndex);
    final updated = TravelMoneyRecord(
      typeCost: type,
      nameCost: name,
      amountCost: amount,
      currency: currency,
      dateCost: date,
      separateCost: separatedMap,
      whoPaid: whoPaid,
    );
    newWholeRecord.travelMoneyRecords[index] = updated;
    TravelboxMoneyData.put(widget.keyIndex, newWholeRecord);
  }

  //分單既widget
  Widget _buildPartnerCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _partnerControllers[index].text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: (){
                  int paidIndex =  _partnerPaid.indexWhere((data)=> data == true);
                  setState(() {
                    if(paidIndex != -1){
                      _partnerPaid[paidIndex] = false;
                      whoPaid = "";               
                    }
                    if(paidIndex != index){
                      _partnerPaid[index] = true;
                      _partnerCheckboxes[index] = true;
                      whoPaid = _partnerControllers[index].text;
                    }
                  });
                }, 
                icon: Icon(Icons.payment),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Colors.blue.withValues(alpha: 0.2),
                  foregroundColor: _partnerPaid[index]? Colors.blue:Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                label: Text('埋單',overflow: TextOverflow.ellipsis,),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _partnerAmounts[index],
                  focusNode: _partnerAmountsFN[index],
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: '金額',
                    prefixText: '\$',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        width: 2,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  validator: (value){
                    if(value == null || value == ""){
                      return "請輸入金額";
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '已付',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  Checkbox(
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: _partnerCheckboxes[index],
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      setState(() {
                        _partnerCheckboxes[index] = newValue;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

//Show Dialog if all checkboxes are unchecked || all consume $ =\= amount || all consume $ = 0
Future<bool> showConfirmDialog(BuildContext context, String errMsg) async{
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      //insetPadding: EdgeInsets.all(4),
      title: Text("請確定以下訊息"),
      content: SingleChildScrollView(
        child: Text("$errMsg \n若直接儲存或會影響欠款處理，你確定要儲存嗎?"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('確定'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消',style: TextStyle(color: Colors.red),),
        ),
      ],
    ),
  );
  return result?? false;
}

  @override
  Widget build(BuildContext context) {
    _currencyKind = widget.currencyList;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 520.0 : screenWidth * 0.88;

    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      title: const Text("詳細資料"),
      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[200],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: InputDecorator(
                        decoration: _inputDecoration('消費類型'),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isDense: true,
                            isExpanded: true,
                            value: chosenType,
                            style: const TextStyle(color: Colors.black, fontSize: 15),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: typesOfCards.map((String items) {
                              return DropdownMenuItem<String>(
                                value: items,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        items,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(typeIcon(items), color: Colors.black),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue == null) return;
                              setState(() {
                                chosenType = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.black),
                        maxLength: 20,
                        decoration: _inputDecoration('消費名稱').copyWith(
                          hintText: '消費名稱',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '請輸入消費名稱';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_currencyKind.length >= 2 &&
                        _currencyKind[0] != _currencyKind[1])
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: InputDecorator(
                          decoration: _inputDecoration('貨幣'),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isDense: true,
                              isExpanded: true,
                              value: _currencyChose,
                              style: const TextStyle(color: Colors.black, fontSize: 15),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: _currencyKind.map((String items) {
                                return DropdownMenuItem<String>(
                                  value: items,
                                  child: Text(
                                    items,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue == null) return;
                                setState(() {
                                  _currencyChose = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: amountController,
                        style: const TextStyle(color: Colors.black),
                        maxLength: 20,
                        decoration: _inputDecoration('消費金額').copyWith(
                          prefixText: '\$',
                          hintText: '消費金額',
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                        ],
                        onChanged: (value) {
                          _partnerAmounts[0].text = value;
                        },
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty || 
                              ((double.tryParse(value) == null &&
                                  int.tryParse(value) == null)) ||
                              double.tryParse(value) == 0
                              ) {
                            return '請輸入非\$0的消費金額';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: InputDecorator(
                        decoration: _inputDecoration('消費日期'),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () async {
                              final DateTime? newDate = await showADatePicker(
                                context,
                                _consumeDate,
                              );
                              if (newDate != null) {
                                setState(() {
                                  _consumeDate = newDate;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                _consumeDate
                                    .toLocal()
                                    .toIso8601String()
                                    .split('T')
                                    .first,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_partnerControllers.length > 1)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: InputDecorator(
                          decoration: _inputDecoration('分單消費'),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 320),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ..._partnerControllers.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    return _buildPartnerCard(index);
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async{
            bool passChangeRecord = true; //Used for checking if the user okay with the 3 following conditions
            if (_formKey.currentState!.validate()) {
              bool checkChange = false;
              int index = 0;

              for (var data in widget.separatedMap.entries) {
                if (_partnerAmounts[index].text !=
                        data.value.amountPaid.toString() ||
                    _partnerCheckboxes[index] != data.value.isPaid) {
                  checkChange = true;
                }
                index++;
              }

              if (nameController.text != widget.name ||
                  double.parse(amountController.text) != widget.amount ||
                  chosenType != widget.type ||
                  _consumeDate != widget.date ||
                  checkChange ||
                  _currencyChose != widget.currency ||
                  widget.whoPaid != whoPaid) {
                Map<String, PaidMoney> newSeparatedMap = {};

                for (int i = 0; i < _partnerControllers.length; i++) {
                  bool checkZero = (double.parse(_partnerAmounts[i].text) == 0 || double.tryParse(_partnerAmounts[i].text) == null) ? true : _partnerCheckboxes[i];
                  newSeparatedMap[_partnerControllers[i].text] = PaidMoney(
                    amountPaid: double.tryParse(_partnerAmounts[i].text) ?? 0.0,
                    isPaid: checkZero
                  );
                }
                if(_partnerAmounts.every((element)=>double.tryParse(element.text) == 0)){
                  passChangeRecord = await showConfirmDialog(context, "目前分單消費全部都是\$0。");
                }
                else if(_partnerAmounts.fold(0.0, (sum,record)=>sum + (double.tryParse(record.text) ?? 0)) != double.tryParse(amountController.text)){
                  passChangeRecord = await showConfirmDialog(context, "目前分單消費總數與消費金額不同。");
                }
                if(_partnerPaid.every((element) => element == false) && context.mounted){
                  passChangeRecord = await showConfirmDialog(context, "目前分單消費沒有點選「埋單」，將預設為「我」埋單。");
                  whoPaid = "我";
                }
                if(passChangeRecord && context.mounted){
                  _changeRecordData(
                    chosenType,
                    nameController.text,
                    double.parse(amountController.text),
                    _currencyChose,
                    _consumeDate,
                    widget.listKeyIndex,
                    newSeparatedMap,
                    whoPaid
                  );
                }
              }
              if(passChangeRecord && context.mounted){
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text("儲存"),
        ),
        TextButton(
          onPressed: () {
            _showDeleteConfirmationDialog(context);
          },
          child: const Text(
            "刪除",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}