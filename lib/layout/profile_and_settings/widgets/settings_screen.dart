import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/cubits/lang_cubit/lang_cubit.dart';
import 'package:vegesea/cubits/profile_cubit/profile_cubit.dart';
import 'package:vegesea/cubits/theme_cubit/theme_cubit.dart';
import 'package:vegesea/layout/Auth/login.dart';
import 'package:vegesea/layout/profile_and_settings/widgets/pirvacy.dart';
import 'package:vegesea/models/enums/theme_state.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';
import 'package:vegesea/shared/shared/constants.dart';

import '../../../cubits/wallet_cubit/wallet_cubit.dart';
import '../../../cubits/wallet_cubit/wallet_state.dart';
import '../../Auth/forgot_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool isTurnedOn = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDark = prefs.getBool("isDarkMode");
    setState(() {
      _isDarkMode = isDark ?? false;
    });
    print("Loaded theme: ${_isDarkMode ? "Dark Mode" : "Light Mode"}");

    BlocProvider.of<ThemeCubit>(context).changeTheme(
      _isDarkMode ? ThemeStat.Dark : ThemeStat.Light,
    );
  }

  Future<void> _saveTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", isDark);
    print("Saved theme: ${isDark ? "Dark Mode" : "Light Mode"}");
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: const MovableFloatingButton(),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate("settings"),
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 25.sp,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        actions: const [
          HomeButton(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.03),
        child: ListView(
          children: [
            SettingsSection(
              icon: Icons.person,
              sectionName: AppLocalizations.of(context).translate("account"),
              sectionWidgetOne: Column(
                children: [
                  token != null
                      ? InkWell(
                          onTap: () {
                            navigateTo(context, ForgotPasswordScreen());
                          },
                          child: ListTile(
                            trailing: Icon(Icons.chevron_right,
                                size: screenSize.width * 0.05),
                            title: Text(
                              AppLocalizations.of(context)
                                  .translate("change password"),
                              style:
                                  TextStyle(fontSize: screenSize.width * 0.035),
                            ),
                          ),
                        )
                      : Container(),
                  InkWell(
                    onTap: () {
                      navigateTo(context, const privacyPolicy());
                    },
                    child: ListTile(
                      trailing: Icon(Icons.chevron_right,
                          size: screenSize.width * 0.05),
                      title: Text(
                        AppLocalizations.of(context)
                            .translate("privacy settings"),
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     navigateTo(context, const privacyPolicy());
                  //   },
                  //   child: ListTile(
                  //     trailing: Icon(Icons.chevron_right,
                  //         size: screenSize.width * 0.05),
                  //     title: Text(
                  //       AppLocalizations.of(context).translate("stores"),
                  //       style: TextStyle(fontSize: 19.sp),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.015,
            ),
            SettingsSection(
              icon: Icons.account_balance_wallet,
              sectionName: AppLocalizations.of(context).translate("wallet"),
              sectionWidgetOne: BlocBuilder<WalletCubit, WalletState>(
                builder: (context, state) {
                  if (state is WalletSuccess) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.account_balance_wallet,
                            color: kMainColor,
                            size: screenSize.width * 0.06,
                          ),
                          title: Text(
                            AppLocalizations.of(context)
                                .translate('Wallet Balance'),
                            style: TextStyle(fontSize: 19.sp),
                          ),
                          trailing: Text(
                            '${state.wallet.balance.toStringAsFixed(2)} LE',
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.bold,
                              color: kMainColor,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                            size: screenSize.width * 0.06,
                          ),
                          title: Text(
                            AppLocalizations.of(context)
                                .translate('wallet_info'),
                            style: TextStyle(
                              fontSize: screenSize.width * 0.035,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (state is WalletLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return ListTile(
                      title: Text(
                        AppLocalizations.of(context).translate('wallet_error'),
                        style: TextStyle(fontSize: 19.sp, color: Colors.red),
                      ),
                    );
                  }
                },
              ),
            ),
            SettingsSection(
              icon: Icons.more,
              sectionName: AppLocalizations.of(context).translate("more"),
              sectionWidgetOne: Column(
                children: [
                  ListTile(
                    trailing: const FittedBox(
                      child: Row(
                        children: [LanguageSwitcher()],
                      ),
                    ),
                    title: Text(
                      AppLocalizations.of(context).translate("language"),
                      style: TextStyle(fontSize: 19.sp),
                    ),
                  ),
                  ListTile(
                    trailing: FittedBox(
                      child: Row(
                        children: [
                          Text(
                            'Egypt',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 19.sp,
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              size: screenSize.width * 0.05)
                        ],
                      ),
                    ),
                    title: Text(
                      AppLocalizations.of(context).translate("country"),
                      style: TextStyle(fontSize: 19.sp),
                    ),
                  ),
                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context).translate("dark mode"),
                      style: TextStyle(fontSize: 19.sp),
                    ),
                    value: _isDarkMode,
                    onChanged: (bool value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      BlocProvider.of<ThemeCubit>(context).changeTheme(
                        value ? ThemeStat.Dark : ThemeStat.Light,
                      );
                      _saveTheme(value);
                    },
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     // Delete Account Api
                  //
                  //     showDialog(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return AlertDialog(
                  //           title: Text(AppLocalizations.of(context).translate('delete_profile')),
                  //           content: Text(AppLocalizations.of(context).translate('confirm_delete_profile')),
                  //           actions: [
                  //             TextButton(
                  //               onPressed: () {
                  //                 Navigator.of(context).pop(); // Close the dialog without any action
                  //               },
                  //               child: Text(AppLocalizations.of(context).translate('no')),
                  //             ),
                  //             TextButton(
                  //               onPressed: () {
                  //                 Navigator.of(context).pop(); // Close the dialog
                  //                 BlocProvider.of<ProfileCubit>(context).deleteProfile();
                  //               },
                  //               child: Text(AppLocalizations.of(context).translate('yes')),
                  //             ),
                  //
                  //           ],
                  //         );
                  //       },
                  //     );
                  //   },
                  //   child: ListTile(
                  //     trailing: FittedBox(
                  //       child: Row(
                  //         children: [
                  //           Icon(Icons.chevron_right,
                  //               size: screenSize.width * 0.05)
                  //         ],
                  //       ),
                  //     ),
                  //     title: Text(
                  //       AppLocalizations.of(context).translate("Delete"),
                  //       style: TextStyle(
                  //         color: Colors.red,
                  //         fontSize: 19.sp,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  BlocConsumer<ProfileCubit, ProfileState>(
                    listener: (context, state) {
                      if (state is ProfileDeletedSuccess) {
                        log("User logged out and profile deleted");
                        navigateAndFinish(context, const ShopLoginScreen());
                      } else if (state is ProfileDeletedFailed) {
                        showToast(
                          text: AppLocalizations.of(context)
                              .translate('failed_to_delete_profile'),
                          state: ToastStates.ERROR,
                        );
                      }
                    },
                    builder: (context, state) {
                      return state is ProfileLoading
                          ? const CircularProgressIndicator()
                          : InkWell(
                              onTap: () {
                                // Delete Account Api
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(context)
                                          .translate('delete_profile')),
                                      content: Text(AppLocalizations.of(context)
                                          .translate('confirm_delete_profile')),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog without any action
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)
                                                  .translate('no')),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            BlocProvider.of<ProfileCubit>(
                                                    context)
                                                .deleteProfile();
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate('yes'),
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: ListTile(
                                trailing: FittedBox(
                                  child: Row(
                                    children: [
                                      Icon(Icons.chevron_right,
                                          size: screenSize.width * 0.05)
                                    ],
                                  ),
                                ),
                                title: Text(
                                  AppLocalizations.of(context)
                                      .translate("delete_profile"),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 19.sp,
                                  ),
                                ),
                              ),
                            );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection(
      {super.key,
      required this.icon,
      this.sectionWidgetOne,
      required this.sectionName,
      this.sectionWidgetTow,
      this.sectionWidgetThree,
      this.sectionWidgetFour});
  final IconData icon;
  final String sectionName;
  final Widget? sectionWidgetOne,
      sectionWidgetTow,
      sectionWidgetThree,
      sectionWidgetFour;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: kMainColor,
                  size: screenSize.width * 0.055,
                ),
                SizedBox(
                  width: screenSize.width * 0.04,
                ),
                Text(
                  sectionName,
                  style:
                      TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          SizedBox(
            height: screenSize.height * 0.03,
          ),
          sectionWidgetOne ?? const SizedBox(),
          sectionWidgetTow ?? const SizedBox(),
          sectionWidgetThree ?? const SizedBox(),
          sectionWidgetFour ?? const SizedBox(),
        ],
      ),
    );
  }
}

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return PopupMenuButton<String>(
      onSelected: (value) {
        context.read<LangCubit>().changeLanguage(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () async {
            String langCode = "en";
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("langCode", langCode);
            Phoenix.rebirth(context);
          },
          value: 'en',
          child: Text('English',
              style: TextStyle(fontSize: screenSize.width * 0.035)),
        ),
        PopupMenuItem(
          onTap: () async {
            String langCode = "ar";
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("langCode", langCode);
            Phoenix.rebirth(context);
          },
          value: 'ar',
          child: Text('العربية',
              style: TextStyle(fontSize: screenSize.width * 0.035)),
        ),
      ],
      icon: Icon(Icons.language, size: screenSize.width * 0.05),
    );
  }
}
