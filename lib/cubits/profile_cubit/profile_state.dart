part of 'profile_cubit.dart';

sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileSuccess extends ProfileState {
  final ProfileModel profile;
  ProfileSuccess(this.profile);
}

final class ProfileUpdateSuccess extends ProfileState {
  final UserModel profile;
  ProfileUpdateSuccess(this.profile);
}

final class ProfileFaluire extends ProfileState {
  final String errMessage;
  ProfileFaluire(this.errMessage);
}

final class ProfileDeletedLoading extends ProfileState {}

final class ProfileDeletedSuccess extends ProfileState {}

final class ProfileDeletedFailed extends ProfileState {
  final String errMessage;
  ProfileDeletedFailed(this.errMessage);
}
