import 'package:flutter/material.dart';

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
          displayLarge: GoogleFonts.rockSalt(
            fontSize: 160,
            fontWeight: FontWeight.w100,
          ),
        ),
      ),
      home: const CounterFunctionsScreen(),
    );
  }
}