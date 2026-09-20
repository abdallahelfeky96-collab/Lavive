// ignore_for_file: unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vegesea/cubits/profile_cubit/profile_cubit.dart';
import 'package:vegesea/models/user_model.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import '../../../shared/shared/constants.dart';
import '../../Auth/login.dart';
import '../../Auth/register.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<ProfileCubit>(context).getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          _showUpdateDialog(context);
        }
      },
      builder: (context, state) {
        if (state is ProfileFaluire) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context).translate("my profile"),
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ),
            body: token != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/no-signal.png",
                            height: 100,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color(0xffF54D40),
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                            AppLocalizations.of(context)
                                .translate("no profile"),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          defaultButton(
                            height: MediaQuery.of(context).size.height * 0.059,
                            width: MediaQuery.of(context).size.width * 0.5,
                            function: () async {
                              navigateTo(context, const ShopLoginScreen());
                            },
                            text:
                                AppLocalizations.of(context).translate("login"),
                            isUpperCase: true,
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.055,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: kMainColor),
                                borderRadius: BorderRadius.circular(
                                    CupertinoContextMenu.kOpenBorderRadius),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  navigateTo(
                                      context, const ShopRegisterScreen());
                                },
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("create account"),
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: kMainColor,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.04,
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

        if (state is ProfileLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ProfileSuccess) {
          final profile = state.profile.data!;
          nameController.text = profile.name ?? "";
          phoneController.text = profile.phone ?? "";
          emailController.text = profile.email ?? "";

          return Scaffold(
            floatingActionButton: const MovableFloatingButton(),
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              title: Text(
                AppLocalizations.of(context).translate("my profile"),
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: const [
                HomeButton(),
              ],
              centerTitle: false,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  buildProfileHeader(
                    name: profile.name,
                    email: profile.email,
                    phone: profile.phone,
                    photo: profile.photo,
                  ),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: nameController,
                              labelText: AppLocalizations.of(context)
                                  .translate("full name"),
                              prefixIcon: Icons.person,
                              validator: (text) {
                                if (text == null || text.trim().isEmpty) {
                                  return 'Please enter Full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            _buildTextField(
                              controller: phoneController,
                              labelText: AppLocalizations.of(context)
                                  .translate("phone"),
                              prefixIcon: Icons.call,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (!RegExp(r'^0[0-9]{10}$').hasMatch(value)) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            _buildTextField(
                              controller: emailController,
                              labelText: AppLocalizations.of(context)
                                  .translate("email"),
                              prefixIcon: Icons.email_outlined,
                              validator: (String? value) {
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
                            ),
                            const SizedBox(height: 20.0),
                            _buildTextField(
                              controller: passwordController,
                              labelText: AppLocalizations.of(context)
                                  .translate("password"),
                              prefixIcon: Icons.password,
                            ),
                            const SizedBox(height: 20.0),
                            _buildTextField(
                              controller: confirmPasswordController,
                              labelText: AppLocalizations.of(context)
                                  .translate("confirm_password"),
                              prefixIcon: Icons.password,
                            ),
                            const SizedBox(height: 20.0),
                            defaultButton(
                              function: () {
                                if (formKey.currentState!.validate()) {
                                  if (passwordController.text.isNotEmpty &&
                                      passwordController.text !=
                                          confirmPasswordController.text) {
                                    showSnackBarMessage(
                                        context,
                                        AppLocalizations.of(context).translate(
                                            "passwords_do_not_match"),
                                        Colors.red,
                                        Icons.error_outline);
                                     return;
                                   }

                                  UserModel profile = UserModel(
                                    name: nameController.text,
                                    phone: phoneController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                  BlocProvider.of<ProfileCubit>(context)
                                      .updateProfile(profile, "");
                                }
                              },
                              text: AppLocalizations.of(context)
                                  .translate("update"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProfileUpdateSuccess) {
          return const SizedBox.shrink();
        } else if (state is ProfileFaluire) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ),
            body: Center(child: Text(state.errMessage)),
          );
        } else {
          return Center(
            child: Scaffold(
              appBar: AppBar(),
              body: Text(
                AppLocalizations.of(context).translate("profile failed"),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            prefixIcon,
            color: kMainColor,
            size: 30,
          ),
          contentPadding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 10.0),
          labelText: labelText,
          labelStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        keyboardType: TextInputType.name,
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate("success")),
          content: Text(
              AppLocalizations.of(context).translate("profile update success")),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                BlocProvider.of<ProfileCubit>(context).getProfile();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildProfileHeader({
    required String? name,
    required String? email,
    required String? phone,
    required String? photo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: kMainColor,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: photo ?? '',
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blueAccent,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                      width: 100,
                      height: 100,
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
                      width: 36,
                      height: 36,
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
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name ?? "Name",
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              email ?? 'example@email.com',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
