import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';
import 'package:self_made_app/common_use/common_use.dart';

class TravelDialogCreateSingleConsumption extends StatefulWidget {
  final List<String> partnerNames;
  final int keyNumber;
  const TravelDialogCreateSingleConsumption({super.key,required this.partnerNames, required this.keyNumber});

  @override
  State<TravelDialogCreateSingleConsumption> createState() => _TravelDialogCreateSingleConsumption();
}

class _TravelDialogCreateSingleConsumption extends State<TravelDialogCreateSingleConsumption> {
  
  //Form Settings
  final _formKey = GlobalKey<FormState>();
  String _typeOfConsumption = '衣著';
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late List<String> _currencyKind;
  late String _currencyChose;
  late DateTime _consumeDate;
  final List<TextEditingController> _partnerControllers = [];
  final List<TextEditingController> _partnerAmounts = [];
  final List<FocusNode> _partnerAmountsFN = [];
  final List<bool> _partnerCheckboxes = [];
  final List<bool> _partnerPaid = [];
  
  String temp_for_focus_amount = "";

  void _initPartnerList(){
    for (var partner in widget.partnerNames) {
      final controller = TextEditingController(text: partner);
      final node = FocusNode();
      final amountController = TextEditingController(text: '0');
      node.addListener((){
        if(node.hasFocus){
          temp_for_focus_amount = amountController.text;
          if(temp_for_focus_amount == "0")
            amountController.text = '';
        }
        if(!node.hasFocus){
          if(amountController.text.isEmpty){
            if(temp_for_focus_amount != "0")
              amountController.text = temp_for_focus_amount;
            else
              amountController.text = '0';
          }
          temp_for_focus_amount = "0";
        }
      });
      _partnerControllers.add(controller);
      _partnerAmounts.add(amountController);
      _partnerAmountsFN.add(node);
      _partnerCheckboxes.add(false);
      _partnerPaid.add(false);
    }
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

  @override
  void initState(){
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _consumeDate = DateTime.now();
    _initPartnerList();
    //Dropdownmenu of curreny
    String currency = TravelboxMoneyData.get(widget.keyNumber).currency;
    _currencyChose = currency;
    _currencyKind = [currency,"HKD"];
    _partnerPaid[0] = true;
    _partnerCheckboxes[0] = true;
  }

  @override
  void dispose(){
    _nameController.dispose();
    _amountController.dispose();
    for (var controller in _partnerControllers) {
      controller.dispose();
    }
    for (var amountController in _partnerAmounts) {
      amountController.dispose();
    } 
    for(var node in _partnerAmountsFN){
      node.dispose();
    }
    super.dispose();
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
                  int paidIndex = _partnerPaid.indexWhere((data)=> data == true);
                  setState(() {
                    if(paidIndex != -1){
                      _partnerPaid[paidIndex] = false;                    
                    }
                    if(paidIndex != index){
                      _partnerPaid[index] = true;
                      _partnerCheckboxes[index] = true;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 520.0 : screenWidth * 0.88;

    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        title: Text('建立單筆消費'),
        content: SingleChildScrollView(
          child: Container(
            width: dialogWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey),
              color: Colors.grey[200],
            ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: EdgeInsets.all(8.0),
                    child: InputDecorator(
                       decoration: _inputDecoration('消費類型'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isDense: true,
                          isExpanded: true,
                          value: _typeOfConsumption,
                          //underline: SizedBox(),
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: typesOfCards.map((String items) {
                            return DropdownMenuItem(value: items, child: Row(
                              children: [
                                Expanded(child: Text(items,overflow: TextOverflow.ellipsis,)),
                                const SizedBox(width: 8),
                                Icon(typeIcon(items), color: Colors.black,),
                              ],
                            ));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _typeOfConsumption = newValue!;
                            });
                          },
                        ),
                      )
                      //)
                      ),
                  ),
                  _currencyKind[0] == _currencyKind[1] ? SizedBox() : //Avoid Dropdownlist crash
                  
                Container(
                  padding: EdgeInsets.all(8.0),
                  child:TextFormField(
                          controller: _nameController, //change later
                          style: TextStyle(color: Colors.black),
                        maxLength: 20,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: '消費名稱',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: '消費名稱',
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
                            return '請輸入消費名稱';
                          }
                          return null;
                        },
                      )
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: InputDecorator(
                      decoration: _inputDecoration('貨幣'),
                      child:Material(
                      color: Colors.transparent,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isDense: true,
                          isExpanded: true,
                          value: _currencyChose,
                          underline: SizedBox(),
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: _currencyKind.map((String items) {
                            return DropdownMenuItem(value: items, child: Row(
                              children: [
                                Expanded(child: Text(items,overflow: TextOverflow.ellipsis,)),
                              ],
                            ));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _currencyChose = newValue!;
                            });
                          },
                        ),
                      )
                      )
                      ),
                  ),
                  Container(
                  padding: EdgeInsets.all(8.0),
                  child:TextFormField(
                          controller: _amountController, //change later
                          style: TextStyle(color: Colors.black),
                        maxLength: 20,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: '消費金額',
                          prefixText: '\$',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: '消費金額',
                          enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[600]!,  
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')), // 允許數字同小數點
                        ],
                        onChanged: (value) {
                          _partnerAmounts[0].text = value;
                        },
                        validator: (value){
                          if(value == null || value.isEmpty || ((double.tryParse(value) == null && int.tryParse(value) == null)) || double.tryParse(value) == 0){
                            return '請輸入非\$0的消費金額';
                          }
                          return null;
                        },
                      )
                  ),
                  //Date
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: InputDecorator(
                      decoration: _inputDecoration('消費日期'),
                      child:Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final DateTime? newDate = await showADatePicker(
                            context,
                            DateTime.now(),
                          );
                          if (newDate != null) {
                            setState(() {
                              _consumeDate = newDate;
                            });
                          }
                        },
                        child: Text(
                            _consumeDate.toLocal().toIso8601String().split('T').first,
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          )
                       ) ,
                      )
                      ),
                  ),
                  if(widget.partnerNames.length>1)
                  Container(
                    padding: EdgeInsets.all(8),
                    child: InputDecorator(
                      decoration: _inputDecoration('分單消費'),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                             children: [
                              ..._partnerControllers.asMap().entries.map((entry){
                                int index = entry.key;
                                //TextEditingController controller = entry.value;
                                return _buildPartnerCard(index);
                              }).toList(),
                             ],
                          
                        ),
                            ),
                      )
                      ),
                  )
              ],
            ),
          ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    final box = TravelboxMoneyData.get(widget.keyNumber);
                    final Map<String, PaidMoney> separateCost = {};
                    final int paidIndex = _partnerPaid.indexWhere((data)=> data == true);
                    final String personPaid = paidIndex == -1 ? '我' : widget.partnerNames[paidIndex];
                    for(int i = 0; i < widget.partnerNames.length; i++){
                      bool checkZero = (double.parse(_partnerAmounts[i].text) == 0 || double.tryParse(_partnerAmounts[i].text) == null) ? true : _partnerCheckboxes[i];
                      final PaidMoney paidMoney = PaidMoney(
                        amountPaid: _partnerAmounts[i].text.contains('.') ? double.parse(_partnerAmounts[i].text) : int.parse(_partnerAmounts[i].text).toDouble(),
                        isPaid: checkZero,
                      );
                      separateCost[_partnerControllers[i].text] = paidMoney;
                    }

                    bool passChangeRecord = true; //Used for checking if the user okay with the 3 following conditions
                    if(_partnerAmounts.every((element)=>double.tryParse(element.text) == 0)){
                      passChangeRecord = await showConfirmDialog(context, "目前分單消費全部都是\$0。");
                    }
                    else if(_partnerAmounts.fold(0.0, (sum,record)=>sum + (double.tryParse(record.text) ?? 0)) != double.tryParse(_amountController.text)){
                      passChangeRecord = await showConfirmDialog(context, "目前分單消費總數與消費金額不同。");
                    }
                    if(_partnerPaid.every((element) => element == false) && context.mounted){
                      passChangeRecord = await showConfirmDialog(context, "目前分單消費沒有點選「埋單」，將預設為「我」埋單。");
                      //personPaid = "我";
                    }
                    if(passChangeRecord && context.mounted){
                      final TravelMoneyRecord newRecord = TravelMoneyRecord(
                        typeCost: _typeOfConsumption, 
                        nameCost: _nameController.text, 
                        amountCost: _amountController.text.contains('.') ? double.parse(_amountController.text) : int.parse(_amountController.text).toDouble(), 
                        dateCost: _consumeDate,
                        separateCost: separateCost,
                        currency: _currencyChose,
                        whoPaid: personPaid
                        );
                      List<TravelMoneyRecord> updatedRecords = List.from(box.travelMoneyRecords);
                      updatedRecords.add(newRecord);
                      box.travelMoneyRecords = updatedRecords;
                      TravelboxMoneyData.put(widget.keyNumber, box);
                      Navigator.of(context).pop();
                    }
                    
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('新增',overflow: TextOverflow.fade,style: TextStyle(color: Colors.blue[500]),),
              ),
              SizedBox(width: 10,),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('取消',overflow: TextOverflow.fade,style: TextStyle(color: Colors.red[500])),
              ),
            ],
          ),
        ],
      );
  }
}