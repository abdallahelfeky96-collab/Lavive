part of 'get_categories_cubit.dart';

@immutable
sealed class GetCategoriesState {}

final class GetCategoriesInitial extends GetCategoriesState {}

final class GetCategoriesLoaging extends GetCategoriesState {}

final class GetCategoriesSuccess extends GetCategoriesState {
  final AllCategories categories;
  GetCategoriesSuccess(this.categories);
}

final class GetCategoriesFaluire extends GetCategoriesState {
  final String errorMessage;
  GetCategoriesFaluire(this.errorMessage);
}
