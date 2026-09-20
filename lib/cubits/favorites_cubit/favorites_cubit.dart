import 'package:bloc/bloc.dart';
import 'package:vegesea/models/favorite_models.dart';
import 'package:vegesea/services/favorite_services.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesInitial());

  Future<void> getAllFavorites() async {
    try {
      emit(FavoritesLoading());
      final favorites = await fetchFavorites();
      emit(FavoritesSuccess(favorites));
    } catch (error) {
      emit(FavoritesFailure(error.toString()));
    }
  }

  Future<void> deleteFromFavorite(int id) async {
    try {
      await deleteFromFavoriteService(id);
      emit(DeleteFromFavorite());
    } catch (e) {}
  }
}
