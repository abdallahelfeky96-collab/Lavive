import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/cubits/auth_cubit/auth_cubit.dart';
import 'package:vegesea/layout/Auth/forgot_password_screen.dart';
import 'package:vegesea/layout/Auth/social_media_button.dart';
import 'package:vegesea/layout/root_view.dart';
import 'package:vegesea/models/user_model.dart';
import 'package:vegesea/layout/Auth/register.dart';
import 'package:vegesea/shared/shared/app_localization.dart';

import '../../services/login_controller.dart';
import '../../shared/shared/components/components.dart';

// ignore: must_be_immutable
class ShopLoginScreen extends StatefulWidget {
  const ShopLoginScreen({super.key});

  @override
  State<ShopLoginScreen> createState() => _ShopLoginScreenState();
}

class _ShopLoginScreenState extends State<ShopLoginScreen> {
  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  bool? ischecked = false;
  String? deviceToken;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            navigateAndFinish(context, const RootView());
          } else if (state is AuthFailure) {
            showSnackBarMessage(
                context, state.errorMessage, Colors.red, Icons.error_outline);
          }
        },
        builder: (context, state) {
          var cuibt = BlocProvider.of<AuthCubit>(context);
          return Scaffold(
              appBar: AppBar(
                backgroundColor: kMainColor,
                leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    )),
              ),
              backgroundColor: kMainColor,
              body: Stack(
                children: [
                  SingleChildScrollView(
                      child: Form(
                          key: formKey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //SizedBox(height: screenHeight * 0.1),
                                FittedBox(
                                  fit: BoxFit.fill,
                                  child: Text(
                                    'LAVIVE',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: const Color(0xFFFFFFFF),
                                        letterSpacing: .5,
                                        fontSize: 45.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  'Healthy Food',
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.05),
                                Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(
                                    minHeight: screenHeight * 0.7,
                                  ),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30),
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.zero,
                                        bottomRight: Radius.zero),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.06),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(height: screenHeight * 0.04),
                                          Row(
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .translate("welcome"),
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize:
                                                          screenWidth * 0.06,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.015),
                                          FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .translate("welcome message"),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  color:
                                                      const Color(0xFF7D8FAB),
                                                  fontSize: screenWidth * 0.035,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.03),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color(0xFFE8EFF3),
                                            ),
                                            child: defaultFormField(
                                              fillColor:
                                                  const Color(0xFFE8EFF3),
                                              color: kMainColor,
                                              controller: emailController,
                                              type: TextInputType.emailAddress,
                                              validate: (String? value) {
                                                if (value!.isEmpty) {
                                                  return 'Please enter your email address';
                                                }
                                                final emailRegExp = RegExp(
                                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                                if (!emailRegExp
                                                    .hasMatch(value)) {
                                                  return 'Please enter a valid email address';
                                                }

                                                return null;
                                              },
                                              label:
                                                  AppLocalizations.of(context)
                                                      .translate("email"),
                                              prefix: Icons.person,
                                            ),
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.025),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: kMainColor,
                                            ),
                                            child: defaultFormField(
                                              fillColor:
                                                  const Color(0xFFE8EFF3),
                                              isPassword: true,
                                              color: kMainColor,
                                              controller: passwordController,
                                              type:
                                                  TextInputType.visiblePassword,
                                              suffix: Icons.visibility_outlined,
                                              validate: (String? value) {
                                                if (value!.isEmpty) {
                                                  return 'password is too short';
                                                }
                                                return null;
                                              },
                                              label:
                                                  AppLocalizations.of(context)
                                                      .translate("password"),
                                              prefix: Icons.lock,
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.03),
                                          defaultButton(
                                            function: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                formKey.currentState!.save();
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                deviceToken = prefs
                                                    .getString("device_token");
                                                UserModel user = UserModel(
                                                    deviceToken: deviceToken,
                                                    password:
                                                        passwordController.text,
                                                    email:
                                                        emailController.text);
                                                log("emailController===>>${emailController.text}");
                                                log("passwordController===>>${passwordController.text}");
                                                await BlocProvider.of<
                                                        AuthCubit>(context)
                                                    .loginUser(user, context);
                                                //  cuibt.loginUser(user);
                                                bool isSignInDone = true;

                                                await prefs.setBool(
                                                    "isKeptSignIn",
                                                    ischecked ?? false);
                                                prefs.setBool("IsSignInDone",
                                                    isSignInDone);
                                              }
                                            },
                                            text: AppLocalizations.of(context)
                                                .translate("login"),
                                            isUpperCase: true,
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.025),
                                          /*
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth * 0.06),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 20,
                                                  child: SocialMediaButton(
                                                      icon: FontAwesomeIcons
                                                          .googlePlusG.data,
                                                      borderColor: Colors.red,
                                                      iconColor: Colors.red,
                                                      text: "Google",
                                                      textColor: Colors.red,
                                                      onTap: () async {
                                                        try {
                                                          var user =
                                                              await Provider.of<
                                                                          LoginController>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .googleLogin();

                                                          if (user != null) {
                                                            await BlocProvider
                                                                    .of<AuthCubit>(
                                                                        context)
                                                                .socialLoginUser(
                                                                    user,
                                                                    context);
                                                          } else {
                                                            showSnackBarMessage(
                                                                context,
                                                                'Google Sign-In canceled or failed',
                                                                Colors.red,
                                                                Icons.error_outline);
                                                          }
                                                        } catch (e, stackTrace) {
                                                          log(e.toString());
                                                          log(stackTrace
                                                              .toString());
                                                          showSnackBarMessage(
                                                              context,
                                                              'Failed to sign in with Google: $e',
                                                              Colors.red,
                                                              Icons.error_outline);
                                                        }
                                                      }),
                                                ),
                                                const Spacer(),
                                                Expanded(
                                                  flex: 20,
                                                  child: SocialMediaButton(
                                                      icon: Icons.facebook,
                                                      borderColor:
                                                          Colors.blue.shade900,
                                                      text: "Facebook",
                                                      textColor:
                                                          Colors.blue.shade900,
                                                      onTap: () async {
                                                        try {
                                                          var user = await Provider.of<
                                                                      LoginController>(
                                                                  context,
                                                                  listen: false)
                                                              .facebooklogin();

                                                          if (user != null) {
                                                            await BlocProvider
                                                                    .of<AuthCubit>(
                                                                        context)
                                                                .socialLoginUser(
                                                                    user,
                                                                    context);
                                                          } else {
                                                            showSnackBarMessage(
                                                                context,
                                                                'Facebook Sign-In canceled or failed',
                                                                Colors.red,
                                                                Icons.error_outline);
                                                          }
                                                        } catch (e, stackTrace) {
                                                          log(e.toString());
                                                          log(stackTrace
                                                              .toString());
                                                          showSnackBarMessage(
                                                              context,
                                                              'Failed to sign in with Facebook: $e',
                                                              Colors.red,
                                                              Icons.error_outline);
                                                        }
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                          */
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Checkbox(
                                                      value: ischecked,
                                                      activeColor: kMainColor,
                                                      onChanged:
                                                          (newbool) async {
                                                        ischecked = newbool;
                                                        SharedPreferences
                                                            prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        prefs.setBool(
                                                            "isKeptSignIn",
                                                            ischecked ?? false);
                                                        setState(() {});
                                                      }),
                                                  FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              "keep sign in"),
                                                      style: GoogleFonts.lato(
                                                        textStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize:
                                                              screenWidth *
                                                                  0.04,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    navigateTo(context,
                                                        ForgotPasswordScreen());
                                                  },
                                                  child: FittedBox(
                                                    fit: BoxFit.fill,
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              "forgot password?"),
                                                      style: GoogleFonts.lato(
                                                        textStyle: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color: kMainColor,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize:
                                                              screenWidth *
                                                                  0.035,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.025),
                                          FittedBox(
                                            fit: BoxFit.fill,
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .translate("dont have acc"),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  color:
                                                      const Color(0xFF7D8FAB),
                                                  fontSize: screenWidth * 0.04,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.015),
                                          SizedBox(
                                            width: double.infinity,
                                            height: screenHeight * 0.07,
                                            child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: kMainColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          CupertinoContextMenu
                                                              .kOpenBorderRadius),
                                                ),
                                                child: TextButton(
                                                    onPressed: () {
                                                      navigateTo(context,
                                                          const ShopRegisterScreen());
                                                    },
                                                    child: FittedBox(
                                                      fit: BoxFit.fill,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                "create account"),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          textStyle: TextStyle(
                                                              color: kMainColor,
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.04,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900),
                                                        ),
                                                      ),
                                                    ))),
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                        ]),
                                  ),
                                )
                              ]))),
                  if (state is AuthLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ));
        },
      ),
    );
  }
}
