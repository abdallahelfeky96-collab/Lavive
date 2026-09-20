// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/cubits/auth_cubit/auth_cubit.dart';
import 'package:vegesea/models/user_model.dart';
import 'package:vegesea/models/virefy_phone_model.dart';
import 'package:vegesea/shared/shared/app_localization.dart';

import '../../shared/shared/components/components.dart';
import 'login.dart';

class ShopRegisterScreen extends StatefulWidget {
  const ShopRegisterScreen({super.key});

  @override
  State<ShopRegisterScreen> createState() => _ShopRegisterScreenState();
}

class _ShopRegisterScreenState extends State<ShopRegisterScreen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  bool? ischecked = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          const CircularProgressIndicator();
        } else if (state is RegAuthSuccess) {
          // Handle registration success, but don't navigate yet
          showSnackBarMessage(
              context, state.regAuthSuccess, Colors.green, Icons.check);
        } else if (state is PhoneVerificationSuccess) {
          // Navigate to login screen after successful phone verification
          navigateAndFinish(context, const ShopLoginScreen());
        } else if (state is AuthFailure) {
          showSnackBarMessage(
              context, state.errorMessage, Colors.red, Icons.error_outline);
          log("register error==>> ${state.errorMessage}");
        }
      },
      builder: (context, state) {
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
          body: Center(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  //const SizedBox(height: 60),
                  FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      'LAVIVE',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.white,
                          letterSpacing: .5,
                          fontSize: 45.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Healthy Food',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    height: 1000,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.zero,
                          bottomRight: Radius.zero),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate("create account"),
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          FittedBox(
                            fit: BoxFit.fill,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("welcome message"),
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  color: Color(0xFF7D8FAB),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              //color: const Color(0xFFBFC9DA),
                              color: const Color(0xFFE8EFF3),
                            ),
                            child: defaultFormField(
                              fillColor: const Color(0xFFE8EFF3),
                              controller: nameController,
                              type: TextInputType.name,
                              validate: (String? value) {
                                if (value!.isEmpty) {
                                  return 'please enter your name';
                                }
                                return null;
                              },
                              label: AppLocalizations.of(context)
                                  .translate("full name"),
                              prefix: Icons.person,
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFE8EFF3),
                            ),
                            child: defaultFormField(
                              fillColor: const Color(0xFFE8EFF3),
                              controller: emailController,
                              type: TextInputType.emailAddress,
                              validate: (String? value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                final emailRegExp = RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                if (!emailRegExp.hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }

                                return null;
                              },
                              label: AppLocalizations.of(context)
                                  .translate("email"),
                              prefix: Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFE8EFF3),
                            ),
                            child: defaultFormField(
                              fillColor: const Color(0xFFE8EFF3),
                              controller: phoneController,
                              type: TextInputType.phone,
                              validate: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                // Check if the phone number starts with 0 and has exactly 11 digits
                                if (!RegExp(r'^0[0-9]{10}$').hasMatch(value)) {
                                  return 'Please enter a valid phone number';
                                }
                                return null; // Validation passed
                              },
                              label: AppLocalizations.of(context)
                                  .translate("phone"),
                              prefix: Icons.phone,
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFE8EFF3),
                            ),
                            child: defaultFormField(
                              fillColor: const Color(0xFFE8EFF3),
                              isPassword: true,
                              controller: passwordController,
                              type: TextInputType.visiblePassword,
                              suffix: Icons.visibility_off,
                              validate: (String? value) {
                                if (value!.isEmpty || value.length < 8) {
                                  return 'password is too short';
                                }
                                return null;
                              },
                              label: AppLocalizations.of(context)
                                  .translate("password"),
                              prefix: Icons.lock_outline,
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFE8EFF3),
                            ),
                            child: defaultFormField(
                              fillColor: const Color(0xFFE8EFF3),
                              isPassword: true,
                              controller: confirmPasswordController,
                              type: TextInputType.visiblePassword,
                              suffix: Icons.visibility_off,
                              validate: (String? value) {
                                if (value!.isEmpty) {
                                  return 'password is too short';
                                }
                                return null;
                              },
                              label: AppLocalizations.of(context)
                                  .translate("confirm_password"),
                              prefix: Icons.lock_outline,
                            ),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          defaultButton(
                            function: () async {
                              if (formKey.currentState!.validate()) {
                                // Check if password and confirm password match
                                if (passwordController.text !=
                                    confirmPasswordController.text) {
                                  // Show error message if passwords don't match
                                  showSnackBarMessage(
                                      context,
                                      AppLocalizations.of(context)
                                          .translate("passwords_do_not_match"),
                                      Colors.red,
                                      Icons.error_outline);
                                  return; // Stop further execution
                                }

                                // Check if the terms and conditions are accepted
                                if (ischecked != true) {
                                  showSnackBarMessage(
                                      context,
                                      AppLocalizations.of(context).translate(
                                          "accept_terms_and_conditions"),
                                      Colors.red,
                                      Icons.error_outline);
                                  return; // Stop further execution
                                }

                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? deviceToken =
                                    prefs.getString("device_token");
                                UserModel user = UserModel(
                                  name: nameController.text,
                                  phone: phoneController.text,
                                  password: passwordController.text,
                                  email: emailController.text,
                                  deviceToken: deviceToken,
                                );

                                VeriryPhoneModel phoneModel = VeriryPhoneModel(
                                  phone: phoneController.text,
                                  code:
                                      "1234", // Replace with actual verification code if needed
                                );

                                // Register the user
                                await BlocProvider.of<AuthCubit>(context)
                                    .registerUser(user);

                                // Verify the phone number
                                await BlocProvider.of<AuthCubit>(context)
                                    .verifyPhoneNumper(phoneModel, context);
                              }
                            },
                            // function: () async {
                            //   UserModel user = UserModel(
                            //       name: nameController.text,
                            //       phone: phoneController.text,
                            //       password: passwordController.text,
                            //       email: emailController.text);
                            //   VeriryPhoneModel phoneModel = VeriryPhoneModel(
                            //       phone: phoneController.text, code: "1234");
                            //   if(formKey.currentState!.validate()) {
                            //     if (passwordController.text != confirmPasswordController.text) {
                            //       // Show error message if passwords don't match
                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //           content: Text(
                            //             AppLocalizations.of(context)
                            //                 .translate("passwords_do_not_match"),
                            //           ),
                            //           backgroundColor: Colors.red,
                            //         ),
                            //       );
                            //       return; // Stop further execution
                            //     }
                            //     await BlocProvider.of<AuthCubit>(context)
                            //         .registerUser(user);
                            //     await BlocProvider.of<AuthCubit>(context)
                            //         .verifyPhoneNumper(phoneModel, context);
                            //   }
                            // },
                            text: AppLocalizations.of(context)
                                .translate("register"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                  value: ischecked,
                                  activeColor: kMainColor,
                                  onChanged: (newbool) {
                                    setState(() {
                                      ischecked = newbool;
                                    });
                                  }),
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate("accept terms"),
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                      color: Color(0xFF7D8FAB),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 50,
                              ),
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Container(
                                              child: const Text(
                                                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.')),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("terms"),
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                        color: kMainColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'and',
                                style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                      color: Color(0xFF7D8FAB),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Container(
                                              child: const Text(
                                                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.')),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("condition"),
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                          color: kMainColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          FittedBox(
                            fit: BoxFit.fill,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("already have acc"),
                              style: const TextStyle(
                                color: Color(0xFF7D8FAB),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(
                                    CupertinoContextMenu.kOpenBorderRadius),
                              ),
                              child: TextButton(
                                  onPressed: () {
                                    navigateTo(
                                        context, const ShopLoginScreen());
                                  },
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate("sign in"),
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                            color: kMainColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ))),
                        ],

                        //],
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}
