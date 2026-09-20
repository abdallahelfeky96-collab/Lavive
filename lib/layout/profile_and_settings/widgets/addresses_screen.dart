import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vegesea/cubits/address_cubit/address_cubit.dart';
import 'package:vegesea/models/address_model.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';
import '../../../cubits/profile_cubit/profile_cubit.dart';
import '../../../models/user_model.dart';
import '../../../shared/shared/constants.dart';
import '../../Auth/login.dart';
import '../../Auth/register.dart';
import '../../../cubits/all_products_cubit/all_products_cubit.dart';
import '../../../models/all_products_model.dart';

class AddresessScreen extends StatefulWidget {
  const AddresessScreen({super.key});

  @override
  _AddresessScreenState createState() => _AddresessScreenState();
}

class _AddresessScreenState extends State<AddresessScreen> {
  final titleController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();

  @override
  void initState() {
    BlocProvider.of<AddressCubit>(context).getAllAddresess();
    BlocProvider.of<AllProductsCubit>(context).getAllProducts();
    log("token===>>$token");
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    addressController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        if (state is AddAddressSuccess) {
          Navigator.pop(context);
          context.read<AddressCubit>().getAllAddresess();
        }
        if (state is DeleteAddressSuccess) {
          context.read<AddressCubit>().getAllAddresess();
        }
      },
      builder: (context, state) {
        if (state is GetAddressLoading) {
          return _buildLoading();
        } else if (state is GetAddressSuccess) {
          final addresses = state.allAdresess.data;
          if (addresses == null || addresses.isEmpty) {
            return _buildEmptyAddressesUI(context, screenSize);
          }
          return Scaffold(
            floatingActionButton: const MovableFloatingButton(),
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
              title:
                  Text(AppLocalizations.of(context).translate("address book")),
              actions: const [
                HomeButton(),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05, vertical: 10),
              child: Column(
                children: [
                  BlocConsumer<ProfileCubit, ProfileState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      if (state is ProfileFaluire) {
                        return Container();
                      }

                      if (state is ProfileLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is ProfileSuccess) {
                        final profile = state.profile.data!;
                        return buildProfileHeader(
                          name: profile.name,
                          email: profile.email,
                          phone: profile.phone,
                          photo: profile.photo,
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.05),
                    child: GestureDetector(
                      onTap: () => _showAddAddressBottomSheet(context),
                      child: Container(
                        margin: const EdgeInsets.only(top: 16, bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.add,
                                color: Theme.of(context).primaryColor),
                            Text(
                              AppLocalizations.of(context)
                                  .translate("add new address"),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.05),
                          child: Card(
                            color: kMainColor,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context).translate("address title")}: ${addresses[index].title}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: kSecondaryColor),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${AppLocalizations.of(context).translate("phone")}: ${addresses[index].phone}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: kSecondaryColor),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${AppLocalizations.of(context).translate("address")}: ${addresses[index].address}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: kSecondaryColor),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                        icon: const Icon(
                                            Icons.delete_forever_outlined,
                                            color: Colors.red),
                                        onPressed: () {
                                          context
                                              .read<AddressCubit>()
                                              .deleteAddress(
                                                  addresses[index].id!);
                                          context
                                              .read<AddressCubit>()
                                              .getAllAddresess();
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          if (token == null) {
            return _buildLoginOrSignupUI(context, screenHeight, screenWidth);
          }
          return _buildEmptyAddressesUI(context, screenSize);
        }
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoginOrSignupUI(
      BuildContext context, double screenHeight, double screenWidth) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context).translate("address book")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            defaultButton(
              height: screenHeight * 0.059,
              width: screenWidth * 0.5,
              function: () => navigateTo(context, const ShopLoginScreen()),
              text: AppLocalizations.of(context).translate("login"),
              isUpperCase: true,
            ),
            SizedBox(height: screenHeight * 0.015),
            SizedBox(
              width: screenWidth * 0.5,
              height: screenHeight * 0.055,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: kMainColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () =>
                      navigateTo(context, const ShopRegisterScreen()),
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      AppLocalizations.of(context).translate("create account"),
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
    );
  }

  Widget _buildEmptyAddressesUI(BuildContext context, Size screenSize) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context).translate("address book")),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.05, vertical: 10),
        child: Column(
          children: [
            BlocConsumer<ProfileCubit, ProfileState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is ProfileFaluire) {
                  return Container();
                }

                if (state is ProfileLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ProfileSuccess) {
                  final profile = state.profile.data!;
                  return buildProfileHeader(
                    name: profile.name,
                    email: profile.email,
                    phone: profile.phone,
                    photo: profile.photo,
                  );
                } else {
                  return Container();
                }
              },
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
              child: GestureDetector(
                onTap: () => _showAddAddressBottomSheet(context),
                child: Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.add, color: Theme.of(context).primaryColor),
                      Text(
                        AppLocalizations.of(context)
                            .translate("add new address"),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  AppLocalizations.of(context).translate("no addresses"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xffF54D40),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressBottomSheet(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: titleController,
                    labelText:
                        AppLocalizations.of(context).translate("address title"),
                    prefixIcon: Icons.title_sharp,
                    validator: (text) => text == null || text.trim().isEmpty
                        ? 'Please enter the title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: phoneController,
                    labelText: AppLocalizations.of(context).translate("phone"),
                    prefixIcon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      // Check if the phone number starts with 0 and has exactly 11 digits
                      if (!RegExp(r'^0[0-9]{10}$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null; // Validation passed
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<AllProductsCubit, AllProductsState>(
                    builder: (context, state) {
                      List<City> cities = [];
                      bool isLoading = false;
                      if (state is AllProductsLoading) {
                        isLoading = true;
                      } else if (state is AllProductsSuccess) {
                        cities = state.allProductsModel.cities ?? [];
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   AppLocalizations.of(context).translate("city"),
                          //   style: const TextStyle(
                          //       fontSize: 16, fontWeight: FontWeight.w500),
                          // ),
                          // const SizedBox(height: 5),
                          isLoading
                              ? const LinearProgressIndicator()
                              : DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(20),
                                  dropdownColor: Colors.white,
                                  initialValue:
                                      cityController.text.isNotEmpty &&
                                              cities.any((city) =>
                                                  (AppLocalizations.of(context)
                                                              .locale
                                                              .languageCode ==
                                                          'ar'
                                                      ? city.titleAr
                                                      : city.titleEn) ==
                                                  cityController.text)
                                          ? cityController.text
                                          : null,
                                  hint: Text(AppLocalizations.of(context)
                                      .translate("choose_city")),
                                  items: cities.map((city) {
                                    String cityName =
                                        AppLocalizations.of(context)
                                                    .locale
                                                    .languageCode ==
                                                'ar'
                                            ? city.titleAr!
                                            : city.titleEn!;
                                    return DropdownMenuItem<String>(
                                      value: cityName,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(cityName),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      cityController.text = value ?? "";
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select your city';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: kMainColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: addressController,
                    labelText:
                        AppLocalizations.of(context).translate("address"),
                    prefixIcon: Icons.location_on,
                    validator: (text) => text == null || text.trim().isEmpty
                        ? 'Please enter address'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  defaultButton(
                    function: () {
                      if (formKey.currentState!.validate()) {
                        if (titleController.text.isNotEmpty &&
                            phoneController.text.isNotEmpty &&
                            addressController.text.isNotEmpty &&
                            cityController.text.isNotEmpty) {
                          AddressModel address = AddressModel(
                            address:
                                "${cityController.text}, ${addressController.text}",
                            phone: phoneController.text,
                            title: titleController.text,
                          );

                          BlocProvider.of<AddressCubit>(context)
                              .addAddress(address);
                        }
                      }
                    },
                    text: AppLocalizations.of(context).translate("add address"),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 2, 15, 0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade400,
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
}
