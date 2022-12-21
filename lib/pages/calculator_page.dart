import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  var _litres = 1.0;

  Map<String, Map<String, dynamic>> proportions = {
    "sugar": {
      "quantity": 57.89,
      "unit": "gr",
    },
    "tea": {
      "quantity": 4.21,
      "unit": "gr",
    },
    "vinegar": {
      "quantity": 3.16,
      "unit": "tea spoons",
    },
  };

  void onSelectLitres(double value) {
    setState(() => {_litres = value});
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
              Text("$_litres ${_litres > 1 ? "litres" : "litre"} of water",
                  style: Theme.of(context).textTheme.headline4),
            ],
          ),
          Slider.adaptive(
            value: _litres,
            min: 1,
            max: 6,
            divisions: 20,
            onChanged: onSelectLitres,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Ingredient(
                  name: "Sugar",
                  amount: _litres * (proportions["sugar"]!["quantity"]),
                  unit: proportions["sugar"]!["unit"],
                ),
                Ingredient(
                  name: "Tea",
                  amount: _litres * (proportions["tea"]!["quantity"]),
                  unit: proportions["tea"]!["unit"],
                ),
                Ingredient(
                  name: "Vinegar",
                  amount: _litres * (proportions["vinegar"]!["quantity"]),
                  unit: proportions["vinegar"]!["unit"],
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
