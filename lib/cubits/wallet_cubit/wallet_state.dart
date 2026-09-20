import 'package:equatable/equatable.dart';

import '../../models/wallet_model.dart';

sealed class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

final class WalletInitial extends WalletState {}

final class WalletLoading extends WalletState {}

final class WalletSuccess extends WalletState {
  final WalletModel wallet;
  const WalletSuccess(this.wallet);

  @override
  List<Object> get props => [wallet];
}

final class WalletFailure extends WalletState {
  final String message;
  const WalletFailure(this.message);

  @override
  List<Object> get props => [message];
}
