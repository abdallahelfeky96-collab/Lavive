import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vegesea/models/all_products_model.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';

Future<AllProductsModel> fetchAllProducts() async {
  String langCode = "en";
  await SharedPreferences.getInstance().then((value) {
    langCode = value.getString("langCode") ?? "en";
  });

  final url = Uri.parse("$BASE_URL/all_products");
  final response = await http
      .get(url, headers: {"Accept": "application/json", "lang": langCode});

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return AllProductsModel.fromJson(jsonResponse);
  } else {
    throw Exception("Failed to load all products");
  }
}
