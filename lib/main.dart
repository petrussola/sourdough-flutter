import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sourdough_app/datamanager.dart';
import 'package:sourdough_app/pages/calculator_page.dart';

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
      title: 'Sourdough Making Toolkit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Sourdough Making Toolkit'),
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
  BannerAd? _adBannerDrawer;
  bool _isBottomBannerAdLoaded = false;
  bool _isDrawerAdLoaded = false;

  @override
  void initState() {
    super.initState();

    _loadDrawerAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadBottomBannerAd();
  }

  Future<void> _loadBottomBannerAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: pageBottomAdId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();

          _isBottomBannerAdLoaded = true;
        },
      ),
    );

    _anchoredAdaptiveAd!.load();

    return;
  }

  _loadDrawerAd() {
    _adBannerDrawer = BannerAd(
      adUnitId: drawerAdId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(
            () {
              // When the ad is loaded, get the ad size and use it to set
              // the height of the ad container.
              _adBannerDrawer = ad as BannerAd;
              _isDrawerAdLoaded = true;
            },
          );
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();

          _isDrawerAdLoaded = true;
        },
      ),
    );

    _adBannerDrawer?.load();

    return;
  }

  @override
  Widget build(BuildContext context) {
    late Widget currentPage;
    late String pageTitle;

    switch (selectedIndex) {
      case 0:
        currentPage =
            ReceipePage(dataManager: dataManager, routeIndex: selectedIndex);
        pageTitle = "Starter receipe";
        break;
      case 1:
        currentPage =
            ReceipePage(dataManager: dataManager, routeIndex: selectedIndex);
        pageTitle = "Bread receipe";
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
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  DrawerListItem(
                    index: 0,
                    icon: Icons.restaurant,
                    name: "Starter receipe",
                    onTap: (index) => {
                      tapHandler(index, context),
                    },
                  ),
                  DrawerListItem(
                    index: 1,
                    icon: Icons.menu_book,
                    name: "Bread receipe",
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
            if (_adBannerDrawer != null && _isDrawerAdLoaded)
              Container(
                alignment: Alignment.center,
                width: _adBannerDrawer?.size.width.toDouble(),
                height: _adBannerDrawer?.size.height.toDouble(),
                child: AdWidget(
                  ad: _adBannerDrawer!,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar:
          _anchoredAdaptiveAd != null && _isBottomBannerAdLoaded
              ? Container(
                  alignment: Alignment.center,
                  width: _anchoredAdaptiveAd!.size.width.toDouble(),
                  height: _anchoredAdaptiveAd!.size.height.toDouble(),
                  child: AdWidget(
                    ad: _anchoredAdaptiveAd!,
                  ),
                )
              : null,
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
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      onTap: () => onTap(index),
    );
  }
}
