import 'package:flutter/material.dart';
import 'package:sourdough_app/pages/bread_calculator.dart';
import 'package:sourdough_app/pages/starter_calculator.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 64.0),
          child: StarterCalculator(),
        ),
        BreadCalculator(),
      ],
    );
  }
}
