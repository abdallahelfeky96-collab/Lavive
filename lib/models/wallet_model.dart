class WalletModel {
  final double balance;

  WalletModel({required this.balance});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: double.tryParse(json['wallet_balance'].toString()) ?? 0.0,
    );
  }
}
