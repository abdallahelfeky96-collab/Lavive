import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vegesea/models/sub_products_model.dart';
import 'package:vegesea/services/get_sub_products_service.dart';

part 'get_sub_products_state.dart';

class GetSubProductsCubit extends Cubit<GetSubProductsState> {
  GetSubProductsCubit() : super(GetSubProductsInitial());
  Future<void> getSubProducts(String subNumber) async {
    try {
      emit(GetSubProductsLoading());
      final subProducts = await fecthSubProducts(subNumber);
      emit(GetSubProductsSuccess(subProducts: subProducts));
    } catch (error) {
      emit(GetSubProductsFaluire(errMessage: error.toString()));
    }
  }
}
