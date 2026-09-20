import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/cubits/cart_cubit/cart_cubit.dart';
import 'package:vegesea/cubits/profile_cubit/profile_cubit.dart';
import 'package:vegesea/layout/Auth/login.dart';
import 'package:vegesea/layout/chat/chat_screen.dart';
import 'package:vegesea/layout/orders/orders_screen.dart';
import 'package:vegesea/layout/profile_and_settings/widgets/addresses_screen.dart';
import 'package:vegesea/layout/profile_and_settings/widgets/my_profile.dart';
import 'package:vegesea/layout/profile_and_settings/widgets/settings_screen.dart';
import 'package:vegesea/models/user_model.dart';
import 'package:vegesea/services/logout_service.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import '../../cubits/wallet_cubit/wallet_cubit.dart';
import '../../cubits/wallet_cubit/wallet_state.dart';
import '../../services/login_controller.dart';
import '../../shared/shared/constants.dart';

class SettingsAndProfileScreen extends StatefulWidget {
  const SettingsAndProfileScreen({super.key});

  @override
  State<SettingsAndProfileScreen> createState() =>
      _SettingsAndProfileScreenState();
}

class _SettingsAndProfileScreenState extends State<SettingsAndProfileScreen> {
  bool? isSignInDone;

  @override
  void initState() {
    super.initState();
    loadsignIn();
    context.read<ProfileCubit>().getProfile();
  }

  loadsignIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSignInDone = prefs.getBool("IsSignInDone") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //floatingActionButton: defaultFloatingButton(context),
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppLocalizations.of(context).translate("profile and settings"),
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 25,
              ),
            ),
          ),
        ),
        // actions: const [
        //   HomeButton(),
        // ],
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileSuccess) {
            final profile = state.profile.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(
                        name: profile.name,
                        email: profile.email,
                        phone: profile.phone,
                        photo: profile.photo,
                        maxWidth: constraints.maxWidth,
                      ),
                      _buildWalletCard(constraints.maxWidth),
                      _buildSettingsGrid(constraints.maxWidth),
                      _buildBottomOptions(constraints.maxWidth),
                    ],
                  ),
                );
              },
            );
          } else if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(
                        name: "Name",
                        email: "Email",
                        phone: "Phone",
                        photo: "",
                        maxWidth: constraints.maxWidth,
                      ),
                      _buildWalletCard(constraints.maxWidth),
                      _buildSettingsGrid(constraints.maxWidth),
                      _buildBottomOptions(constraints.maxWidth),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildWalletCard(double maxWidth) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        if (state is WalletSuccess) {
          return Container(
            margin: EdgeInsets.all(maxWidth * 0.04),
            padding: EdgeInsets.all(maxWidth * 0.04),
            decoration: BoxDecoration(
              color: kMainColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet,
                        color: Colors.white, size: maxWidth * 0.08),
                    SizedBox(width: maxWidth * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translate('Wallet Balance'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${state.wallet.balance.toStringAsFixed(2)} LE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildProfileHeader({
    required String? name,
    required String? email,
    required String? phone,
    required String? photo,
    required double maxWidth,
  }) {
    double avatarRadius = maxWidth * 0.12;
    double editButtonSize = maxWidth * 0.09;
    double fontSize = maxWidth * 0.045;
    double emailFontSize = maxWidth * 0.035;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.04),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: kMainColor,
        ),
        padding: EdgeInsets.all(maxWidth * 0.04),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: photo ?? '',
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blueAccent,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: avatarRadius,
                        color: Colors.grey,
                      ),
                      width: avatarRadius * 2,
                      height: avatarRadius * 2,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image != null) {
                        context.read<ProfileCubit>().updateProfile(
                              UserModel(
                                name: name,
                                email: email,
                                phone: phone,
                              ),
                              image.path,
                            );
                      }
                    },
                    child: Container(
                      width: editButtonSize,
                      height: editButtonSize,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: editButtonSize * 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: maxWidth * 0.025),
            Text(
              name ?? "Name",
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              email ?? 'example@email.com',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Colors.white70,
                  fontSize: emailFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGrid(double maxWidth) {
    int crossAxisCount = maxWidth > 600 ? 4 : 3;
    double padding = maxWidth * 0.04;

    return Container(
      margin: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: kSecondaryColor,
      ),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: crossAxisCount,
        padding: EdgeInsets.all(padding),
        mainAxisSpacing: padding * 0.6,
        crossAxisSpacing: padding * 0.6,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildGridItem(
            context,
            icon: Icons.person,
            label: AppLocalizations.of(context).translate("my profile"),
            targetPage: const MyProfileScreen(),
            maxWidth: maxWidth,
          ),
          _buildGridItem(
            context,
            icon: Icons.shopping_basket,
            label: AppLocalizations.of(context).translate("my orders"),
            targetPage: const OrdersScreen(),
            maxWidth: maxWidth,
          ),
          _buildGridItem(
            context,
            icon: Icons.location_on,
            label: AppLocalizations.of(context).translate("my addresses"),
            targetPage: const AddresessScreen(),
            maxWidth: maxWidth,
          ),
          _buildGridItem(
            context,
            icon: Icons.settings,
            label: AppLocalizations.of(context).translate("settings"),
            targetPage: const SettingsScreen(),
            maxWidth: maxWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOptions(double maxWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildOptionButton(
            label: AppLocalizations.of(context).translate("support center"),
            color: Colors.green,
            icon: Icons.support_agent,
            onTap: () {
              navigateTo(context, const ChatScreen());
            },
            maxWidth: maxWidth,
          ),
          isSignInDone!
              ? _buildOptionButton(
                  label: AppLocalizations.of(context).translate("signout"),
                  color: Colors.green,
                  icon: Icons.logout,
                  onTap: () async {
                    try {
                      await logoutService();
                      await LoginController()
                          .logout(); // Clear social login session
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('token');
                      await prefs.setBool('IsSignInDone', false);
                      await prefs.remove('name');
                      await prefs.remove('email');
                      await prefs.setBool("isKeptSignIn", false);
                      context.read<CartCubit>().clearCart();

                      navigateAndFinish(context, const ShopLoginScreen());
                      token = prefs.getString('token');
                      log("token removed. Sign out success");
                      log("token===>> $token");
                    } catch (e) {}
                  },
                  maxWidth: maxWidth,
                )
              : _buildOptionButton(
                  label: AppLocalizations.of(context).translate("signin"),
                  color: Colors.green,
                  icon: Icons.logout,
                  onTap: () async {
                    try {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool("IsSignInDone", true);

                      navigateAndFinish(context, const ShopLoginScreen());
                    } catch (e) {}
                  },
                  maxWidth: maxWidth,
                )
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget targetPage,
    required double maxWidth,
  }) {
    double iconSize = maxWidth * 0.2; // Relative icon size
    double fontSize = maxWidth * 0.05; // Relative font size
    double padding = maxWidth * 0.01; // Padding for the card

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 3, // Allocate more space for the icon
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    icon,
                    color: Colors.green,
                  ),
                ),
              ),
              SizedBox(
                  height: maxWidth * 0.02), // Spacing between icon and label
              Flexible(
                flex: 5, // Allocate less space for the label
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    required double maxWidth,
  }) {
    double height = maxWidth * 0.2;
    double iconSize = maxWidth * 0.075;
    double fontSize = maxWidth * 0.035;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          margin: EdgeInsets.symmetric(horizontal: maxWidth * 0.02),
          decoration: BoxDecoration(
            color: kSecondaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: iconSize),
              SizedBox(height: maxWidth * 0.02),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: color,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
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
