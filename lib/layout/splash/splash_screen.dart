import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vegesea/layout/Auth/auth_container.dart';
import 'package:vegesea/layout/root_view.dart';
import 'package:vegesea/services/deep_link_service.dart';
import 'package:vegesea/shared/shared/components/components.dart';
import '../../shared/shared/app_colors.dart';
import '../../shared/shared/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;

  // If a cold-start deep link already routed somewhere (product, cart, ...),
  // do not replace the stack with the default home/auth flow.
  _goNext() {
    if (DeepLinkService.instance.handledDeepLink) return;
    (token != null)
        ? navigateAndFinish(context, const RootView())
        : navigateAndFinish(context, const AuthContainer());
  }

  _startDelay() {
    _timer = Timer(const Duration(seconds: 3), () => _goNext());
  }

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Image.asset(
          "assets/assets/splash.gif",
          fit: BoxFit.cover, // Ensures the image covers the entire screen
        ),
      ),
    );
  }
}
