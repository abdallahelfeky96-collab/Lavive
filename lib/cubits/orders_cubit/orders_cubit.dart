import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/models/all_orders_model.dart';
import 'package:vegesea/models/one_order_model.dart';
import 'package:vegesea/services/orders_services.dart';
import 'package:vegesea/shared/shared/Network/end_points.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersInitial());

  Future<void> getAllOrderes() async {
    try {
      emit(GetOrdersLoading());
      final allOrders = await fetchAllOrders();
      emit(GetOrdersSuccess(allOrders));
    } catch (e) {
      emit(GetOrdersFaluire(e.toString()));
    }
  }

  ////////////////////////////////////////////////////////////
  Future<void> getOneOrdere(dynamic orderID) async {
    try {
      emit(GetOneOrderLoading());
      final order = await fetchOrder(orderID);
      emit(GetOneOrderSuccess(order));
    } catch (e) {
      emit(GetOrdersFaluire(e.toString()));
    }
  }
  ////////////////////////////////////////////////////////////

  Future<void> deleteOrder(dynamic orderID) async {
    try {
      String? token;
      await SharedPreferences.getInstance().then((value) {
        token = value.getString("token");
      });
      final url = Uri.parse("$BASE_URL/close-order/$orderID");
      final response = await http.post(url, headers: {
        "Accept": "application/json",
        'Authorization': 'Bearer $token'
      });
      final responseBody = jsonDecode(response.body);
      if (responseBody['code'] == 403) {
        emit(DeleteOrderFaluire(responseBody['msg']));
      }
      if (response.statusCode != 200) {
        throw Exception("Failed to delete order");
      }
      if (responseBody['code'] == 201) {
        emit(DeleteOrderSuccess("Order Deleted Succefully"));
      }
    } catch (e) {
      emit(DeleteOrderFaluire(e.toString()));
    }
  }

  Future<void> editOrder(Map<String, dynamic> body) async {
    try {
      emit(EditOrderLoading());
      await addToOrder(body);
      emit(EditOrderSuccess("Order Updated Successfully"));
    } catch (e) {
      emit(EditOrderFaluire(e.toString()));
    }
  }

  Future<void> refundOrder(
      {required dynamic orderID, required String refundReason}) async {
    try {
      emit(RefundOrderLoading());
      String? token;
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString("token");

      final url = Uri.parse("$BASE_URL/refund-order/$orderID");
      log('Refund Order URL: $url');
      log('Refund Order Body: ${jsonEncode({'refund_reason': refundReason})}');

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'refund_reason': refundReason,
        }),
      );

      log('Refund Order Status: ${response.statusCode}');
      log('Refund Order Response: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['status'] == true || responseBody['code'] == 200) {
          emit(RefundOrderSuccess(
              responseBody['msg'] ?? "Refund requested successfully"));
        } else {
          emit(RefundOrderFaluire(
              responseBody['msg'] ?? "Failed to request refund"));
        }
      } else if (response.statusCode == 422) {
        String errorMsg = responseBody['message'] ?? "Validation Error";
        if (responseBody['errors'] != null && responseBody['errors'] is Map) {
          final errors = responseBody['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMsg = firstError[0].toString();
            }
          }
        }
        emit(RefundOrderFaluire(errorMsg));
      } else {
        emit(RefundOrderFaluire(responseBody['msg'] ??
            responseBody['message'] ??
            "An error occurred (${response.statusCode})"));
      }
    } catch (e) {
      emit(RefundOrderFaluire(e.toString()));
    }
  }
}
