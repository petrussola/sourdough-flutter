import 'package:flutter/material.dart';

class StarterCalculator extends StatefulWidget {
  const StarterCalculator({super.key});

  @override
  State<StarterCalculator> createState() => _StarterCalculatorState();
}

class _StarterCalculatorState extends State<StarterCalculator> {
  var _starterGrams = 40.0;

  Map<String, Map<String, dynamic>> proportions = {
    "flour": {
      "quantity": 1.00,
      "unit": "gr",
    },
    "water": {
      "quantity": 1.00,
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
              Text("$_starterGrams grams of starter",
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          Slider.adaptive(
            value: _starterGrams,
            min: 0,
            max: 250,
            divisions: 250,
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
