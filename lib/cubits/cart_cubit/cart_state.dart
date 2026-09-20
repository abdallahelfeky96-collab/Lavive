part of 'cart_cubit.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

final class CartInitial extends CartState {}

final class CartSuccess extends CartState {
  final List<ProductModel> products;

  const CartSuccess(this.products);

  @override
  List<Object> get props => [products];
}
