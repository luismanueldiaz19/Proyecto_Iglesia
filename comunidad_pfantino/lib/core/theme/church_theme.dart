import 'package:flutter/material.dart';

import 'church_colors.dart';

final ThemeData churchTheme = ThemeData(
  useMaterial3: true,

  textTheme: const TextTheme(
    // Títulos grandes: "¿A dónde vas?"
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    ),
    // Nombres de vehículos y precios: "UberX", "$250"
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),

    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight:
          FontWeight.w500, // Medium, para darle más presencia que un bodyMedium
      letterSpacing: 0.1,
      color: Color(
        0xFF0B2E6B,
      ), // Puedes usar tu azul principal o un Colors.black87
    ),

    // Direcciones y botones
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    // Tiempo estimado (ETA) y descripciones
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.black54, // Un gris oscuro para restar peso visual
    ),
    // Matrícula del conductor, pequeñas notas
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
    ),
  ),
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

  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.white,
    headerBackgroundColor: ChurchColors.primary,
    headerForegroundColor: Colors.white,
    // El color de fondo del rango seleccionado será un azul muy suave y transparente
    rangeSelectionBackgroundColor: ChurchColors.primary.withValues(alpha: 0.1),
    // El color de los días seleccionados (inicio y fin)
    dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ChurchColors.primary;
      }
      return null;
    }),
    dayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return ChurchColors.black;
    }),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: ChurchColors.primary,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0B2E6B),
      foregroundColor: Colors.white,
      // Bordes redondeados suaves
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // 50px de alto por defecto (el ancho será automático según el contenido o el contenedor)
      minimumSize: const Size(0, 50),

      // Aplicando tu paleta de colores corporativa
      // backgroundColor: const Color(0xFF0B2E6B),
      // foregroundColor: Colors.white,

      // Sin sombra para un diseño más limpio y moderno (Material 3)
      elevation: 0,

      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),

      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  // elevatedButtonTheme: ElevatedButtonThemeData(
  //   style: ElevatedButton.styleFrom(
  //     // // 50px de alto y ancho completo por defecto
  //     // minimumSize: const Size(double.infinity, 50),

  //     // // Aplicando tu paleta de colores corporativa
  //     // backgroundColor: const Color(0xFF0B2E6B),
  //     // foregroundColor: Colors.white,

  //     // // Sin sombra para un diseño más limpio y moderno (Material 3)
  //     // elevation: 0,

  //     // textStyle: const TextStyle(
  //     //   fontSize: 16,
  //     //   fontWeight: FontWeight.w600,
  //     //   letterSpacing: 0.5,
  //     // ),

  //     // // Bordes redondeados suaves
  //     // shape: RoundedRectangleBorder(
  //     //   borderRadius: BorderRadius.circular(12),
  //     // ),
  //   ),
);
