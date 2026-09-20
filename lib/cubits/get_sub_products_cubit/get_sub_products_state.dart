part of 'get_sub_products_cubit.dart';

@immutable
sealed class GetSubProductsState {}

final class GetSubProductsInitial extends GetSubProductsState {}

final class GetSubProductsLoading extends GetSubProductsState {}

final class GetSubProductsSuccess extends GetSubProductsState {
  final SubProductsModel subProducts;

  GetSubProductsSuccess({required this.subProducts});
}

final class GetSubProductsFaluire extends GetSubProductsState {
  final String errMessage;

  GetSubProductsFaluire({required this.errMessage});
}
