import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/models/notis_model.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';

Future<NotisCountModel> fetchNotisCount() async {
  String? token;
  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });
  final url = Uri.parse("$BASE_URL/notifications_count");
  final response = await http.get(url, headers: {
    "Content-Type": "application/json",
    'Authorization': 'Bearer $token'
  });
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return NotisCountModel.fromJson(jsonResponse);
  } else {
    throw Exception(response.body);
  }
}

Future<NotisModel> fetchAllNotis() async {
  String? token;
  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });
  final url = Uri.parse("$BASE_URL/notifications");
  final response = await http.get(url, headers: {
    "Content-Type": "application/json",
    'Authorization': 'Bearer $token'
  });
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return NotisModel.fromJson(jsonResponse);
  } else {
    throw Exception(response.body);
  }
}
