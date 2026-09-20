import 'package:bloc/bloc.dart';

import '../../models/wallet_model.dart';
import '../../services/wallet_services.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial());

  Future<void> fetchWalletBalance() async {
    try {
      emit(WalletLoading());
      final wallet = await getWalletBalance();
      emit(WalletSuccess(wallet));
    } catch (e) {
      emit(WalletFailure(e.toString()));
    }
  }

  void updateWalletBalance(double newBalance) {
    emit(WalletSuccess(WalletModel(balance: newBalance)));
  }
}
