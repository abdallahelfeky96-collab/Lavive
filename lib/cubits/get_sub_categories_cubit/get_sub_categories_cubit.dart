import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vegesea/models/sub_categories.dart';
import 'package:vegesea/services/get_sub_categories_service.dart';


part 'get_sub_categories_state.dart';

class GetSubCategoriesCubit extends Cubit<GetSubCategoriesState> {
  GetSubCategoriesCubit() : super(GetSubCategoriesInitial());
  Future<void> getSubCategoreis(int subNumber) async {
    try {
      emit(GetSubCategoriesLoading());
      final subCategories = await fecthSubCategories(subNumber);
      emit(GetSubCategoriesSuccess(subCategories: subCategories));
    } catch (error) {
      emit(GetSubCategoriesFaluire(error.toString()));
    }
  }
}
