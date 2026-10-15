import 'package:flutter/material.dart';

enum AppFlavorTheme {
  daily,
  travel,
}

@immutable
class AppExtraColors extends ThemeExtension<AppExtraColors> {
  final Color cardSoft;
  final Color summaryCard;
  final Color border;
  final Color borderStrong;
  final Color subText;
  final Color fabShadow;
  final Color chart1;
  final Color chart2;
  final Color chart3;

  const AppExtraColors({
    required this.cardSoft,
    required this.summaryCard,
    required this.border,
    required this.borderStrong,
    required this.subText,
    required this.fabShadow,
    required this.chart1,
    required this.chart2,
    required this.chart3,
  });

  @override
  AppExtraColors copyWith({
    Color? cardSoft,
    Color? summaryCard,
    Color? border,
    Color? borderStrong,
    Color? subText,
    Color? fabShadow,
    Color? chart1,
    Color? chart2,
    Color? chart3,
  }) {
    return AppExtraColors(
      cardSoft: cardSoft ?? this.cardSoft,
      summaryCard: summaryCard ?? this.summaryCard,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      subText: subText ?? this.subText,
      fabShadow: fabShadow ?? this.fabShadow,
      chart1: chart1 ?? this.chart1,
      chart2: chart2 ?? this.chart2,
      chart3: chart3 ?? this.chart3,
    );
  }

  @override
  AppExtraColors lerp(ThemeExtension<AppExtraColors>? other, double t) {
    if (other is! AppExtraColors) return this;
    return AppExtraColors(
      cardSoft: Color.lerp(cardSoft, other.cardSoft, t)!,
      summaryCard: Color.lerp(summaryCard, other.summaryCard, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      subText: Color.lerp(subText, other.subText, t)!,
      fabShadow: Color.lerp(fabShadow, other.fabShadow, t)!,
      chart1: Color.lerp(chart1, other.chart1, t)!,
      chart2: Color.lerp(chart2, other.chart2, t)!,
      chart3: Color.lerp(chart3, other.chart3, t)!,
    );
  }
}

class DailyPalette {
  static const background = Color(0xFFFAF6F1);
  static const surface = Color(0xFFFFFDFC);
  static const softSurface = Color(0xFFF3ECE4);
  static const primary = Color(0xFFC78B6B);
  static const primaryDark = Color(0xFFA96D4E);
  static const text = Color(0xFF3A312C);
  static const subText = Color(0xFF85756C);
  static const border = Color(0xFFE6D9CF);
  static const borderStrong = Color(0xFFB89F90);
  static const summaryCard = Color(0xFFF1E3D6);
  static const fabShadow = Color(0x33A96D4E);

  static const chart1 = Color(0xFFC78B6B);
  static const chart2 = Color(0xFFD8A48F);
  static const chart3 = Color(0xFFE8CFC2);
}

class TravelPalette {
  static const background = Color(0xFFF4F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const softSurface = Color(0xFFEAF0F5);
  static const primary = Color(0xFF5B7C99);
  static const primaryDark = Color(0xFF45657F);
  static const text = Color(0xFF243342);
  static const subText = Color(0xFF6B7C8C);
  static const border = Color(0xFFD8E1E8);
  static const borderStrong = Color(0xFF93A7B8);
  static const summaryCard = Color(0xFFDCE7F0);
  static const fabShadow = Color(0x3345657F);

  static const chart1 = Color(0xFF5B7C99);
  static const chart2 = Color(0xFF7F9BB3);
  static const chart3 = Color(0xFFB7C8D6);
}

extension AppThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  AppExtraColors get extraColors => Theme.of(this).extension<AppExtraColors>()!;
}