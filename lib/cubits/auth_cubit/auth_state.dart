part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final String authSuccess;
  AuthSuccess(this.authSuccess);
}

final class RegAuthSuccess extends AuthState {
  final String regAuthSuccess;
  RegAuthSuccess(this.regAuthSuccess);
}

class PhoneVerificationSuccess extends AuthState {}

final class AuthFailure extends AuthState {
  final String errorMessage;
  AuthFailure(this.errorMessage);
}
