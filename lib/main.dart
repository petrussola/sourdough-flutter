import 'package:flutter/material.dart';
import 'package:kombucha_app/datamanager.dart';
import 'package:kombucha_app/pages/calculator_page.dart';
import 'package:kombucha_app/pages/ingredients_page.dart';

import 'pages/receipe_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kombucha Club',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Kombucha Making Toolkit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var dataManager = DataManager();
  var selectedIndex = 0;

  tapHandler(int index, BuildContext context) {
    setState(
      () {
        selectedIndex = index;
      },
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    late Widget currentPage;
    late String pageTitle;

    switch (selectedIndex) {
      case 0:
        currentPage = const IngredientsPage();
        pageTitle = "Ingredients";
        break;
      case 1:
        currentPage = ReceipePage(dataManager: dataManager);
        pageTitle = "Receipe";
        break;
      case 2:
        currentPage = const CalculatorPage();
        pageTitle = "Proportions";
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Text(widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    )),
              ),
            ),
            DrawerListItem(
              index: 0,
              icon: Icons.restaurant,
              name: "Ingredients",
              onTap: (index) => {
                tapHandler(index, context),
              },
            ),
            DrawerListItem(
              index: 1,
              icon: Icons.menu_book,
              name: "Receipe",
              onTap: (index) => {
                tapHandler(index, context),
              },
            ),
            DrawerListItem(
              index: 2,
              icon: Icons.calculate,
              name: "Proportions",
              onTap: (index) => {
                tapHandler(index, context),
              },
            ),
          ],
        ),
      ),
      body: currentPage,
    );
  }
}

class DrawerListItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String name;
  final Function(int index) onTap;

  const DrawerListItem(
      {super.key,
      required this.index,
      required this.icon,
      required this.name,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        name,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: () => onTap(index),
    );
  }
}
