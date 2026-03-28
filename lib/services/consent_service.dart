import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();

  /// Requests UMP consent info, shows the form if needed, then initializes
  /// MobileAds. On any error, MobileAds is still initialized (non-personalized
  /// ads will be served).
  Future<void> initializeWithConsent() async {
    if (kIsWeb) return;

    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _showConsentForm(() => _initSdk(completer));
        } else {
          _initSdk(completer);
        }
      },
      (error) {
        debugPrint('UMP consent error: ${error.message}');
        _initSdk(completer);
      },
    );

    return completer.future;
  }

  void _showConsentForm(VoidCallback onDone) {
    ConsentForm.loadConsentForm(
      (form) => form.show((error) {
        if (error != null) {
          debugPrint('Consent form error: ${error.message}');
        }
        onDone();
      }),
      (error) {
        debugPrint('Consent form load error: ${error.message}');
        onDone();
      },
    );
  }

  void _initSdk(Completer<void> completer) {
    MobileAds.instance.initialize().then((_) => completer.complete());
  }
}
