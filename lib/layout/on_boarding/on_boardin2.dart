import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/layout/profile_and_settings/widgets/settings_screen.dart';
import '../../shared/shared/app_localization.dart';
import '../../shared/shared/components/components.dart';
import '../root_view.dart';

class OnBoarding2 extends StatefulWidget {
  const OnBoarding2({super.key});

  @override
  State<OnBoarding2> createState() => _OnBoarding2State();
}

class _OnBoarding2State extends State<OnBoarding2> {
  bool isAppOpend = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Stack(
      children: [
        const Image(
          image: AssetImage('assets/images/boarding.png'),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.03,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                ],
              ),
              SizedBox(
                height: height * 0.15,
              ),
              Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/images/Group.png',
                  height: height * 0.35,
                  width: width * 0.8,
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
                        AppLocalizations.of(context).translate('on2'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: const Color(0xFF303733),
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      Text(
                        AppLocalizations.of(context).translate('on22'),
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
                            'assets/images/img_2.png',
                            height: width * 0.025,
                            width: width * 0.025,
                          ),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          Image.asset(
                            'assets/images/img_1.png',
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
                      navigateAndFinish(context, const RootView());
                      isAppOpend = true;
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("isAppOpend", isAppOpend);
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('get_started'),
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
