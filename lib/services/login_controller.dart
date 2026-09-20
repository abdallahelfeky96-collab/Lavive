import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vegesea/models/user_details.dart';

class LoginController with ChangeNotifier {
  // object
  final _googleSignIn = GoogleSignIn(
    serverClientId:
        '649819481598-fktllb8b0cgnp1p6npgq33r5ak61413s.apps.googleusercontent.com',
  );
  GoogleSignInAccount? googleSignInAccount;
  UserDetails? userDetails;

  /*
  // Disabled as per customer request
  // fucntion for google login
  Future<UserModel?> googleLogin() async {
    try {
      googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        userDetails = UserDetails(
          displayName: googleSignInAccount!.displayName,
          email: googleSignInAccount!.email,
          photoURL: googleSignInAccount!.photoUrl,
          uid: googleSignInAccount!.id,
          provider: 'google',
        );
        log("Google Sign-In Success: ${userDetails!.displayName}");

        // Fetch device_token from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? deviceToken = prefs.getString("device_token");

        // Create a UserModel object with the user details
        UserModel user = UserModel(
          name: userDetails!.displayName,
          email: userDetails!.email,
          image: userDetails!.photoURL,
          provider: 'google',
          uid: userDetails!.uid,
          deviceToken: deviceToken,
        );

        notifyListeners();
        return user;
      }
    } catch (e, stackTrace) {
      log("Google Sign-In Error: $e");
      log("Stack Trace: $stackTrace");
    }
    return null;
  }

  // function for facebook login
  Future<UserModel?> facebooklogin() async {
    try {
      var result = await FacebookAuth.i.login(
        permissions: ["public_profile", "email"],
      );

      // check the status of our login
      if (result.status == LoginStatus.success) {
        final requestData = await FacebookAuth.i.getUserData(
          fields: "email, name, picture, id",
        );

        userDetails = UserDetails(
          displayName: requestData["name"],
          email: requestData["email"],
          photoURL: requestData["picture"]["data"]["url"] ?? " ",
          uid: requestData["id"],
          provider: 'facebook',
        );
        log("Facebook Sign-In Success: ${userDetails!.displayName}");

        // Fetch device_token from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? deviceToken = prefs.getString("device_token");

        // Create a UserModel object with the user details
        UserModel user = UserModel(
          name: userDetails!.displayName,
          email: userDetails!.email,
          image: userDetails!.photoURL,
          provider: 'facebook',
          uid: userDetails!.uid,
          deviceToken: deviceToken,
        );

        notifyListeners();
        return user;
      }
    } catch (e, stackTrace) {
      log("Facebook Sign-In Error: $e");
      log("Stack Trace: $stackTrace");
    }
    return null;
  }
  */

  // logout
  logout() async {
    try {
      googleSignInAccount = await _googleSignIn.signOut();
      await FacebookAuth.i.logOut();
    } catch (_) {}
    userDetails = null;
    notifyListeners();
  }
}
