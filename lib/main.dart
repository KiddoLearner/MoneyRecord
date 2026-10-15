import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:self_made_app/DataSource/MoneySource.dart';
import 'package:self_made_app/color_theme/app_color.dart';
import 'package:self_made_app/color_theme/app_theme.dart';
import 'package:self_made_app/pages/backup_page.dart';
import 'package:self_made_app/pages/home_page.dart';
import 'package:self_made_app/pages/travel_page.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Boxes/box_money.dart';

//手動reset hive database
void clearMoneyBox() async {
  await boxMoneyData.clear();
}

//手動reset travel hive
void cleaerTravelMoneyBox() async{
  await TravelboxMoneyData.clear();
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  //initalize the hive
  await Hive.initFlutter();
  Hive.registerAdapter(MoneyDataAdapter());
  Hive.registerAdapter(TravelMoneyDataAdapter());
  Hive.registerAdapter(TravelMoneyRecordAdapter());
  Hive.registerAdapter(PaidMoneyAdapter());
  //open the box
  boxMoneyData = await Hive.openBox<MoneyData>('MoneySource');
  TravelboxMoneyData = await Hive.openBox<TravelMoneyData>('TravelMoneySource');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
  runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'TW'), 
        Locale('zh', 'HK'), 
      ],
      locale: const Locale('zh', 'HK'), 

      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(AppFlavorTheme.daily),

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },

      //home: HomePage(),
      home:Theme(
        data: AppTheme.getTheme(AppFlavorTheme.daily),
        child: const HomePage()
      ),

      routes: {
        '/home_page': (context) =>Theme(
          data: AppTheme.getTheme(AppFlavorTheme.daily),
          child: const HomePage()
        ),

        '/travel_page' : (context) => Theme(
          data: AppTheme.getTheme(AppFlavorTheme.travel),
          child: const TravelPage()
        ),
        '/backup_page' : (context) => Theme(
          data: AppTheme.getTheme(AppFlavorTheme.daily),
          child: const BackupPage()
        ),
      },
      );
  }
}

