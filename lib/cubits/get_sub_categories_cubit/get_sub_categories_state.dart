part of 'get_sub_categories_cubit.dart';

@immutable
sealed class GetSubCategoriesState {}

final class GetSubCategoriesInitial extends GetSubCategoriesState {}

final class GetSubCategoriesLoading extends GetSubCategoriesState {}

final class GetSubCategoriesSuccess extends GetSubCategoriesState {
  final SubCategoriesModel subCategories;

  GetSubCategoriesSuccess({required this.subCategories});
}

final class GetSubCategoriesFaluire extends GetSubCategoriesState {
  final String errorMessage;
  GetSubCategoriesFaluire(this.errorMessage);
}
