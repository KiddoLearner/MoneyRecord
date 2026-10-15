import 'package:flutter/material.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/DataSource/MoneySource.dart';
import 'package:self_made_app/common_use/common_use.dart';
import 'package:self_made_app/color_theme/app_color.dart';


class MoneyRecordPage extends StatefulWidget {
  const MoneyRecordPage({super.key});

  @override
  State<MoneyRecordPage> createState() => _MoneyRecordPageState();
}

class _MoneyRecordPageState extends State<MoneyRecordPage>{
  String chosenType = '衣著';
  DateTime chosenDate = DateTime.now();
  late String datepickerName = '${chosenDate.year}-${chosenDate.month}-${chosenDate.day}';
  var typesOfCost = ['衣著','飲食','交通','娛樂','其他'];

  late TextEditingController nameController;
  late TextEditingController amountController;
  @override
  void initState(){
    super.initState();
    nameController = TextEditingController();
    amountController = TextEditingController();
  }

  @override
  void dispose(){
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context); 
    final colors = theme.colorScheme; 
    final textTheme = theme.textTheme; 
    final extra = theme.extension<AppExtraColors>()!;

    void showADatePicker(){
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900), 
        lastDate: DateTime(2100)
        ).then((value){
          if(value != null){
            chosenDate = value;
            print(chosenDate.toString());
            setState(() {
            datepickerName = '${value.year}-${value.month}-${value.day}';
          });
          }
        });
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('新增記錄', style: textTheme.titleLarge?.copyWith(color: colors.onPrimary, ),),
        //backgroundColor: Colors.blueAccent,
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(
          color: colors.onPrimary, 
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          
                //種類dropdown
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    //color: Colors.grey[200],
                    color: extra.cardSoft,
                    border: Border.all(
                        color: extra.border, 
                      ),
                  ),
                  padding: EdgeInsets.all(20),
                  //height: 300,
                  child: Row(
                    children: [
                      Text('種類: ', style: TextStyle(color: colors.onSurface, ),),
                      SizedBox(width: 20,),
                      DropdownButton(
                        value: chosenType,
                        underline: SizedBox(),
                        style: TextStyle(color: colors.onSurface, fontSize: 15),
                        icon: Icon(Icons.keyboard_arrow_down, color: colors.onSurface, ),
                        dropdownColor: colors.surface, 
                        items: typesOfCost.map((String items) {
                          return DropdownMenuItem(value: items, child: Row(
                            children: [
                              Text(items,style: TextStyle(color: colors.onSurface, ),),
                              Icon(typeIcon(items), color: colors.onSurface,),
                            ],
                          ));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            chosenType = newValue!;
                            print(chosenType);
                          });
                        },
                      )
                    ],
                  ),
                ),
          
                SizedBox(height: 20,),
          
                //名稱textfield
                Container(decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    //color: Colors.grey[200],
                    color: extra.cardSoft, 
                    border: Border.all(color: extra.border,), 
                  ),
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(color: colors.onSurface,), 
                          maxLength: 20,
                          decoration: InputDecoration(
                            labelText: '項目名稱',
                            border: OutlineInputBorder()
                          ),
                          validator: (value) {
                            if(value == null || value.isEmpty){
                              return '請輸入項目名稱';
                            }
                            return null;
                          },
                          controller: nameController,
                        ),
                      ),
                    ],
                  ),
                ),
          
                SizedBox(height: 20,),
          
          
                //金錢textfield
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    //color: Colors.grey[200],
                    color: extra.cardSoft,
                    border: Border.all(color: extra.border,),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(color: colors.onSurface,),
                          decoration: InputDecoration(
                            prefixText: 'HK\$',
                            prefixStyle: TextStyle(color: extra.subText,),
                            labelText: '金額',
                            border: OutlineInputBorder()
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if(value == null || value.isEmpty || ((double.tryParse(value) == null && int.tryParse(value) == null))){
                              return '請輸入金額';
                            }
                            return null;
                          },
                          controller: amountController,
                        ),
                      ),
                    ],
                  ),
                ),
          
                SizedBox(height: 20,),
          
                //日期Picker，預設今日
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    //color: Colors.grey[200],
                    color: extra.cardSoft, 
                    border: Border.all(color: extra.border,),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      MaterialButton(onPressed: showADatePicker,
                      child: Row(
                        children: [
                          Text("$datepickerName ", style: TextStyle(color: colors.onSurface),),
                          Icon(Icons.calendar_month, color: colors.onSurface,),
                        ],
                      ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(onPressed: (){
                         if (_formKey.currentState!.validate()){ //Check係咪所有textformfield都岩
                          MoneySource.instance.createMoneyData(
                            chosenType,
                            nameController.text.toString(),              
                            double.parse(amountController.text),
                            chosenDate
                          );
                          setState(() {
                           
                          });
                          Navigator.pop(context);
                         }
                        
                        },
                        //color: Colors.blueAccent,
                        color: colors.primary, 
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), 
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('新增', style: TextStyle(color: colors.onPrimary),),
                          ),
                        ),
                      MaterialButton(
                        onPressed: (){
                        Navigator.pop(context);},
                        //color: Colors.white,
                        color: colors.surface, 
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: extra.border, ),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('返回', style: TextStyle(color: colors.onSurface),),
                            ),)
                  ],
                ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
