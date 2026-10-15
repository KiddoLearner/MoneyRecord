import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData getTheme(AppFlavorTheme flavor) {
    switch (flavor) {
      case AppFlavorTheme.daily:
        return _buildDailyTheme();
      case AppFlavorTheme.travel:
        return _buildTravelTheme();
    }
  }

  static ThemeData _buildDailyTheme() {
    const scheme = ColorScheme.light(
      primary: DailyPalette.primary,
      onPrimary: Colors.white,
      secondary: DailyPalette.summaryCard,
      onSecondary: DailyPalette.text,
      surface: DailyPalette.surface,
      onSurface: DailyPalette.text,
      error: Color(0xFFD96C5F),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DailyPalette.background,
      cardColor: DailyPalette.surface,
      dividerColor: DailyPalette.border,
      canvasColor: DailyPalette.background,
      extensions: const [
        AppExtraColors(
          cardSoft: DailyPalette.softSurface,
          summaryCard: DailyPalette.summaryCard,
          border: DailyPalette.border,
          borderStrong: DailyPalette.borderStrong, 
          subText: DailyPalette.subText,
          fabShadow: DailyPalette.fabShadow,
          chart1: DailyPalette.chart1,
          chart2: DailyPalette.chart2,
          chart3: DailyPalette.chart3,
        ),
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: DailyPalette.background,
        foregroundColor: DailyPalette.text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: DailyPalette.surface,
        elevation: 2,
        shadowColor: DailyPalette.fabShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: DailyPalette.border),
        ),
      ),
      dialogTheme: DialogThemeData( 
        backgroundColor: DailyPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: DailyPalette.border),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DailyPalette.primary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DailyPalette.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DailyPalette.text,
          backgroundColor: DailyPalette.surface,
          side: const BorderSide(color: DailyPalette.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData( 
        style: TextButton.styleFrom(
          foregroundColor: DailyPalette.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DailyPalette.softSurface,
        hintStyle: const TextStyle(color: DailyPalette.subText),
        labelStyle: const TextStyle(color: DailyPalette.subText),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: DailyPalette.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: DailyPalette.primary, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DailyPalette.surface,
        selectedItemColor: DailyPalette.primary,
        unselectedItemColor: DailyPalette.subText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: DailyPalette.text, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: DailyPalette.text, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: DailyPalette.text),
        bodyMedium: TextStyle(color: DailyPalette.text),
        bodySmall: TextStyle(color: DailyPalette.subText),
      ),
    );
  }

  static ThemeData _buildTravelTheme() {
    const scheme = ColorScheme.light(
      primary: TravelPalette.primary,
      onPrimary: Colors.white,
      secondary: TravelPalette.summaryCard,
      onSecondary: TravelPalette.text,
      surface: TravelPalette.surface,
      onSurface: TravelPalette.text,
      error: Color(0xFFD96C5F),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: TravelPalette.background,
      cardColor: TravelPalette.surface,
      dividerColor: TravelPalette.border,
      canvasColor: TravelPalette.background,
      extensions: const [
        AppExtraColors(
          cardSoft: TravelPalette.softSurface,
          summaryCard: TravelPalette.summaryCard,
          border: TravelPalette.border,
          borderStrong: TravelPalette.borderStrong, 
          subText: TravelPalette.subText,
          fabShadow: TravelPalette.fabShadow,
          chart1: TravelPalette.chart1,
          chart2: TravelPalette.chart2,
          chart3: TravelPalette.chart3,
        ),
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: TravelPalette.background,
        foregroundColor: TravelPalette.text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: TravelPalette.surface,
        elevation: 2,
        shadowColor: TravelPalette.fabShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: TravelPalette.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: TravelPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: TravelPalette.border),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: TravelPalette.primary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TravelPalette.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TravelPalette.text,
          backgroundColor: TravelPalette.surface,
          side: const BorderSide(color: TravelPalette.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData( 
        style: TextButton.styleFrom(
          foregroundColor: TravelPalette.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TravelPalette.softSurface,
        hintStyle: const TextStyle(color: TravelPalette.subText),
        labelStyle: const TextStyle(color: TravelPalette.subText),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TravelPalette.borderStrong), 
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TravelPalette.primary, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TravelPalette.surface,
        selectedItemColor: TravelPalette.primary,
        unselectedItemColor: TravelPalette.subText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: TravelPalette.text, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: TravelPalette.text, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: TravelPalette.text),
        bodyMedium: TextStyle(color: TravelPalette.text),
        bodySmall: TextStyle(color: TravelPalette.subText),
      ),
    );
  }
}