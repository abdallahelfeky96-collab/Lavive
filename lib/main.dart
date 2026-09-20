import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:short_navigation/short_navigation.dart';
import 'package:vegesea/cubits/address_cubit/address_cubit.dart';
import 'package:vegesea/cubits/all_products_cubit/all_products_cubit.dart';
import 'package:vegesea/cubits/auth_cubit/auth_cubit.dart';
import 'package:vegesea/cubits/banners_cubit/banners_cubit.dart';
import 'package:vegesea/cubits/cart_cubit/cart_cubit.dart';
import 'package:vegesea/cubits/chat_cubit/chat_cubit.dart';
import 'package:vegesea/cubits/favorites_cubit/favorites_cubit.dart';
import 'package:vegesea/cubits/get_categories_cubit/get_categories_cubit.dart';
import 'package:vegesea/cubits/get_one_product_cubit/get_one_product_cubit.dart';
import 'package:vegesea/cubits/get_popular_deals_cubit/get_popular_deals_cubit.dart';
import 'package:vegesea/cubits/get_sub_categories_cubit/get_sub_categories_cubit.dart';
import 'package:vegesea/cubits/get_sub_products_cubit/get_sub_products_cubit.dart';
import 'package:vegesea/cubits/lang_cubit/lang_cubit.dart';
import 'package:vegesea/cubits/notis_cubit/notis_cubit.dart';
import 'package:vegesea/cubits/orders_cubit/orders_cubit.dart';
import 'package:vegesea/cubits/products_cubit/products_cubit.dart';
import 'package:vegesea/cubits/profile_cubit/profile_cubit.dart';
import 'package:vegesea/cubits/search_cubit/search_cubit.dart';
import 'package:vegesea/cubits/theme_cubit/theme_cubit.dart';
import 'package:vegesea/layout/home/widgets/sub_categories_grid.dart';
import 'package:vegesea/layout/orders/order_detail_screen.dart';
import 'package:vegesea/layout/product_screen/product_screen.dart';
import 'package:vegesea/layout/root_view.dart';
import 'package:vegesea/layout/maintenance/app_access_gate.dart';
import 'package:vegesea/models/enums/theme_state.dart';
import 'package:vegesea/models/one_product_model.dart';
import 'package:vegesea/services/floating_action_provider.dart';
import 'package:vegesea/services/deep_link_service.dart';
import 'package:vegesea/services/login_controller.dart';
import 'package:vegesea/services/marketing_service.dart';
import 'package:vegesea/shared/shared/Network/cache_helper.dart';
import 'package:vegesea/shared/shared/Network/firebase_notifications.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vegesea/shared/shared/theme_data.dart';
import 'cubits/wallet_cubit/wallet_cubit.dart';
import 'shared/shared/helper/quantity_provider.dart';
import 'shared/shared/Network/remote_config_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await RemoteConfigService().init();


  // Request permission
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await CacheHelper.init();
  await Hive.initFlutter();
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(DataAdapter());
  Hive.registerAdapter(SubCategoryAdapter());
  await Hive.openBox('cartBox');
  sharedPreferences = await SharedPreferences.getInstance();
  token = sharedPreferences!.getString("token");
  if (kDebugMode) {
    log("token===>>$token");
  }

  final firebaseNotifications = FirebaseNotifications();
  firebaseNotifications.initNotifications();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Marketing + attribution: FB events, iOS ATT, ChottuLink deep links.
  await MarketingService.instance.init();

  // Android App Links / Universal Links for the 4 branded subdomains:
  // initial launch URI (cold start) + background stream URI.
  await DeepLinkService.instance.init();

  runApp(BlocProvider(
      create: (_) => LangCubit(), child: Phoenix(child: const MyApp())));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QuantityProvider()),
          ChangeNotifierProvider(create: (context) => ButtonPositionProvider()),
          ChangeNotifierProvider(create: (context) => LoginController()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => GetCategoriesCubit()),
            BlocProvider(create: (context) => AuthCubit()),
            BlocProvider(create: (context) => GetPopularDealsCubit()),
            BlocProvider(create: (context) => ProductsCubit()),
            BlocProvider(create: (context) => GetSubCategoriesCubit()),
            BlocProvider(create: (context) => GetSubProductsCubit()),
            BlocProvider(create: (context) => AllProductsCubit()),
            BlocProvider(create: (context) => SearchCubit()),
            BlocProvider(create: (context) => GetOneProductCubit()),
            BlocProvider(
                create: (context) => CartCubit()..loadCartFromStorage()),
            BlocProvider(create: (context) => ProfileCubit()),
            BlocProvider(create: (context) => AddressCubit()),
            BlocProvider(create: (context) => BannersCubit()),
            BlocProvider(create: (context) => OrdersCubit()),
            BlocProvider(create: (context) => FavoritesCubit()),
            BlocProvider(create: (context) => ChatCubit()),
            BlocProvider(create: (context) => NotisCubit()),
            BlocProvider(create: (context) => WalletCubit()),
            BlocProvider(
                create: (context) =>
                    ThemeCubit()..changeTheme(ThemeStat.Initial)),
          ],
          child: BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
            final theme =
                state is AppDarkTheme ? DarkTheme.theme : LightTheme.theme;

            return BlocBuilder<LangCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp(
                  navigatorKey: Go.navigatorKey,
                    routes: {
                      "root_view": (context) => const RootView(),
                      "sub_categories_page": (context) =>
                          const SubCategoriesGrid(),
                      "product_details_page": (context) => const ProductScreen(),
                      "order_details_page": (context) =>
                          const OrderDetailScreen(),
                    },

                  debugShowCheckedModeBanner: false,
                  theme: theme,
                  //home: token != null ? const SplashScreen() :const AuthContainer(),
                  home: const AppAccessGate(),
                  builder: EasyLoading.init(),
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en', ''),
                    Locale('ar', ''),
                  ],
                  locale: locale,
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }
