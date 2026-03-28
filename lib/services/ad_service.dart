import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sourdough_app/envvariables.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static const _kLastAppOpenShownMs = 'lastAppOpenShownMs';
  static const _appOpenFrequency = Duration(days: 7);

  // ── Banner ──
  final ValueNotifier<bool> bannerVisible = ValueNotifier(true);
  BannerAd? bannerAd;
  final ValueNotifier<bool> bannerLoaded = ValueNotifier(false);

  // ── App Open ──
  AppOpenAd? _appOpenAd;
  int _appOpenRetries = 0;
  bool _showOnLoad = false;

  Future<void> init({bool showAppOpenOnLoad = false}) async {
    if (kIsWeb) return;
    _showOnLoad = showAppOpenOnLoad;
    _loadAppOpen();
  }

  // ── Banner ──

  /// Creates and loads an adaptive collapsible banner ad.
  /// Must be called with a BuildContext to get screen width.
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

  /// Shows the app open ad if loaded and 7+ days since last show.
  Future<void> tryShowAppOpen() async {
    if (_appOpenAd == null) return;

    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getInt(_kLastAppOpenShownMs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastShown < _appOpenFrequency.inMilliseconds) return;

    await prefs.setInt(_kLastAppOpenShownMs, now);
    _appOpenAd!.show();
  }

  void dispose() {
    bannerAd?.dispose();
    _appOpenAd?.dispose();
  }
}
