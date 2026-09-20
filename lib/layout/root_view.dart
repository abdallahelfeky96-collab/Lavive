import 'dart:developer';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vegesea/layout/profile_and_settings/settings_and_profile_screen.dart';
import 'package:vegesea/services/deep_link_service.dart';
import '../cubits/wallet_cubit/wallet_cubit.dart';
import '../shared/shared/app_localization.dart';
import '../shared/shared/components/components.dart';
import 'cart/cart_screen.dart';
import 'favourite/favourite_screen.dart';
import 'home/home.dart';
import 'orders/orders_screen.dart';
import '../cubits/cart_cubit/cart_cubit.dart';

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  late final PageController _pageController;
  late int currentScreen;

  @override
  void initState() {
    super.initState();
    currentScreen = DeepLinkService.instance.rootTabNotifier.value;
    _pageController = PageController(initialPage: currentScreen);
    // Initialize the screens list
    screens = [
      const CartScreen(),
      const OrdersScreen(showBackButton: false),
      const HomePage(),
      const FavoriteScreen(),
      const SettingsAndProfileScreen(),
    ];
    context.read<WalletCubit>().fetchWalletBalance();

    // Deep links can switch the active tab (e.g. ?promo= -> Cart, domain -> Home).
    DeepLinkService.instance.rootTabNotifier.addListener(_onDeepLinkTab);
  }

  void _onDeepLinkTab() {
    if (!mounted) return;
    final tab = DeepLinkService.instance.rootTabNotifier.value;
    if (tab == currentScreen) return;
    setState(() {
      currentScreen = tab;
    });
    _pageController.jumpToPage(tab);
  }

  @override
  void dispose() {
    DeepLinkService.instance.rootTabNotifier.removeListener(_onDeepLinkTab);
    _pageController.dispose();
    super.dispose();
  }

  /// List of screens to display in the PageView
  late List<Widget> screens;

  /// List of labels for the CurvedNavigationBar
  late final List<String> _labels = [
    AppLocalizations.of(context).translate('cart'),
    AppLocalizations.of(context).translate('order'),
    AppLocalizations.of(context).translate('home'),
    AppLocalizations.of(context).translate('favorites'),
    AppLocalizations.of(context).translate('settings'),
  ];

  /// List of icons for the CurvedNavigationBar
  List<Widget> get _icons => [
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            int count = 0;
            if (state is CartSuccess) {
              count = state.products.length;
            }
            return Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  'assets/images/ic_cart.svg',
                  height: 30.h,
                  width: 30.w,
                  color: Colors.white,
                ),
                if (count > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: kMainColor, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        SvgPicture.asset(
          'assets/images/arrows.svg',
          height: 30.h,
          width: 30.w,
          color: Colors.white,
        ),
        SvgPicture.asset(
          "assets/images/home.svg",
          height: 30.h,
          width: 30.w,
          color: Colors.white,
        ),
        SvgPicture.asset(
          'assets/images/heart.svg',
          height: 30.h,
          width: 30.w,
          color: Colors.white,
        ),
        Image.asset(
          'assets/images/setting.png',
          height: 30.h,
          width: 30.w,
          color: Colors.white,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F8E9), // Light green background from screenshot
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurvedNavigationBar(
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            color: kMainColor, // Dark green background
            buttonBackgroundColor: kMainColor, // Green circle for selected
            backgroundColor: Colors.transparent,
            index: currentScreen,
            height: kBottomNavigationBarHeight,
            items: List.generate(_icons.length, (index) {
              final bool isSelected = currentScreen == index;
              return Container(
                padding: isSelected ? EdgeInsets.all(12.r) : EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: isSelected ? 1.2 : 1.0,
                      child: _icons[index],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _labels[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
            onTap: (index) {
              setState(() {
                currentScreen = index; // Update the current screen index
              });
              _pageController
                  .jumpToPage(index); // Navigate to the selected page
              log('Current selected index: $index');
            },
          ),
          // Adaptive filler for gesture navigation area (iPhone bar/Android line)
          if (MediaQuery.of(context).padding.bottom > 0)
            Container(
              height: MediaQuery.of(context).padding.bottom,
              color: kMainColor, // Match the navigation bar color
            ),
        ],
      ),
    );
  }
}
