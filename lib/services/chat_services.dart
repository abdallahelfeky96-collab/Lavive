import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vegesea/models/message_model.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';

Future<void> sendMessage(SendMessageModel message) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");

  final url = Uri.parse("$BASE_URL/chat");
  final response = await http.post(url,
      headers: {
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
        "Content-Type": "application/json",
      },
      body: jsonEncode(message.toJson()));

  if (response.statusCode != 200) {
    throw Exception("❌ Failed to send message");
  }
}

Future<MessageModel> fetchMyChat() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");

  final url = Uri.parse("$BASE_URL/chat");
  final response = await http.get(
    url,
    headers: {
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    return MessageModel.fromJson(responseBody);
  } else {
    throw Exception("❌ Failed to get messages");
  }
}
