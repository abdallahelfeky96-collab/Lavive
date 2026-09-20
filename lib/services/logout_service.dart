import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vegesea/shared/shared/Network/end_points.dart';

Future<void> logoutService() async {
  String? token;
  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });
  final url = Uri.parse("$BASE_URL/client/logout");
  final response = await http.post(url, headers: {
    "Accept": "application/json",
    'Authorization': 'Bearer $token',
  });
}
