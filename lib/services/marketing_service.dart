import 'dart:async';
import 'dart:developer';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:chottu_link/chottu_link.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

import 'deep_link_service.dart';

/// Central marketing + attribution layer for Lavive.
///
/// Responsibilities:
///  - Facebook App Events (CompleteRegistration, Purchase) on the new app id.
///  - iOS App Tracking Transparency prompt + advertiser-tracking sync.
///  - ChottuLink init + incoming/deferred deep-link routing (delegated to the
///    central [DeepLinkService], which owns all URI parsing/routing).
///
/// Facebook app install/activation events are auto-logged by the native SDK,
/// which now reads the new app id from strings.xml (Android) and Info.plist (iOS).
class MarketingService {
  MarketingService._();
  static final MarketingService instance = MarketingService._();

  // ---- ChottuLink config ----
  // Filled from ChottuLink dashboard. apiKey = Mobile SDK Integration Key (NOT the Rest API key).
  // apiKey: ChottuLink dashboard > API Keys (mobile SDK key).
  // domain: your branded subdomain, e.g. "lavive.chottu.link".
  static const String _chottuLinkApiKey = 'c_app_Qun1x4xBRrBzCSPdMf70gzvlf1anCuZ2';
  static const String chottuLinkDomain = 'lavive.chottu.link';
  static const List<String> deepLinkDomains = [
    'lavive.chottu.link',
    'go.lavive.app',
    'offer.lavive.app',
    'shop.lavive.app',
    'box.lavive.app',
  ];

  final FacebookAppEvents _fb = FacebookAppEvents();
  StreamSubscription<dynamic>? _linkSub;
  bool _initialised = false;

  /// Call once at startup, after WidgetsFlutterBinding.ensureInitialized().
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    // Initialise ChottuLink so deferred links resolve on first launch.
    try {
      await ChottuLink.init(apiKey: _chottuLinkApiKey);
    } catch (e) {
      log('ChottuLink init failed: $e');
    }

    // Listen for incoming + deferred deep links and delegate all parsing /
    // routing to the central DeepLinkService (shared with Android App Links).
    try {
      _linkSub = ChottuLink.onLinkReceived.listen((link) {
        log('ChottuLink received: $link');
        DeepLinkService.instance.handleRawLink(link.toString());
      });
    } catch (e) {
      log('ChottuLink listener failed: $e');
    }

    // iOS App Tracking Transparency (no-op on Android), then sync to FB SDK.
    await _requestTrackingAndSync();
  }

  Future<void> _requestTrackingAndSync() async {
    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        status = await AppTrackingTransparency.requestTrackingAuthorization();
      }
      await _fb.setAdvertiserTracking(
        enabled: status == TrackingStatus.authorized,
      );
    } catch (e) {
      log('ATT request failed: $e');
    }
  }

  // ---- Facebook standard events ----

  /// Log when a user finishes registration.
  Future<void> logCompleteRegistration({String method = 'app'}) async {
    try {
      await _fb.logCompletedRegistration(registrationMethod: method);
    } catch (e) {
      log('FB CompleteRegistration failed: $e');
    }
  }

  /// Log a completed order. [amount] is the order total, currency defaults to EGP.
  Future<void> logPurchase(double amount, {String currency = 'EGP'}) async {
    try {
      await _fb.logPurchase(amount: amount, currency: currency);
    } catch (e) {
      log('FB Purchase failed: $e');
    }
  }

  void dispose() {
    _linkSub?.cancel();
  }
}