part of 'favorites_cubit.dart';

sealed class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesSuccess extends FavoritesState {
  final GetAllFavoritesModel favorites;
  FavoritesSuccess(this.favorites);
}

class DeleteFromFavorite extends FavoritesState {}

class FavoritesFailure extends FavoritesState {
  final String errMessage;
  FavoritesFailure(this.errMessage);
}
