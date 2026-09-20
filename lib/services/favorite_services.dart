import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:vegesea/models/favorite_models.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';

Future<void> addToFavoriteService(AddToFavoriteModel favoriteProduct) async {
  String? token;
  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });
  final url = Uri.parse("$BASE_URL/favorite/product");
  final response = await http.post(url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(favoriteProduct.toJson()));
}

Future<void> deleteFromFavoriteService(int id) async {
  String? token;
  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });
  final url = Uri.parse("$BASE_URL/favorite/product/$id");
  final response = await http.delete(
    url,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    },
  );
}

Future<GetAllFavoritesModel> fetchFavorites() async {
  String? token;
  String langCode = "en";

  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
    langCode = value.getString("langCode") ?? "en";
  });
  final url = Uri.parse("$BASE_URL/favorite/product");
  final response = await http.get(url, headers: {
    "Accept": "application/json",
    'Authorization': 'Bearer $token',
    "lang": langCode,
  });

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return GetAllFavoritesModel.fromJson(jsonResponse);
  } else {
    throw Exception("Failed to load favorites");
  }
}
