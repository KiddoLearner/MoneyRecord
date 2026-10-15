import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';
import 'package:self_made_app/color_theme/app_color.dart';
import 'package:self_made_app/color_theme/app_theme.dart';
import 'package:self_made_app/common_use/common_use.dart';
import 'package:self_made_app/pages/travel_money_record.dart';

class TravelDialogCreateRecord extends StatefulWidget {
  const TravelDialogCreateRecord({
    super.key,
  });

  @override
  State<TravelDialogCreateRecord> createState() => _TravelDialogCreateRecordState();
}




class _TravelDialogCreateRecordState extends State<TravelDialogCreateRecord> {
  late TextEditingController _travel_name_controller;
  late TextEditingController _date_controller;
  late DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(Duration(days: 7)),
  );
  late TextEditingController _travel_place_controller;
  late List<String> _travel_partners;

  final List<TextEditingController> _partnerControllers = [];
  final List<FocusNode> _partnerFocusNodes = [];

  //Rate & Currency Setting
  late TextEditingController _rate_controller;
  late TextEditingController _currency_controller;

  void _addPartnerField() {
    if(_partnerControllers.isEmpty || _partnerControllers.last.text.isNotEmpty) {
      setState(() {
      final focusNode =FocusNode();
      final controller = TextEditingController();
      focusNode.addListener(() {
        if(!focusNode.hasFocus){
          final index = _partnerFocusNodes.indexOf(focusNode);
          if( _partnerControllers[index].text.isEmpty){
            _removePartnerField(index);
          }
        }
      });

      _partnerControllers.add(controller);
      _partnerFocusNodes.add(focusNode);
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    });
    }
  }

  void _removePartnerField(int index) {
    if(index < 0 || index >= _partnerControllers.length) return;

    final controller = _partnerControllers[index];
    final focusNode = _partnerFocusNodes[index];

      setState(() {
      
      _partnerControllers.removeAt(index);
      _partnerFocusNodes.removeAt(index);
    });
    

    WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.dispose();
    focusNode.dispose();
  });
  }

TextFormField textFormField(
  TextEditingController txtCtrler, bool numberInput,{int maxLength = 100,String hint = '',FocusNode? focusNode,}) {
  return TextFormField(
    maxLength: maxLength,
    controller: txtCtrler,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color:Colors.black,fontSize: 10),
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
    ),
    keyboardType: numberInput? TextInputType.numberWithOptions(decimal: true):null,
    inputFormatters: numberInput?[
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
    ]:null,
    focusNode: focusNode,
  );
}
Flexible txtFlex(String txt,{double size = 18}){
  return Flexible(
    child: Text(
      txt,
      style: TextStyle(fontSize: size),
      overflow: TextOverflow.ellipsis,
    ),
  );
}

@override
void initState() {
  super.initState();
  _travel_name_controller = TextEditingController(); 
  _travel_place_controller = TextEditingController();
  _currency_controller = TextEditingController();
  _rate_controller = TextEditingController();
  _date_controller = TextEditingController(text:
      '${_dateRange.start.year}/${_dateRange.start.month}/${_dateRange.start.day} - '
      '${_dateRange.end.year}/${_dateRange.end.month}/${_dateRange.end.day}',);
}

@override
void dispose() {
  _travel_name_controller.dispose();
  _travel_place_controller.dispose();
  _currency_controller.dispose();
  _rate_controller.dispose();
  _date_controller.dispose();
  for (var controller in _partnerControllers) {
    controller.dispose();
  }
  for (var focusNode in _partnerFocusNodes) {
    focusNode.dispose();
  }
  super.dispose();
}
  
  final _formKey = GlobalKey<FormState>();
  
@override
Widget build(BuildContext context) {
  bool snackbarMsg = false;
  String? dialogErrMsg;

  return StatefulBuilder(
    builder: (BuildContext dialogContext, StateSetter setDialogState) {
      final media = MediaQuery.of(dialogContext);
      final maxDialogWidth = media.size.width > 500 ? 420.0 : media.size.width * 0.9;

      Widget buildLabel(String text) {
        return Text(
          text,
          style: const TextStyle(fontSize: 17),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      }

      Widget buildFormRow({required String label,required Widget child,
        CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
      }) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Expanded(
                flex: 3,
                child: buildLabel(label),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 7,
                child: child,
              ),
            ],
          ),
        );
      }

      Widget buildInput(
        TextEditingController controller,
        bool numberInput, {
        int maxLength = 100,
        String hint = '',
        FocusNode? focusNode,
        String? errMsg
      }) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLength: maxLength,
          keyboardType: numberInput
              ? const TextInputType.numberWithOptions(decimal: true)
              : null,
          inputFormatters: numberInput
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),]
              : null,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                width: 1.5,
                color: Colors.grey,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          validator: (value){
            if((value == null || value.isEmpty) && (errMsg != null || errMsg != "")){
              return "請輸入$errMsg";
            }
            return null;
          },
        );
      }

      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        title: const Text(
          '建立新紀錄',
          textAlign: TextAlign.center,
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxDialogWidth,
            maxHeight: media.size.height * 0.72,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildFormRow(
                    label: '旅行名稱：',
                    child: buildInput(
                      _travel_name_controller,
                      false,
                      maxLength: 20,
                      errMsg: '旅行名稱'
                    ),
                  ),
                  buildFormRow(
                    label: '旅行日期：',
                    child: TextFormField(
                      readOnly: true,
                      controller: _date_controller,
                      onTap: () async {
                        final DateTimeRange? newDateRange = await pickDateRange(
                          context,
                          _dateRange,
                        );
                        if (newDateRange != null) {
                          setState(() {
                            _dateRange = newDateRange;
                            _date_controller.text =
                                '${_dateRange.start.year}/${_dateRange.start.month}/${_dateRange.start.day} - '
                                '${_dateRange.end.year}/${_dateRange.end.month}/${_dateRange.end.day}';
                          });
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        counterText: '',
                        suffixIcon: const Icon(Icons.calendar_month),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            width: 1.5,
                            color: Colors.grey,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        filled: true,
                        //fillColor: Colors.white,
                      ),
                    ),
                   
                  ),
                  buildFormRow(
                    label: '旅行地點：',
                    child: buildInput(
                      _travel_place_controller,
                      false,
                      maxLength: 30,
                      errMsg: "旅行地點"
                    ),
                  ),
                  buildFormRow(
                    label: '貨幣匯率：',
                    crossAxisAlignment: CrossAxisAlignment.start,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: Text('1'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: buildInput(
                            _currency_controller,
                            false,
                            maxLength: 10,
                            hint: '貨幣',
                            errMsg: "貨幣"
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: Text(':'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: buildInput(
                            _rate_controller,
                            true,
                            maxLength: 10,
                            hint: '匯率',
                            errMsg: "匯率"
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: Text(
                            '港幣',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  buildFormRow(
                    label: '同行人士：',
                    crossAxisAlignment: CrossAxisAlignment.start,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ..._partnerControllers.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final controller = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: buildInput(
                                      controller,
                                      false,
                                      maxLength: 20,
                                      focusNode: _partnerFocusNodes[index],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _addPartnerField,
                            icon: const Icon(Icons.add),
                            label: const Text('新增同行人士'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        if (_travel_name_controller.text.isEmpty ||
                            _travel_place_controller.text.isEmpty ||
                            _currency_controller.text.isEmpty ||
                            _rate_controller.text.isEmpty ||
                            double.tryParse(_rate_controller.text) == null) {
                          const errMsg = "請填寫旅行名稱、地點、貨幣及有效匯率";
                          if (!snackbarMsg) {
                            snackbarMsg = true;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  errMsg,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                            Timer(const Duration(seconds: 4), () {
                              if (mounted) {
                                setState(() {
                                  snackbarMsg = false;
                                });
                              }
                            });
                          }
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
                            dialogErrMsg = '❌不能有重覆名稱！';
                          });
                          return;
                        } else {
                          setDialogState(() {
                            dialogErrMsg = null;
                          });
                        }

                        final keyNumber = await TravelMoneySource().createTravelMoneyData(
                          _travel_name_controller.text,
                          _dateRange.start,
                          _dateRange.end,
                          _travel_place_controller.text,
                          _travel_partners,
                          currency: _currency_controller.text.toUpperCase(),
                          rate: double.parse(_rate_controller.text),
                        );

                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Theme(
                              data: AppTheme.getTheme(AppFlavorTheme.travel),
                              child: TravelMoneyRecordPage(RecordKey: keyNumber),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('建立'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
}