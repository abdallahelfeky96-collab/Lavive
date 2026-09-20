import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:vegesea/models/popular_deals_model.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';

Future<PopularDeals> fetchPopularDeals() async {
  String langCode = "en";
  await SharedPreferences.getInstance().then((value) {
    langCode = value.getString("langCode") ?? "en";
  });
  final url = Uri.parse(
    "$BASE_URL/top-products",
  );

  final response = await http
      .get(url, headers: {"Accept": "application/json", "lang": langCode});
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return PopularDeals.fromJson(jsonResponse);
  } else {
    throw Exception("Faild to get Popular Deals");
  }
}
