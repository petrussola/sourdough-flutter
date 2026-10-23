import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();
  bool privacyOptionsRequired = false;

  /// Start ads only when UMP says requests are permitted.
  Future<bool> initializeWithConsent() async {
    if (kIsWeb) return false;

    try {
      return await _requestConsentAndInitialize();
    } catch (error) {
      debugPrint('Ad consent initialization failed: $error');
      return false;
    }
  }

  Future<bool> _requestConsentAndInitialize() async {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => completer.complete(),
      (error) {
        debugPrint('UMP consent error: ${error.message}');
        completer.complete();
      },
    );

    await completer.future;
    final formDone = Completer<void>();
    await ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error != null) debugPrint('Consent form error: ${error.message}');
      formDone.complete();
    });
    await formDone.future;
    privacyOptionsRequired = await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
    if (!await ConsentInformation.instance.canRequestAds()) return false;
    await MobileAds.instance.initialize();
    return true;
  }

  Future<bool> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) {
          debugPrint('Privacy options error: ${error.message}');
        }
      });
      return await ConsentInformation.instance.canRequestAds();
    } catch (error) {
      debugPrint('Privacy options check failed: $error');
      return false;
    }
  }
}
