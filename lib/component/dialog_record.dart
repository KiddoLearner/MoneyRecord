import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/DataSource/MoneySource.dart';
import 'package:self_made_app/color_theme/app_color.dart';
import 'package:self_made_app/common_use/common_use.dart';

class DialogRecord extends StatefulWidget {
  final String type;
  final String name;
  final double amount;
  final DateTime date;
  final int keyIndex;

  const DialogRecord({
    super.key,
    required this.type,
    required this.name,
    required this.amount,
    required this.date,
    required this.keyIndex,
  });

  @override
  State<DialogRecord> createState() => _DialogRecordState();
}

class _DialogRecordState extends State<DialogRecord> {
  late TextEditingController nameController;
  late TextEditingController amountController;

  late String chosenType;
  late DateTime chosenDate;
  late String datepickerName;

  final _formKey = GlobalKey<FormState>();

  // 你的種類清單
  final List<String> typesOfCost = ['衣著', '飲食', '交通', '娛樂', '其他'];

  AutoSizeText autoSizeText(
    String text, {
    double size = 16,
    TextStyle textStyle = const TextStyle(),
    int maxLines = 1,
  }) {
    return AutoSizeText(
      text,
      style: textStyle.copyWith(
        color: textStyle.color ?? Colors.black,
        fontSize: size,
      ),
      minFontSize: 8,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    amountController = TextEditingController(text: widget.amount.toString());
    chosenType = typesOfCost.contains(widget.type) ? widget.type : typesOfCost.first;
    chosenDate = widget.date;
    datepickerName = '${chosenDate.year}-${chosenDate.month}-${chosenDate.day}';
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _deleteRecord(int index) async {
    await boxMoneyData.deleteAt(index);
    MoneySource.instance.modifyRecord();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showDeleteConfirmationDialog(BuildContext parentContext) {
    final colors = Theme.of(parentContext).colorScheme;
    final extra = Theme.of(parentContext).extension<AppExtraColors>();

    if (extra == null) return;

    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: extra.border),
          ),
          title: Text(
            "確認刪除",
            style: TextStyle(color: colors.onSurface),
          ),
          content: Text(
            "確定要刪除此筆記錄嗎？",
            style: TextStyle(color: extra.subText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                "取消",
                style: TextStyle(color: colors.primary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteRecord(widget.keyIndex);
              },
              child: Text(
                "刪除",
                style: TextStyle(color: colors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _changeRecordData( String type, String name,double amount,DateTime date,int index,) {
    final updated = MoneyData(
      typeCost: type,
      nameCost: name,
      amountCost: amount,
      dateCost: date,
    );

    boxMoneyData.putAt(index, updated);
    MoneySource.instance.modifyRecord();
  }

  // 統一輸入框樣式，避免重複寫
  InputDecoration _inputDecoration({required AppExtraColors extra,required ColorScheme colors,required String label,String? hint,String? prefixText,}) {
    return InputDecoration(
      counterText: '',
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      fillColor: colors.surface,
      labelStyle: TextStyle(color: extra.subText),
      hintStyle: TextStyle(color: extra.subText),
      prefixStyle: TextStyle(color: extra.subText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: extra.borderStrong,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colors.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double dialogWidth = screenWidth > 600 ? 420 : screenWidth * 0.82;

    //Color Settings
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final extra = theme.extension<AppExtraColors>();

    if (extra == null) {
      return const AlertDialog(
        content: Text('AppExtraColors 未設定'),
      );
    }

    Future<void> showADatePicker() async {
      final value = await showDatePicker(
        context: context,
        initialDate: chosenDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );

      if (value != null) {
        setState(() {
          chosenDate = value;
          datepickerName = '${value.year}-${value.month}-${value.day}';
        });
      }
    }

    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: extra.border),
      ),
      title: Text("詳細資料",style: textTheme.titleLarge?.copyWith(color: colors.onSurface),),
      content: SizedBox(
        width: dialogWidth,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: extra.border),
            borderRadius: BorderRadius.circular(20),
            color: extra.cardSoft,
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /* =============種類 dropdown============ */
                InputDecorator(
                  decoration: _inputDecoration(
                    label: '種類',
                    extra: extra,
                    colors: colors,
                  ),
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
              

                const SizedBox(height: 8),

                /// =========================
                /// 名稱
                /// =========================
                TextFormField(
                  controller: nameController,
                  style: TextStyle(color: colors.onSurface),
                  maxLength: 20,
                  decoration: _inputDecoration(
                    extra: extra,
                    colors: colors,
                    label: '項目名稱',
                    hint: '項目名稱',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入項目名稱';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                /// =========================
                /// 金額
                /// =========================
                TextFormField(
                  controller: amountController,
                  style: TextStyle(color: colors.onSurface),
                  maxLength: 20,
                  decoration: _inputDecoration(
                    extra: extra,
                    colors: colors,
                    label: '價錢',
                    prefixText: 'HK\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        ((double.tryParse(value) == null &&
                            int.tryParse(value) == null))) {
                      return '請輸入正確金額';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                /// =========================
                /// 日期
                /// =========================
                InputDecorator(
                  decoration: _inputDecoration(
                    label: '種類',
                    extra: extra,
                    colors: colors,
                  ),
                  child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      backgroundColor: colors.surface,
                      foregroundColor: colors.onSurface,
                      side: BorderSide(color: extra.borderStrong),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    onPressed: showADatePicker,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          datepickerName,
                          style: TextStyle(color: colors.onSurface),
                        ),
                        Icon(
                          Icons.calendar_month,
                          color: colors.onSurface,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),),
                
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (nameController.text != widget.name ||
                  double.parse(amountController.text) != widget.amount ||
                  chosenType != widget.type ||
                  chosenDate != widget.date) {
                _changeRecordData(
                  chosenType,
                  nameController.text,
                  double.parse(amountController.text),
                  chosenDate,
                  widget.keyIndex,
                );
              }
              Navigator.of(context).pop();
            }
          },
          child: Text(
            "儲存",
            style: TextStyle(color: colors.primary),
          ),
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