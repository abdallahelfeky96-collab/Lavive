import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vegesea/shared/shared/Network/end_points.dart';

Future<void> resetPasswordService(String email) async {
  final url = Uri.parse("$BASE_URL/password/reset");
  final response = await http.post(url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({'email': email}));
  if (response.statusCode == 200) {
  } else {
    throw Exception('Failed to reset password');
  }
}

Future<Map<String, dynamic>> checkCodeService(CheckCode checkCode) async {
  final url = Uri.parse("$BASE_URL/password/reset_with_code");

  final response = await http.post(
    url,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      'code': checkCode.code.trim(),
      'email': checkCode.email.trim(),
      'password': checkCode.password,
      'password_confirmation': checkCode.password_confirmation
    }),
  );

  return jsonDecode(response.body);
}

class CheckCode {
  final String code, email, password, password_confirmation;

  CheckCode(
      {required this.code,
      required this.email,
      required this.password,
      required this.password_confirmation});
}
