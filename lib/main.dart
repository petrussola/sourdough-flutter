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
        primarySwatch: Colors.lightGreen,
      ),
      home: const MyHomePage(title: 'Kombucha Toolkit'),
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

  @override
  Widget build(BuildContext context) {
    late Widget currentPage;

    switch (selectedIndex) {
      case 0:
        currentPage = const IngredientsPage();
        break;
      case 1:
        currentPage = ReceipePage(dataManager: dataManager);
        break;
      case 2:
        currentPage = const CalculatorPage();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Ingredients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Receipe",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: "Proportions calculator",
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (index) => {
          setState(
            () {
              selectedIndex = index;
            },
          )
        },
      ),
      body: currentPage,
    );
  }
}
