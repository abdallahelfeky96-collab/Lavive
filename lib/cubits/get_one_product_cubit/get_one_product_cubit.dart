import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vegesea/models/one_product_model.dart';
import 'package:vegesea/services/get_one_product_service.dart';

part 'get_one_product_state.dart';

class GetOneProductCubit extends Cubit<GetOneProductState> {
  GetOneProductCubit() : super(GetOneProductInitial());

  Future<void> getOneProduct(String productID) async {
    try {
      emit(GetOneProductLoading());

      final product = await fetchOneProduct(productID);
      emit(GetOneProductSuccess(product: product));
    } catch (error) {
      emit(GetOneProductFaluire(errMessage: error.toString()));
    }
  }
}
