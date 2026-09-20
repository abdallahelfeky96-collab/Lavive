part of 'orders_cubit.dart';

sealed class OrdersState {
  const OrdersState();
}

final class OrdersInitial extends OrdersState {}

final class CreateOrderLoading extends OrdersState {}

final class CreateOrderSuccess extends OrdersState {
  final String createOrderSuccessMessage;
  CreateOrderSuccess(this.createOrderSuccessMessage);
}

final class CreateOrderFaluire extends OrdersState {
  final String CreateOrderFaluireMessage;
  CreateOrderFaluire(this.CreateOrderFaluireMessage);
}

final class GetOrdersLoading extends OrdersState {}

final class GetOrdersSuccess extends OrdersState {
  AllOrdersModel allOrders;
  GetOrdersSuccess(this.allOrders);
}

final class GetOrdersFaluire extends OrdersState {
  final String getOrdersFaluireMessage;
  GetOrdersFaluire(this.getOrdersFaluireMessage);
}

final class DeleteOrderSuccess extends OrdersState {
  final String deleteOrderSuccessMessage;
  DeleteOrderSuccess(this.deleteOrderSuccessMessage);
}

final class DeleteOrderFaluire extends OrdersState {
  final String deleteOrderFaluireMessage;
  DeleteOrderFaluire(this.deleteOrderFaluireMessage);
}

final class GetOneOrderLoading extends OrdersState {}

final class GetOneOrderSuccess extends OrdersState {
  final OneOrderModel order;
  GetOneOrderSuccess(this.order);
}

final class GetOneOrderSuccessFaluire extends OrdersState {
  final String getOneFaluireMessage;
  GetOneOrderSuccessFaluire(this.getOneFaluireMessage);
}

final class EditOrderLoading extends OrdersState {}

final class EditOrderSuccess extends OrdersState {
  final String message;
  EditOrderSuccess(this.message);
}

final class EditOrderFaluire extends OrdersState {
  final String message;
  EditOrderFaluire(this.message);
}

final class RefundOrderLoading extends OrdersState {}

final class RefundOrderSuccess extends OrdersState {
  final String message;
  RefundOrderSuccess(this.message);
}

final class RefundOrderFaluire extends OrdersState {
  final String message;
  RefundOrderFaluire(this.message);
}
