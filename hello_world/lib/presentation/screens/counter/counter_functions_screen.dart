import 'package:flutter/material.dart';

class CounterFunctionsScreen extends StatefulWidget {
  const CounterFunctionsScreen({super.key});

  @override
  State<CounterFunctionsScreen> createState() => _CounterFunctionsScreenState();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Functions'),
        actions: [
        IconButton(
          icon: Icon( Icons.refresh_rounded),
          onPressed: () {
            setState(() {
              clickCounter = 0;
            });
          },
        ),
        ],
      ),
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text(
              '$clickCounter',
              style: GoogleFonts.comicNeue(
                fontSize: 160,
                fontWeight: FontWeight.w100,
                color: _getCounterColor(clickCounter),
              ),
            ),
            Text(
              "Click${ clickCounter > 1 ? 's' : '' }",
              style: const TextStyle(fontSize: 25),
            ),
            ],
          ),
        )
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            onPressed: () {
              setState(() {
                clickCounter += 1;
              });
            },
            icon: Icons.plus_one,
          ),
          SizedBox(height: 16),
          CustomButton(
            icon: Icons.remove,
            onPressed: () {
              setState(() {
                clickCounter -= 1;
              });
            },
          ),
          SizedBox(height: 16),
          CustomButton(
            onPressed: () {
              setState(() {
                clickCounter = 0;
              });
            },
            icon: Icons.refresh_outlined,
          ),
        ],
      )
    );
  }
}

