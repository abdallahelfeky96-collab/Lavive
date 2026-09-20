import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/models/profile_model.dart';
import 'package:vegesea/models/user_model.dart';
import 'package:vegesea/services/profile_services.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<void> getProfile() async {
    try {
      emit(ProfileLoading());

      final profile = await fetchProfile();
      emit(ProfileSuccess(profile));
      log("get profile==>>> ${profile.data!.email}");
      log("get profile==>>> ${profile.data}");
    } catch (error, stackTrace) {
      log("error profile==>>> ${error.toString()}");
      log("error profile==>>> ${stackTrace.toString()}");
      emit(ProfileFaluire(error.toString()));
    }
  }

  Future<void> updateProfile(UserModel profile, String imagePath) async {
    try {
      emit(ProfileLoading());
      await updateProfileService(profile, imagePath);
      emit(ProfileUpdateSuccess(profile));
      emit(ProfileSuccess(await fetchProfile()));
    } catch (error) {
      emit(ProfileFaluire(error.toString()));
    }
  }

  Future<void> deleteProfile() async {
    try {
      emit(ProfileLoading());
      await deleteProfileService();
      log("Account Deleted Successfully");

      // Clear token and other user data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      emit(ProfileDeletedSuccess());
    } catch (error) {
      log("Failed to delete profile: $error");
      emit(ProfileDeletedFailed(error.toString()));
    }
  }
}
