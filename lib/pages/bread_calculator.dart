import 'package:flutter/material.dart';

class BreadCalculator extends StatefulWidget {
  const BreadCalculator({super.key});

  @override
  State<BreadCalculator> createState() => _BreadCalculatorState();
}

class _BreadCalculatorState extends State<BreadCalculator> {
  var _starterGrams = 100.0;

  Map<String, Map<String, dynamic>> proportions = {
    "flour": {
      "quantity": 4.50,
      "unit": "gr",
    },
    "water": {
      "quantity": 3.25,
      "unit": "gr",
    },
    "salt": {
      "quantity": 0.11,
      "unit": "gr",
    },
    "honey": {
      "quantity": 0.10,
      "unit": "gr",
    },
  };

  void onSelectStarterGrams(double value) {
    setState(() => {
          _starterGrams = value,
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$_starterGrams active sourdough",
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          Slider.adaptive(
            value: _starterGrams,
            min: 0,
            max: 500,
            divisions: 500,
            onChanged: onSelectStarterGrams,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Ingredient(
                  name: "Flour",
                  amount: _starterGrams * (proportions["flour"]!["quantity"]),
                  unit: proportions["flour"]!["unit"],
                ),
                Ingredient(
                  name: "Water",
                  amount: _starterGrams * (proportions["water"]!["quantity"]),
                  unit: proportions["water"]!["unit"],
                ),
                Ingredient(
                  name: "Salt",
                  amount: _starterGrams * (proportions["salt"]!["quantity"]),
                  unit: proportions["salt"]!["unit"],
                ),
                Ingredient(
                  name: "Honey (optional)",
                  amount: _starterGrams * (proportions["honey"]!["quantity"]),
                  unit: proportions["honey"]!["unit"],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Ingredient extends StatelessWidget {
  final String name;
  final double amount;
  final String unit;

  const Ingredient(
      {super.key,
      required this.name,
      required this.amount,
      required this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text("$name: ${amount.round()} $unit",
          style: const TextStyle(fontSize: 18.0)),
    );
  }
}
