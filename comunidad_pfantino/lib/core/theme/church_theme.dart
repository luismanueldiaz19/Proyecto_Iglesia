import 'package:flutter/material.dart';

import 'church_colors.dart';

final ThemeData churchTheme = ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: ChurchColors.primary,
    onPrimary: Colors.white,

    secondary: ChurchColors.gold,
    onSecondary: Colors.white,

    surface: ChurchColors.background,
    onSurface: ChurchColors.black,

    error: Colors.red,
    onError: Colors.white,
  ),

  scaffoldBackgroundColor: ChurchColors.background,

  appBarTheme: const AppBarTheme(
    backgroundColor: ChurchColors.primary,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ChurchColors.gold,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
