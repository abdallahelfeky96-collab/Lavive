import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:vegesea/models/products_model.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';

Future<ProductsModel> fetchProducts(String catNumber) async {
  String langCode = "en";
  await SharedPreferences.getInstance().then((value) {
    langCode = value.getString("langCode") ?? "en";
  });
  final url = Uri.parse("$BASE_URL/sub-category/$catNumber");

  final response = await http
      .get(url, headers: {"Accept": "application/json", "lang": langCode});

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    return ProductsModel.fromJson(responseBody);
  } else {
    throw Exception("Failed to load categories");
  }
}
