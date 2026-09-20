part of 'get_one_product_cubit.dart';

@immutable
sealed class GetOneProductState {}

final class GetOneProductInitial extends GetOneProductState {}

final class GetOneProductLoading extends GetOneProductState {}

final class GetOneProductSuccess extends GetOneProductState {
  final ProductModel product;

  GetOneProductSuccess({required this.product});
}

final class GetOneProductFaluire extends GetOneProductState {
  final String errMessage;

  GetOneProductFaluire({required this.errMessage});
}
