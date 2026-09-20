import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vegesea/models/products_model.dart';
import 'package:vegesea/services/get_one_category_with_products_sevice.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  Future<void> getProducts(String catNumber) async {
    try {
      emit(ProductsLoading());

      final products = await fetchProducts(catNumber);

      emit(ProductsSuccess(products));
    } catch (error) {
      emit(ProductsFailure(error.toString()));
    }
  }
}
