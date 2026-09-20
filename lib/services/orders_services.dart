import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:vegesea/models/all_orders_model.dart';
import 'package:vegesea/models/one_order_model.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';
import 'package:vegesea/shared/shared/constants.dart';

final Dio _dio = Dio()
  ..interceptors.add(
    TalkerDioLogger(
      settings: const TalkerDioLoggerSettings(
        printRequestHeaders: true,
        printResponseHeaders: false,
        printResponseData: true,
      ),
    ),
  );

Future<AllOrdersModel> fetchAllOrders() async {
  if (token == null) {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  try {
    final response = await _dio.get(
      "$BASE_URL/order",
      options: Options(
        headers: {
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      return AllOrdersModel.fromJson(response.data);
    } else {
      throw Exception("Failed to load orders");
    }
  } catch (e) {
    throw Exception("Failed to load orders: $e");
  }
}

Future<OneOrderModel> fetchOrder(dynamic orderID) async {
  if (token == null) {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  try {
    final response = await _dio.get(
      "$BASE_URL/order/$orderID",
      options: Options(
        headers: {
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final model = OneOrderModel.fromJson(response.data);
      if (model.data == null) {
        throw Exception("Order details not found on server.");
      }
      return model;
    } else {
      throw Exception("Failed to load order");
    }
  } catch (e) {
    throw Exception("Failed to load order: $e");
  }
}
/// Edit Order
Future<void> addToOrder(Map<String, dynamic> body) async {
  if (token == null) {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  try {
    final response = await _dio.post(
      "$BASE_URL/$ADD_TO_ORDER",
      data: body,
      options: Options(
        headers: {
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.data['msg'] ?? "Failed to update order");
    }
  } catch (e) {
    if (e is DioException && e.response?.data != null) {
      final message = e.response?.data['message'] ?? e.response?.data['msg'] ?? e.toString();
      throw Exception(message);
    }
    throw Exception("Failed to update order: $e");
  }
}
