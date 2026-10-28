import 'package:flutter/material.dart';

const colorList = <Color>[
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.purple,
  Colors.deepPurple,
  Colors.orange,
  Colors.pink,
  Colors.pinkAccent,
];

const themeNames = <String>[
  'Azul Clásico',
  'Verde Azulado (Teal)',
  'Verde Esmeralda',
  'Púrpura Vibrante',
  'Púrpura Profundo',
  'Naranja Cálido',
  'Rosa Suave',
  'Rosa Neón (Accent)',
];

String getLogoPath(int index) {
  if (index <= 0) return 'assets/images/logo.jpg';
  if (index >= 7) return 'assets/images/logo8.jpg';
  return 'assets/images/logo${index + 1}.jpg';
}

class AppTheme {
  final int selectedColor;
  final bool isDarkmode;

  AppTheme({
    this.selectedColor = 0,
    this.isDarkmode = false,
  })  : assert(selectedColor >= 0, 'Selected color must be greater or equal to 0'),
        assert(selectedColor < colorList.length,
            'Selected color must be less or equal than ${colorList.length - 1}');

  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        brightness: isDarkmode ? Brightness.dark : Brightness.light,
        colorSchemeSeed: colorList[selectedColor],
        appBarTheme: const AppBarTheme(centerTitle: false),
      );

  AppTheme copyWith({
    int? selectedColor,
    bool? isDarkmode,
  }) =>
      AppTheme(
        selectedColor: selectedColor ?? this.selectedColor,
        isDarkmode: isDarkmode ?? this.isDarkmode,
      );
}
