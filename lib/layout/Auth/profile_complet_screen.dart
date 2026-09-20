import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vegesea/models/user_model.dart';

import '../../cubits/profile_cubit/profile_cubit.dart';
import '../../shared/shared/app_localization.dart';
import '../../shared/shared/components/components.dart';
import '../root_view.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final UserModel user;

  const ProfileCompletionScreen({super.key, required this.user});

  @override
  _ProfileCompletionScreenState createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _phoneController,
                labelText: AppLocalizations.of(context).translate("phone"),
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
              const SizedBox(height: 20),
              defaultButton(
                function: () {
                  if (_formKey.currentState!.validate()) {
                    // Update the user's phone number
                    widget.user.phone = _phoneController.text;

                    // Save the updated user profile (you can call your backend API here)
                    // For now, just navigate to the root view
                    BlocProvider.of<ProfileCubit>(context).updateProfile(
                        UserModel(phone: _phoneController.text), "");
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const RootView(),
                      ),
                    );
                  }
                },
                text:
                    AppLocalizations.of(context).translate("save_and_continue"),
              ),
            ],
          ),
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
}
