import 'package:flutter/material.dart';

/// Colores de interfaz basados en las fechas/temporadas de CinePedia
/// (solo cambian el tema visual de la app, no el icono ni el splash).
const List<Color> seasonThemeColors = [
  Color(0xFF0088CC), // 0: Normal (Azul Cine)
  Color(0xFFC1121F), // 1: Navidad
  Color(0xFFD97706), // 2: Día Mundial del Cine
  Color(0xFFE91E63), // 3: San Valentín
  Color(0xFFFF6D00), // 4: Halloween
  Color(0xFF7209B7), // 5: Aniversario
];

class AppTheme {
  final int selectedColor;
  final bool isDarkmode;

  const AppTheme({
    this.selectedColor = 0,
    this.isDarkmode = true,
  });

  ThemeData getTheme() {
    final safeIndex = selectedColor.clamp(0, seasonThemeColors.length - 1);
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkmode ? Brightness.dark : Brightness.light,
      colorSchemeSeed: seasonThemeColors[safeIndex],
    );
  }

  AppTheme copyWith({
    int? selectedColor,
    bool? isDarkmode,
  }) =>
      AppTheme(
        selectedColor: selectedColor ?? this.selectedColor,
        isDarkmode: isDarkmode ?? this.isDarkmode,
      );
}
