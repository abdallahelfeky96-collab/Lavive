part of 'all_products_cubit.dart';

sealed class AllProductsState {}

final class AllProductsInitial extends AllProductsState {}

final class AllProductsLoading extends AllProductsState {}

final class AllProductsSuccess extends AllProductsState {
  final AllProductsModel allProductsModel;
  AllProductsSuccess({required this.allProductsModel});
}

final class AllProductsFailure extends AllProductsState {
  final String error;
  AllProductsFailure({required this.error});
}
