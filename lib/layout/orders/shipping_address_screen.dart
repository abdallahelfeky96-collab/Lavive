import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/cubits/address_cubit/address_cubit.dart';
import 'package:vegesea/cubits/profile_cubit/profile_cubit.dart';
import 'package:vegesea/models/address_model.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import 'package:vegesea/cubits/all_products_cubit/all_products_cubit.dart';
import '../../shared/shared/app_localization.dart';
import '../../models/all_products_model.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ProfileCubit>(context).getProfile();
    BlocProvider.of<AllProductsCubit>(context).getAllProducts();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saveShippingAddress = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  //final zipController = TextEditingController();
  final cityController = TextEditingController();
  final addressTitleController = TextEditingController();
  final addressController = TextEditingController();
  // final notesController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    //zipController.dispose();
    cityController.dispose();
    addressTitleController.dispose();
    addressController.dispose();
    // notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileSuccess) {
          final profile = state.profile.data!;
          nameController.text = profile.name ?? "";
          phoneController.text = profile.phone ?? "";
          emailController.text = profile.email ?? "";
          return Scaffold(
            floatingActionButton: const MovableFloatingButton(),
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).translate('CheckOut')),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                const HomeButton(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StepIndicator(
                              isActive: true,
                              label: AppLocalizations.of(context)
                                  .translate('Delivery')),
                          StepIndicator(
                              isActive: true,
                              label: AppLocalizations.of(context)
                                  .translate('address')),
                          StepIndicator(
                              isActive: false,
                              label: AppLocalizations.of(context)
                                  .translate('payment')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      defaultFormField(
                          label: AppLocalizations.of(context)
                              .translate("full name"),
                          controller: nameController,
                          fillColor: const Color(0xffE3EBF0),
                          type: TextInputType.name,
                          validate: (s) {
                            if (s == null) {
                              return 'Please enter Full Name';
                            }
                            return null;
                          }),
                      const SizedBox(height: 20),
                      defaultFormField(
                        label: AppLocalizations.of(context).translate("email"),
                        controller: emailController,
                        fillColor: const Color(0xffE3EBF0),
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
                      ),
                      const SizedBox(height: 20),
                      defaultFormField(
                        label: AppLocalizations.of(context).translate("phone"),
                        controller: phoneController,
                        fillColor: const Color(0xffE3EBF0),
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
                      ),
                      const SizedBox(height: 20),
                      defaultFormField(
                        label: AppLocalizations.of(context)
                            .translate("address_title"),
                        controller: addressTitleController,
                        fillColor: const Color(0xffE3EBF0),
                        type: TextInputType.text,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address title';
                          }
                          return null; // Validation passed
                        },
                      ),
                      const SizedBox(height: 20),
                      defaultFormField(
                        label:
                            AppLocalizations.of(context).translate("address"),
                        controller: addressController,
                        fillColor: const Color(0xffE3EBF0),
                        type: TextInputType.text,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null; // Validation passed
                        },
                      ),
                      const SizedBox(height: 20),
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
                              Text(
                                AppLocalizations.of(context).translate("city"),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 5),
                              isLoading
                                  ? const LinearProgressIndicator()
                                  : DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      borderRadius: BorderRadius.circular(20),
                                      dropdownColor: Colors.white,
                                      initialValue: cityController.text.isNotEmpty &&
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
                                        fillColor: const Color(0xffE3EBF0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xff0E6328),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      buildDropdownField(
                        AppLocalizations.of(context).translate("country"),
                        AppLocalizations.of(context)
                            .translate("choose_your_country"),
                      ),
                      // const SizedBox(height: 10),
                      // defaultFormField(
                      //   label: AppLocalizations.of(context).translate("notes"),
                      //   controller: notesController,
                      //   fillColor: const Color(0xffE3EBF0),
                      //   type: TextInputType.multiline,
                      //   maxLines: 3,
                      //   hintText: AppLocalizations.of(context)
                      //       .translate("add order description"),
                      // ),
                      CheckboxListTile(
                        value: saveShippingAddress,
                        onChanged: (value) {
                          setState(() {
                            saveShippingAddress = value!;
                          });
                        },
                        title: Text(AppLocalizations.of(context)
                            .translate("save_shipping_address")),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 20),
                      BlocListener<AddressCubit, AddressState>(
                        listener: (context, state) {
                          if (state is AddAddressSuccess) {
                            // الانتقال إلى صفحة الدفع عند النجاح
                            //navigateTo(context, const PaymentFormScreen());
                            Navigator.of(context).pop();
                          } else if (state is AddAddressFaluire) {
                            // طباعة لتأكيد الوصول إلى حالة الفشل
                            print("Failed to add address");

                            // إظهار AlertDialog عند الفشل
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Error"),
                                  content: const Text("Error Add Address"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: defaultButton(
                          function: () async {
                            if (_formKey.currentState!.validate()) {
                              if (addressTitleController.text.isNotEmpty &&
                                  phoneController.text.isNotEmpty &&
                                  addressController.text.isNotEmpty &&
                                  cityController.text.isNotEmpty) {
                                AddressModel address = AddressModel(
                                  address: addressController.text,
                                  phone: phoneController.text,
                                  title: addressTitleController.text,
                                );
                                final prefs =
                                    await SharedPreferences.getInstance();
                                // await prefs.setString(
                                //     'order_notes', notesController.text);

                                await BlocProvider.of<AddressCubit>(context)
                                    .addAddress(address);
                              } else {
                                showSnackBarMessage(
                                    context,
                                    AppLocalizations.of(context)
                                        .translate("complete_all_fields"),
                                    Colors.red,
                                    Icons.error_outline);
                              }
                            }
                          },
                          text: AppLocalizations.of(context).translate('next'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  // Widget buildTextField(String label, String hint, {bool readOnly = false}) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(label,
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
  //       SizedBox(height: 5),

  //     ],
  //   );
  // }

  Widget buildDropdownField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          items: const [
            DropdownMenuItem(value: "Egypt", child: Text("Egypt")),
          ],
          onChanged: (value) {},
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffE3EBF0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: hint,
          ),
        ),
      ],
    );
  }
}

class StepIndicator extends StatelessWidget {
  final bool isActive;
  final String label;

  const StepIndicator({super.key, required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? const Color(0xff0E6328) : Colors.grey,
          child: isActive
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xff0E6328) : Colors.grey)),
      ],
    );
  }
}
