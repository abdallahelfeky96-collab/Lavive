part of 'banners_cubit.dart';

sealed class BannersState {}

final class BannersInitial extends BannersState {}

final class BannersLoading extends BannersState {}

final class BannersSuccess extends BannersState {
  final BannersModel bannersModel;
  BannersSuccess({required this.bannersModel});
}

final class BannersFailure extends BannersState {
  final String error;
  BannersFailure({required this.error});
}
