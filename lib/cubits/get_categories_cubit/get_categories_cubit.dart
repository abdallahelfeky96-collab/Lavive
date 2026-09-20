import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vegesea/models/all_categories_model.dart';
import 'package:vegesea/services/get_all_categories_sevice.dart';

part 'get_categories_state.dart';

class GetCategoriesCubit extends Cubit<GetCategoriesState> {
  AllCategories? cachedCategories;
  GetCategoriesCubit() : super(GetCategoriesInitial());

  Future<void> getCategories() async {
    try {
      emit(GetCategoriesLoaging());

      final categories = await fetchCategories();
      cachedCategories = categories;
      emit(GetCategoriesSuccess(categories));
    } catch (error) {
      emit(GetCategoriesFaluire(error.toString()));
    }
  }
}
