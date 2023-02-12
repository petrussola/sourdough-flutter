import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kombucha_app/datamanager.dart';

import 'package:kombucha_app/pages/calculator_page.dart';
import 'package:kombucha_app/pages/ingredients_page.dart';

import 'envvariables.dart';
import 'pages/receipe_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

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
  BannerAd? _anchoredAdaptiveAd;
  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: const String.fromEnvironment(
        'PAGE_BOTTOM_AD_ID',
        defaultValue: bannerAdTestId,
      ),
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
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

    tapHandler(int index, BuildContext context) {
      setState(
        () {
          selectedIndex = index;
        },
      );
      Navigator.pop(context);
    }

    final BannerAd adBannerDrawer = BannerAd(
      adUnitId: const String.fromEnvironment("AD_BANNER_DRAWER_ID",
          defaultValue: bannerAdTestId),
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );

    adBannerDrawer.load();

    final AdWidget adWidgetDrawer = AdWidget(ad: adBannerDrawer);

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      drawer: Drawer(
        child: Column(
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
            Expanded(
              child: Column(
                children: [
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
            Container(
              alignment: Alignment.center,
              width: adBannerDrawer.size.width.toDouble(),
              height: adBannerDrawer.size.height.toDouble(),
              child: adWidgetDrawer,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _anchoredAdaptiveAd != null && _isAdLoaded
          ? Container(
              alignment: Alignment.center,
              width: _anchoredAdaptiveAd!.size.width.toDouble(),
              height: _anchoredAdaptiveAd!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredAdaptiveAd!),
            )
          : null,
      body: _isAdLoaded
          ? currentPage
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to the Kombucha Making Toolkit app!',
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  )
                ],
              ),
            ),
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
