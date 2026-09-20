import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:short_navigation/short_navigation.dart';
import 'package:vegesea/layout/home/widgets/sub_categories_grid.dart';
import 'package:vegesea/layout/home/sliding_details.dart';
import 'package:vegesea/models/banners_model.dart' as banner_model;
import 'package:vegesea/services/get_banners_service.dart';
import 'package:vegesea/layout/product_screen/product_screen.dart';

/// Central App Links / Deep Links router for Lavive.
///
/// Responsibilities:
///  - Captures incoming URIs on cold start (`getInitialLink`) and while the
///    app is running (`uriLinkStream`), plus handles ChottuLink attribution
///    links delegated from [MarketingService].
///  - Parses `uri.host`, `uri.pathSegments` and `uri.queryParameters` and
///    dispatches to the matching in-app screen:
///      * `/p/{id}` or `?product_id=`  -> ProductScreen(id)
///      * `/c/{id}` or `?category_id=` -> SubCategoriesGrid(category id)
///      * `/b/{id}` or `?banner_id=` -> SlidingDetails (Banners/Offers detail)
///      * `?promo={code}` (or `/cart`) -> Cart tab with the promo applied
///      * subdomain fallback            -> Home tab
///  - Stores a pending promo code so it is applied as soon as the Cart has
///    items (applies immediately if the Cart already has items).
class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  /// SharedPreferences key used to persist a pending promo code.
  static const String _pendingPromoPrefsKey = 'pending_promo_code';

  /// Branded App Links / Universal Links subdomains the app routes in-app.
  static const List<String> appLinkHosts = [
    'go.lavive.app',
    'offer.lavive.app',
    'shop.lavive.app',
    'box.lavive.app',
  ];

  /// ChottuLink attribution domain is also accepted as a deep link source.
  static const String chottuLinkDomain = 'lavive.chottu.link';

  /// RootView tab indexes (must stay in sync with `RootView.screens`).
  static const int homeTabIndex = 2;
  static const int cartTabIndex = 0;

  /// Controls which tab `RootView` shows after a deep link.
  final ValueNotifier<int> rootTabNotifier = ValueNotifier<int>(homeTabIndex);

  AppLinks? _appLinks;
  StreamSubscription<Uri>? _appLinkSub;
  String? _lastHandledLink;
  String? _pendingPromoCode;

  /// True once a valid deep link has been dispatched. Used so the splash
  /// auto-navigation does not wipe a screen that a deep link already opened.
  bool _handledDeepLink = false;
  bool get handledDeepLink => _handledDeepLink;

  /// Promo code delivered by a deep link, kept until the Cart consumes it.
  String? get pendingPromoCode => _pendingPromoCode;

  bool _initialised = false;

  /// Call once at startup, after `WidgetsFlutterBinding.ensureInitialized()`.
  /// Loads a previously persisted promo code and starts listening to App Links
  /// (initial + background stream).
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      _pendingPromoCode = prefs.getString(_pendingPromoPrefsKey);
    } catch (e) {
      log('DeepLink promo restore failed: $e');
    }

    try {
      _appLinks = AppLinks();

      // 1) Initial launch URI (cold start: App opened from a link).
      final initialUri = await _appLinks!.getInitialLink();
      if (initialUri != null) {
        log('DeepLink initial: $initialUri');
        handleUri(initialUri);
      }

      // 2) Background stream URI (warm start / link tapped while running).
      _appLinkSub = _appLinks!.uriLinkStream.listen((uri) {
        log('DeepLink stream: $uri');
        handleUri(uri);
      });
    } catch (e) {
      log('AppLinks init failed: $e');
    }
  }

  /// Entry point used by ChottuLink when a resolved attribution link arrives.
  void handleRawLink(String? rawLink) {
    if (rawLink == null || rawLink.isEmpty) return;
    final uri = Uri.tryParse(rawLink.trim());
    if (uri == null) return;
    handleUri(uri);
  }

  /// Parses and routes a single incoming URI.
  void handleUri(Uri uri) {
    // Deduplicate: the same link can be delivered by app_links AND ChottuLink.
    final normalized = uri.replace(fragment: '').toString();
    if (normalized == _lastHandledLink) return;
    _lastHandledLink = normalized;

    // Promo code is a global side-effect: store it whenever present so the
    // Cart applies it (now, or as soon as the first product is added).
    final promo = uri.queryParameters['promo'];
    if (promo != null && promo.trim().isNotEmpty) {
      _setPendingPromo(promo.trim());
    }

    final route = _matchRoute(uri);
    if (route == null) return;
    _handledDeepLink = true;

    switch (route.target) {
      case DeepLinkTarget.product:
        final id = route.id;
        if (id == null) return;
        _navigate(() => Go.to(ProductScreen(productID: id)));
        break;
      case DeepLinkTarget.banner:
        final id = int.tryParse(route.id ?? '');
        if (id == null) return;
        _openBannerById(id);
        break;
      case DeepLinkTarget.category:
        final id = int.tryParse(route.id ?? '');
        if (id == null) return;
        _navigate(() => Go.to(SubCategoriesGrid(subNumber: id)));
        break;
      case DeepLinkTarget.cart:
        _openRootTab(cartTabIndex);
        break;
      case DeepLinkTarget.home:
        _openRootTab(homeTabIndex);
        break;
      case DeepLinkTarget.unknown:
        break;
    }
  }

  /// Parses a URI into a concrete in-app route (target + id when needed).
  DeepLinkRoute? _matchRoute(Uri uri) {
    // Legacy custom scheme: lavive://product/123 , lavive://category/123 ,
    // lavive://offer/first-order.
    if (uri.scheme == 'lavive') {
      final firstSegment =
          uri.pathSegments.where((s) => s.isNotEmpty).toList();
      final id = firstSegment.isNotEmpty ? firstSegment[0] : null;
      switch (uri.host.toLowerCase()) {
        case 'product':
          return id == null
              ? null
              : DeepLinkRoute(DeepLinkTarget.product, id: id);
        case 'category':
          return id == null
              ? null
              : DeepLinkRoute(DeepLinkTarget.category, id: id);
        case 'offer':
          return const DeepLinkRoute(DeepLinkTarget.home);
        default:
          return null;
      }
    }

    if (uri.scheme != 'https' && uri.scheme != 'http') {
      return null;
    }

    final host = uri.host.toLowerCase();
    if (!appLinkHosts.contains(host) && host != chottuLinkDomain) {
      return null;
    }

    final seg = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final query = uri.queryParameters;

    // Path-segment rules (highest priority): /p/{id}, /c/{id}, /b/{id}.
    if (seg.isNotEmpty && seg[0] == 'p' && seg.length >= 2) {
      return DeepLinkRoute(DeepLinkTarget.product, id: seg[1]);
    }
    if (seg.isNotEmpty && seg[0] == 'c' && seg.length >= 2) {
      return DeepLinkRoute(DeepLinkTarget.category, id: seg[1]);
    }
    if (seg.isNotEmpty && seg[0] == 'b' && seg.length >= 2) {
      return DeepLinkRoute(DeepLinkTarget.banner, id: seg[1]);
    }

    // Query-parameter rules: ?product_id=, ?banner_id=, ?category_id=.
    final productId = query['product_id'];
    if (productId != null && productId.isNotEmpty) {
      return DeepLinkRoute(DeepLinkTarget.product, id: productId);
    }
    final bannerId = query['banner_id'];
    if (bannerId != null && bannerId.isNotEmpty) {
      return DeepLinkRoute(DeepLinkTarget.banner, id: bannerId);
    }
    final categoryId = query['category_id'];
    if (categoryId != null && categoryId.isNotEmpty) {
      return DeepLinkRoute(DeepLinkTarget.category, id: categoryId);
    }

    // Promo / cart routing: ?promo={code} or /cart.
    if (query.containsKey('promo') || (seg.isNotEmpty && seg[0] == 'cart')) {
      return const DeepLinkRoute(DeepLinkTarget.cart);
    }

    // Default subdomain fallback -> Home tab.
    return const DeepLinkRoute(DeepLinkTarget.home);
  }

  /// Opens the Banners / Offers detail screen for the banner matching [id].
  ///
  /// There is no dedicated one-banner endpoint, so we reuse the existing
  /// banners API service and locate the banner by id on the client side.
  Future<void> _openBannerById(int id) async {
    try {
      final res = await fetchAllBanners();
      final banners = res.data ?? const <banner_model.Data>[];
      banner_model.Data? match;
      for (final b in banners) {
        if (b.id == id) {
          match = b;
          break;
        }
      }
      if (match != null) {
        final banner = match;
        _navigate(() => Go.to(SlidingDetails(banner: banner)));
      } else {
        _openRootTab(homeTabIndex);
      }
    } catch (e) {
      log('Deep link banner fetch failed: $e');
      _openRootTab(homeTabIndex);
    }
  }

  /// Resets the RootView stack to [tab] (Home or Cart).
  void _openRootTab(int tab) {
    rootTabNotifier.value = tab;
    _navigate(() =>
        Go.toNameRemoveAll('root_view', predicate: (_) => false));
  }

  /// Runs [action] once the global navigator is mounted. A link can arrive
  /// during cold start before the navigator exists, so we retry briefly.
  void _navigate(void Function() action, [int tries = 0]) {
    if (Go.navigatorKey.currentState != null) {
      try {
        action();
      } catch (e) {
        log('Deep link navigation failed: $e');
      }
    } else if (tries < 20) {
      Future.delayed(const Duration(milliseconds: 300),
          () => _navigate(action, tries + 1));
    }
  }

  void _setPendingPromo(String code) {
    _pendingPromoCode = code;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_pendingPromoPrefsKey, code);
    });
  }

  /// Called once the Cart has consumed the deep link promo.
  void clearPendingPromo() {
    _pendingPromoCode = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_pendingPromoPrefsKey);
    });
  }

  void dispose() {
    _appLinkSub?.cancel();
    _appLinks = null;
    rootTabNotifier.dispose();
  }
}

/// Internal decision produced while parsing a URI.
enum DeepLinkTarget { product, category, banner, cart, home, unknown }

/// A parsed deep link with the target screen and (when needed) the id to pass.
class DeepLinkRoute {
  const DeepLinkRoute(this.target, {this.id});

  final DeepLinkTarget target;
  final String? id;
}