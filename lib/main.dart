import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sourdough_app/datamanager.dart';
import 'package:sourdough_app/pages/calculator_page.dart';
import 'package:sourdough_app/pages/onboarding_page.dart';
import 'package:sourdough_app/services/ad_service.dart';
import 'package:sourdough_app/services/consent_service.dart';
import 'package:sourdough_app/theme/app_theme.dart';

import 'pages/recipe_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConsentService.instance.initializeWithConsent();
  await AdService.instance.init(showAppOpenOnLoad: true);

  final showOnboarding = await OnboardingPage.shouldShow();

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sourdough Making Toolkit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: _showOnboarding
          ? OnboardingPage(
              onComplete: () {
                setState(() => _showOnboarding = false);
              },
            )
          : const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _dataManager = DataManager();
  var _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb) {
      AdService.instance.loadBanner(MediaQuery.of(context).size.width);
    }
  }

  static const _pageTitles = [
    'Starter Recipe',
    'Bread Recipe',
    'Calculator',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      RecipePage(dataManager: _dataManager, routeIndex: 0),
      RecipePage(dataManager: _dataManager, routeIndex: 1),
      const CalculatorPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: pages[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!kIsWeb)
            ValueListenableBuilder<bool>(
              valueListenable: AdService.instance.bannerLoaded,
              builder: (context, loaded, _) {
                final ad = AdService.instance.bannerAd;
                if (!loaded || ad == null) return const SizedBox.shrink();
                return SizedBox(
                  width: ad.size.width.toDouble(),
                  height: ad.size.height.toDouble(),
                  child: AdWidget(ad: ad),
                );
              },
            ),
          NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.science_outlined),
                selectedIcon: Icon(Icons.science),
                label: 'Starter',
              ),
              NavigationDestination(
                icon: Icon(Icons.bakery_dining_outlined),
                selectedIcon: Icon(Icons.bakery_dining),
                label: 'Bread',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate),
                label: 'Calculator',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
