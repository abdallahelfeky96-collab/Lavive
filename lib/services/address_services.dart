import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:vegesea/models/address_model.dart';
import 'package:vegesea/models/get_all_addresses_model.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';

Future<void> addAddressService(AddressModel address) async {
  String? token;
  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });
  final url = Uri.parse("$BASE_URL/addresses");
  final response = await http.post(url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(address.toJson()));
  final responseBody = jsonDecode(response.body);
  log("Address is added==>>$responseBody");
  int responseCode = responseBody['code'];
}

Future<GetAllAddressesModel> fetchAllAddresses() async {
  String? token;
  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });
  final url = Uri.parse("$BASE_URL/addresses");
  final response = await http.get(url, headers: {
    "Accept": "application/json",
    'Authorization': 'Bearer $token'
  });
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return GetAllAddressesModel.fromJson(jsonResponse);
  } else {
    throw Exception("Failed to load addresses");
  }
}

Future<void> updateAddressService(AddressModel address, int id) async {
  String? token;
  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });
  final url = Uri.parse("$BASE_URL/addresses/$id");
  final response = await http.put(url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(address.toJson()));
}

Future<void> deleteAddressService(int id) async {
  String? token;
  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });
  final url = Uri.parse("$BASE_URL/addresses/$id");
  final response = await http.delete(
    url,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    },
  );
}
