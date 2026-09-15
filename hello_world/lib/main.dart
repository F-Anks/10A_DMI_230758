import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello_world_app/presentation/screens/counter/counter_functions_screen.dart';

const Color counterZeroColor = Color.fromARGB(255, 7, 164, 255);
const Color counterPositiveColor = Colors.green;
const Color counterNegativeColor = Colors.red;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 208, 33, 243),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.comicNeue(
            fontSize: 160,
            fontWeight: FontWeight.w100,
          ),
        ),
      ),
      home: const CounterFunctionsScreen(),
    );
  }
}