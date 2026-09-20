import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/layout/Auth/login.dart';
import 'package:vegesea/layout/profile_and_settings/widgets/settings_screen.dart';
import '../../shared/shared/app_localization.dart';
import '../../shared/shared/components/components.dart';
import 'on_boardin2.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
        body: Stack(
      children: [
        const Image(
          image: AssetImage('assets/images/boarding.png'),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: height * 0.04,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                          AppLocalizations.of(context).translate("language")),
                      const LanguageSwitcher(),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context, _createRoute(const OnBoarding2()));
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.12,
              ),
              Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/images/basket.png',
                  height: height * 0.35,
                  width: width * 0.7,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: height * 0.06,
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('on1'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: const Color(0xFF303733),
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Text(
                        AppLocalizations.of(context).translate('on11'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: const Color(0xFF303733),
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/img_1.png',
                            height: width * 0.025,
                            width: width * 0.025,
                          ),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          Image.asset(
                            'assets/images/img_2.png',
                            height: width * 0.025,
                            width: width * 0.025,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: height * 0.085,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * 0.05),
                  color: kMainColor,
                ),
                child: TextButton(
                    onPressed: () async {
                      // Navigator.push(
                      //     context, _createRoute(const OnBoarding2()));
                      navigateTo(context, const OnBoarding2());
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('next'),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            color: const Color(0xFFFFFFFF),
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w700),
                      ),
                    )),
              )
            ],
          ),
        )
      ],
    ));
  }
}

Route _createRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInCubic;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

void finishOnboarding(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool("isFirstTime", false);
  navigateAndFinish(context, const ShopLoginScreen());
}
