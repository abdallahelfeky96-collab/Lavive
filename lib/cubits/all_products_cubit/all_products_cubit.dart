import 'package:bloc/bloc.dart';
import 'package:vegesea/models/all_products_model.dart';
import 'package:vegesea/services/get_all_products_service.dart';

part 'all_products_state.dart';

class AllProductsCubit extends Cubit<AllProductsState> {
  AllProductsCubit() : super(AllProductsInitial());
  Future<void> getAllProducts() async {
    emit(AllProductsLoading());

    try {
      final allProducts = await fetchAllProducts();
      emit(AllProductsSuccess(allProductsModel: allProducts));
    } catch (e) {
      emit(AllProductsFailure(error: e.toString()));
    }
  }
}
