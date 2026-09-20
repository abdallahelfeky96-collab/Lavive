import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:vegesea/models/profile_model.dart';
import 'package:vegesea/models/user_model.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';

Future<ProfileModel> fetchProfile() async {
  String? token;

  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });
  final url = Uri.parse("$BASE_URL/profile");
  final response = await http.get(url, headers: {
    "Accept": "application/json",
    'Authorization': 'Bearer $token'
  });

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return ProfileModel.fromJson(jsonResponse);
  } else {
    throw Exception("Failed to load profile");
  }
}

Future<void> updateProfileService(UserModel profile, String imagePath) async {
  String? token, name, phone;

  // الحصول على الـ Token من SharedPreferences
  await SharedPreferences.getInstance().then((value) {
    token = value.getString("token");
  });

  // إعداد رابط API
  final url = Uri.parse("$BASE_URL/profile/update");

  // إنشاء طلب Multipart
  var request = http.MultipartRequest('POST', url);

  // إضافة الـ Authorization Header
  request.headers['Authorization'] = 'Bearer $token';

  // إضافة الصورة إذا كانت موجودة
  if (imagePath.isNotEmpty) {
    request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
  }

  // إضافة البيانات النصية
  request.fields['name'] = profile.name ?? '';
  request.fields['email'] = profile.email ?? '';
  request.fields['phone'] = profile.phone ?? '';

  // إرسال الطلب
  final response = await request.send();

  // قراءة استجابة الخادم
  final responseBody = await http.Response.fromStream(response);

  if (response.statusCode == 200) {
    final responseData = jsonDecode(responseBody.body);
    log("update profile responseData==>> $responseData");
    name = responseData['data']['name'];
    phone = responseData['data']['phone'];

    // تحديث SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("name", name!);
  } else {
    print("Failed to update profile: ${responseBody.body}");
  }
}

Future<void> deleteProfileService() async {
  String? token;

  // Retrieve the token from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  token = prefs.getString("token");

  // API endpoint for deleting the profile
  final url = Uri.parse("$BASE_URL/delete/profile");

  // Create the HTTP request
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    log("Profile deleted: ${response.body}");
  } else {
    throw Exception("Failed to delete profile: ${response.body}");
  }
}
