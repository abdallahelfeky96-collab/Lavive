import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/wallet_model.dart';
import '../shared/shared/Network/end_points.dart';

Future<WalletModel> getWalletBalance() async {
  String? token = await SharedPreferences.getInstance()
      .then((value) => value.getString("token"));

  final url = Uri.parse("$BASE_URL/getWalletBalanceForClient");

  final response = await http.get(
    url,
    headers: {
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return WalletModel.fromJson(jsonResponse);
  } else {
    throw Exception("Failed to fetch wallet balance");
  }
}
