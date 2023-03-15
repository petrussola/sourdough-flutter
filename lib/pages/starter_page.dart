import 'package:flutter/material.dart';

class IngredientsPage extends StatelessWidget {
  const IngredientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Ingredient(
            title: "SCOBY",
            description: "Stands for Symbiotic Culture of Bacteria and Yeast."),
        Ingredient(
            title: "Unflitered apple cider vinegar",
            description:
                "Also called \"with the mother\", it is essential to keep the acidity levels high to protect the SCOBY from harmful bacteria."),
        Ingredient(
            title: "Tea",
            description:
                "It needs to be either pure green or black tea. Flavored tea contains oils that won't work with Kombutcha"),
        Ingredient(
            title: "Sugar", description: "Regular Caster or Granulated Sugar."),
        Ingredient(
          title: "Water",
          description:
              "I have a filter jar of water (Brita style, if you live in Europe, Google that) and I have never had any problem. I have never done it with tap water, it is drinkable where I live. If you live in a place where it is not safe to drink tap water, please use bottled water.",
        ),
      ],
    );
  }
}

class Ingredient extends StatelessWidget {
  final String title;
  final String description;

  const Ingredient({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Text(
              description,
              style: const TextStyle(fontSize: 16.0, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
