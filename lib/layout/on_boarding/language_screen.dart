import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/layout/on_boarding/on_boarding.dart';

import '../../cubits/lang_cubit/lang_cubit.dart';
import '../../shared/shared/app_localization.dart';
import '../../shared/shared/components/components.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("language")),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.4,
                child: Image.asset(
                  "assets/images/logo_icon.png",
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      size: screenWidth * 0.3,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.19),
              defaultButton(
                height: screenHeight * 0.059,
                width: screenWidth * 0.5,
                function: () async {
                  String langCode = "en";
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString("langCode", langCode);
                  context.read<LangCubit>().changeLanguage(langCode);
                  navigateAndFinish(context, const OnBoarding());
                },
                text: "English",
                isUpperCase: true,
              ),
              SizedBox(height: screenHeight * 0.015),
              SizedBox(
                width: screenWidth * 0.5,
                height: screenHeight * 0.055,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: kMainColor),
                    borderRadius: BorderRadius.circular(
                        CupertinoContextMenu.kOpenBorderRadius),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      String langCode = "ar";
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("langCode", langCode);
                      context.read<LangCubit>().changeLanguage(langCode);
                      navigateAndFinish(context, const OnBoarding());
                    },
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Text(
                        "عربي",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: kMainColor,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
