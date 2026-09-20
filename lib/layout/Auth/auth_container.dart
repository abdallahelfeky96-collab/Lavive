import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/layout/Auth/login.dart';
import 'package:vegesea/layout/on_boarding/language_screen.dart';
import 'package:vegesea/layout/root_view.dart';


class AuthContainer extends StatefulWidget {
  const AuthContainer({super.key});

  @override
  State<AuthContainer> createState() => _AuthContainerState();
}

class _AuthContainerState extends State<AuthContainer> {
  bool? isAppOpened;
  bool? isKeptSignIn;
  String? token;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAppOpened = prefs.getBool("isAppOpened") ?? false;
      isKeptSignIn = prefs.getBool("isKeptSignIn") ?? false;
      token = prefs.getString("token");
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // First time opening app
    if (isAppOpened == false) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool("isAppOpened", true);
      });
      return const LanguageScreen();
    }
    if (isAppOpened == true && token == null && isKeptSignIn == false) {
      return const RootView();
    }
    // if (token == null) {
    //   return const RootView();
    // }

    // User has logged in and checked "keep me signed in"
    if (isKeptSignIn == true && token != null && isAppOpened == true) {
      return const RootView();
    }

    // User hasn't checked "keep me signed in"
    if (isKeptSignIn == false && isAppOpened == true && token != null) {
      return const ShopLoginScreen();
    }

    return const ShopLoginScreen();
  }
}
