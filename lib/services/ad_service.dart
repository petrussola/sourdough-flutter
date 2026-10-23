import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sourdough_app/envvariables.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();
  bool _initialized = false;
  int _generation = 0;
  bool get isInitialized => _initialized;

  // ── Banner ──
  final ValueNotifier<bool> bannerVisible = ValueNotifier(true);
  BannerAd? bannerAd;
  final ValueNotifier<bool> bannerLoaded = ValueNotifier(false);
  int _bannerRequestId = 0;

  // ── App Open ──
  AppOpenAd? _appOpenAd;
  DateTime? _appOpenLoadedAt;
  int _appOpenRetries = 0;

  // ── Interstitial ──
  InterstitialAd? _interstitialAd;
  bool _interstitialShowing = false;
  int _tabSwitchCount = 0;
  static const _tabSwitchesPerAd = 3;

  // ── Native ──
  final List<NativeAd> _nativeAdPool = [];
  final ValueNotifier<int> nativeAdsReady = ValueNotifier(0);
  static const _nativeAdPoolSize = 2;

  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    _initialized = true;
    _loadAppOpen();
    _loadInterstitial();
    _loadNativeAdPool();
  }

  // ── Banner ──

  Future<void> loadBanner(double screenWidth) async {
    if (!_initialized || screenWidth <= 0) return;
    final requestId = ++_bannerRequestId;
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      screenWidth.truncate(),
    );

    if (size == null || !_initialized || requestId != _bannerRequestId) return;

    bannerLoaded.value = false;
    bannerAd?.dispose();
    final ad = BannerAd(
      adUnitId: pageBottomAdId,
      size: size,
      request: const AdRequest(
        extras: {'collapsible': 'bottom'},
      ),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!identical(bannerAd, ad)) {
            ad.dispose();
            return;
          }
          bannerLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed to load: ${error.message}');
          ad.dispose();
          if (identical(bannerAd, ad)) {
            bannerAd = null;
            bannerLoaded.value = false;
          }
        },
      ),
    );

    bannerAd = ad;
    ad.load();
  }

  // ── App Open ──

  void showAppOpenWhenReady() {
    if (!_initialized) return;
    tryShowAppOpen();
  }

  void _loadAppOpen() {
    if (!_initialized) return;
    final generation = _generation;
    AppOpenAd.load(
      adUnitId: appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (!_initialized || generation != _generation) {
            ad.dispose();
            return;
          }
          _appOpenRetries = 0;
          _appOpenAd = ad;
          _appOpenLoadedAt = DateTime.now();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (generation != _generation) return;
              _appOpenAd = null;
              _loadAppOpen();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (generation != _generation) return;
              _appOpenAd = null;
              _loadAppOpen();
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (!_initialized || generation != _generation) return;
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
    final generation = _generation;
    Future.delayed(delay, () {
      if (_initialized && generation == _generation) _loadAppOpen();
    });
  }

  /// Shows the app open ad if one is loaded. Frequency capping is managed
  /// server-side in the AdMob console.
  void tryShowAppOpen() {
    if (!_initialized || _appOpenAd == null || _interstitialShowing) return;
    if (_appOpenLoadedAt == null ||
        DateTime.now().difference(_appOpenLoadedAt!) >=
            const Duration(hours: 4)) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenLoadedAt = null;
      _loadAppOpen();
      return;
    }
    final ad = _appOpenAd!;
    _appOpenAd = null;
    _appOpenLoadedAt = null;
    ad.show();
  }

  // ── Interstitial ──

  void _loadInterstitial() {
    if (!_initialized) return;
    final generation = _generation;
    InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (!_initialized || generation != _generation) {
            ad.dispose();
            return;
          }
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (generation != _generation) return;
              _interstitialShowing = false;
              _interstitialAd = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (generation != _generation) return;
              _interstitialShowing = false;
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (!_initialized || generation != _generation) return;
          debugPrint('Interstitial failed to load: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Call on every tab switch. Shows an interstitial every [_tabSwitchesPerAd] switches.
  void onTabSwitch() {
    if (!_initialized) return;
    _tabSwitchCount++;
    if (_tabSwitchCount >= _tabSwitchesPerAd) {
      _tabSwitchCount = 0;
      _tryShowInterstitial();
    }
  }

  void _tryShowInterstitial() {
    if (_interstitialAd == null || _interstitialShowing) return;
    _interstitialShowing = true;
    final ad = _interstitialAd!;
    _interstitialAd = null;
    ad.show();
  }

  // ── Native ──

  void _loadNativeAdPool() {
    for (var i = _nativeAdPool.length; i < _nativeAdPoolSize; i++) {
      _loadOneNativeAd();
    }
  }

  void _loadOneNativeAd() {
    if (!_initialized) return;
    final generation = _generation;
    NativeAd(
      adUnitId: nativeAdId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!_initialized || generation != _generation) {
            ad.dispose();
            return;
          }
          _nativeAdPool.add(ad as NativeAd);
          nativeAdsReady.value = _nativeAdPool.length;
        },
        onAdFailedToLoad: (ad, error) {
          if (!_initialized || generation != _generation) {
            ad.dispose();
            return;
          }
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
    if (!_initialized) return null;
    if (_nativeAdPool.isEmpty) return null;
    final ad = _nativeAdPool.removeAt(0);
    nativeAdsReady.value = _nativeAdPool.length;
    _loadOneNativeAd();
    return ad;
  }

  void dispose() {
    _initialized = false;
    _generation++;
    _appOpenRetries = 0;
    _interstitialShowing = false;
    _tabSwitchCount = 0;
    _bannerRequestId++;
    bannerLoaded.value = false;
    bannerAd?.dispose();
    bannerAd = null;
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _appOpenLoadedAt = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    for (final ad in _nativeAdPool) {
      ad.dispose();
    }
    _nativeAdPool.clear();
    nativeAdsReady.value = 0;
  }
}
