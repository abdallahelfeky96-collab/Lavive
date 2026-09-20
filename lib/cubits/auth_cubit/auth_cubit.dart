import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/models/user_model.dart';
import 'package:vegesea/models/virefy_phone_model.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';
import 'package:vegesea/services/marketing_service.dart';

import '../../shared/shared/constants.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  bool isSignInDone = false;
  String? _token;
  String? name;
  String? email;
  String? phone;
  String? image;
  Future<void> registerUser(UserModel user) async {
    emit(AuthLoading());

    final url = Uri.parse("$BASE_URL/client/$REGISTER");
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      if (responseBody['status'] == false) {
        if (responseBody["code"] == 203) {
          emit(RegAuthSuccess(
              'User registered successfully!\nnow you can sign in!'));
          log("User registered successfully");
          // Facebook CompleteRegistration event for ad optimisation.
          MarketingService.instance.logCompleteRegistration();
        }

        String errorMessage = '';
        if (responseBody['errors'] != null) {
          if (responseBody['errors']['email'] != null) {
            errorMessage = 'This email is already in use.';
            log("This email is already in use.");
          }
          if (responseBody['errors']['phone'] != null) {
            errorMessage = 'This phone number is already in use.';
            log("This phone number is already in use.");
          }

          emit(AuthFailure(errorMessage));
        }
      }
    } else {
      emit(AuthFailure(
          "'Failed to register user. Status code: ${response.statusCode}'"));
      log("'Failed to register user. Status code: ${response.statusCode}'");
      log("Redirect Location: ${response.headers['location']}");
    }
  }

  Future<void> verifyPhoneNumper(
      VeriryPhoneModel phoneModel, BuildContext context) async {
    emit(AuthLoading());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = Uri.parse("$BASE_URL/client/verify");
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "lang": "ar",
      },
      body: jsonEncode(phoneModel.toJson()),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['status'] == true) {
        _token = responseBody["data"]["token"];
        name = responseBody['data']['name'];
        email = responseBody['data']['email'];
        phone = responseBody['data']['phone'];
        image = responseBody['data']['image']; // Capture image

        await prefs.setString("name", name ?? "");
        await prefs.setString("email", email ?? "");
        await prefs.setString("phone", phone ?? "");
        if (image != null) await prefs.setString("image", image!); // Save image
        await prefs.setBool("IsSignInDone", true);

        await prefs.setString("token", _token!);
        token = prefs.getString("token");
        log("token===>>$token");

        emit(PhoneVerificationSuccess());
        log("Phone verification successful");
      } else {
        emit(AuthFailure(responseBody['msg'] ?? "Phone verification failed"));
        log("Phone verification failed: ${responseBody['msg']}");
      }
    } else {
      emit(AuthFailure(
          "Failed to verify phone number. Status code: ${response.statusCode}"));
      log("Failed to verify phone number. Status code: ${response.statusCode}");
    }
  }

  Future<void> loginUser(UserModel user, BuildContext context) async {
    emit(AuthLoading());
    try {
      log("Call API===>>>>>>");
      final url = Uri.parse("$BASE_URL/client/$LOGIN");
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(user.toJson()),
      );

      log("Response: ${response.body}");
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        log("Response Body: $responseBody");

        if (responseBody["status"] == true && responseBody["data"] != null) {
          _token = responseBody["data"]["token"];
          name = responseBody["data"]["name"];
          email = responseBody["data"]["email"];
          phone = responseBody["data"]["phone"];
          image = responseBody['data']['image']; // Capture image

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("name", name ?? "");
          await prefs.setString("email", email ?? "");
          await prefs.setString("phone", phone ?? "");
          if (image != null) {
            await prefs.setString("image", image!); // Save image
          }
          await prefs.setString("token", _token ?? "");
          await prefs.setBool("IsSignInDone", true);

          token = prefs.getString("token");
          log("Token Saved: $token");
          emit(AuthSuccess("Login successful"));
        } else {
          log("Invalid response: ${responseBody["message"] ?? "No data"}");
          emit(AuthFailure(
              responseBody["message"] ?? "Email or Password is incorrect"));
        }
      } else {
        log("HTTP Error: ${response.body}");
        emit(AuthFailure("Login failed"));
      }
    } catch (e, stackTrace) {
      log("Exception: $e");
      log("StackTrace: $stackTrace");
      emit(AuthFailure("Something went wrong. Please try again."));
    }
  }

  Future<void> socialLoginUser(UserModel user, BuildContext context) async {
    emit(AuthLoading());
    try {
      log("Call API===>>>>>>");
      final url = Uri.parse("$BASE_URL$SOCIALLOGIN");

      /// /client/social/login
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(user.toJson()),
      );

      log("Response: ${response.body}");
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        log("Response Body: $responseBody");

        if (responseBody["status"] == true && responseBody["data"] != null) {
          _token = responseBody["data"]["token"];
          name = responseBody["data"]["name"];
          email = responseBody["data"]["email"];
          phone = responseBody["data"]["phone"];
          image = responseBody['data']['image']; // Capture image

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("name", name ?? "");
          await prefs.setString("email", email ?? "");
          await prefs.setString("phone", phone ?? "");
          if (image != null) {
            await prefs.setString("image", image!); // Save image
          }
          await prefs.setString("token", _token ?? "");
          await prefs.setBool("IsSignInDone", true);

          token = prefs.getString("token");
          log("Token Saved: $token");
          emit(AuthSuccess("Login successful"));
        } else {
          log("Invalid response: ${responseBody["message"] ?? "No data"}");
          emit(AuthFailure(responseBody["message"] ?? "Social Login failed"));
        }
      } else {
        log("HTTP Error: ${response.body}");
        emit(AuthFailure("Social Login failed: ${response.statusCode}"));
      }
    } catch (e, stackTrace) {
      log("Exception: $e");
      log("StackTrace: $stackTrace");
      emit(AuthFailure("Something went wrong. Please try again."));
    }
  }
}
