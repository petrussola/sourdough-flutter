import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sourdough_app/envvariables.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // ── Banner ──
  final ValueNotifier<bool> bannerVisible = ValueNotifier(true);
  BannerAd? bannerAd;
  final ValueNotifier<bool> bannerLoaded = ValueNotifier(false);

  // ── App Open ──
  AppOpenAd? _appOpenAd;
  int _appOpenRetries = 0;
  bool _showOnLoad = false;

  // ── Interstitial ──
  InterstitialAd? _interstitialAd;
  bool _interstitialShowing = false;
  int _tabSwitchCount = 0;
  static const _tabSwitchesPerAd = 3;

  // ── Native ──
  final List<NativeAd> _nativeAdPool = [];
  final ValueNotifier<int> nativeAdsReady = ValueNotifier(0);
  static const _nativeAdPoolSize = 2;

  Future<void> init({bool showAppOpenOnLoad = false}) async {
    if (kIsWeb) return;
    _showOnLoad = showAppOpenOnLoad;
    _loadAppOpen();
    _loadInterstitial();
    _loadNativeAdPool();
  }

  // ── Banner ──

  Future<void> loadBanner(double screenWidth) async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      screenWidth.truncate(),
    );

    if (size == null) return;

    bannerAd?.dispose();
    bannerAd = BannerAd(
      adUnitId: pageBottomAdId,
      size: size,
      request: const AdRequest(
        extras: {'collapsible': 'bottom'},
      ),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
          bannerLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed to load: ${error.message}');
          ad.dispose();
          bannerAd = null;
          bannerLoaded.value = false;
        },
      ),
    );

    bannerAd!.load();
  }

  // ── App Open ──

  void _loadAppOpen() {
    AppOpenAd.load(
      adUnitId: appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenRetries = 0;
          _appOpenAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _appOpenAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _appOpenAd = null;
            },
          );
          if (_showOnLoad) {
            _showOnLoad = false;
            tryShowAppOpen();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('App Open ad failed to load: ${error.message}');
          _appOpenAd = null;
          _retryAppOpen();
        },
      ),
    );
  }

  void _retryAppOpen() {
    if (_appOpenRetries >= 3) return;
    _appOpenRetries++;
    final delay = Duration(seconds: 30 * _appOpenRetries);
    Future.delayed(delay, _loadAppOpen);
  }

  /// Shows the app open ad if one is loaded. Frequency capping is managed
  /// server-side in the AdMob console.
  void tryShowAppOpen() {
    if (_appOpenAd == null) return;
    _appOpenAd!.show();
  }

  // ── Interstitial ──

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _interstitialShowing = false;
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _interstitialShowing = false;
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Call on every tab switch. Shows an interstitial every [_tabSwitchesPerAd] switches.
  void onTabSwitch() {
    if (kIsWeb) return;
    _tabSwitchCount++;
    if (_tabSwitchCount >= _tabSwitchesPerAd) {
      _tabSwitchCount = 0;
      _tryShowInterstitial();
    }
  }

  void _tryShowInterstitial() {
    if (_interstitialAd == null || _interstitialShowing) return;
    _interstitialShowing = true;
    _interstitialAd!.show();
  }

  // ── Native ──

  void _loadNativeAdPool() {
    for (var i = _nativeAdPool.length; i < _nativeAdPoolSize; i++) {
      _loadOneNativeAd();
    }
  }

  void _loadOneNativeAd() {
    NativeAd(
      adUnitId: nativeAdId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _nativeAdPool.add(ad as NativeAd);
          nativeAdsReady.value = _nativeAdPool.length;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
      ),
    ).load();
  }

  /// Returns a loaded native ad, or null if none available.
  /// The caller is responsible for displaying it; the ad is removed from the pool
  /// and a new one is loaded to replace it.
  NativeAd? getNativeAd() {
    if (_nativeAdPool.isEmpty) return null;
    final ad = _nativeAdPool.removeAt(0);
    nativeAdsReady.value = _nativeAdPool.length;
    _loadOneNativeAd();
    return ad;
  }

  void dispose() {
    bannerAd?.dispose();
    _appOpenAd?.dispose();
    _interstitialAd?.dispose();
    for (final ad in _nativeAdPool) {
      ad.dispose();
    }
    _nativeAdPool.clear();
  }
}
