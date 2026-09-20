import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/promo_code_model.dart';
import '../shared/shared/Network/end_points.dart';

Future<PromoCodeModel> validatePromoCode(String code) async {
  String? token = await SharedPreferences.getInstance()
      .then((value) => value.getString("token"));

  final url = Uri.parse("$BASE_URL/promocodes/validate");

  final response = await http.post(
    url,
    headers: {
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({"code": code}),
  );

  final jsonResponse = jsonDecode(response.body);
  return PromoCodeModel.fromJson(jsonResponse);
}
