part of 'get_popular_deals_cubit.dart';

@immutable
sealed class GetPopularDealsState {}

final class GetPopularDealsInitial extends GetPopularDealsState {}

final class GetPopularDealsLoading extends GetPopularDealsState {}

final class GetPopularDealsSuccess extends GetPopularDealsState {
  final PopularDeals popularDeals;
  GetPopularDealsSuccess(this.popularDeals);
}

// ignore: must_be_immutable
final class GetPopularDealsFaluire extends GetPopularDealsState {
  String errMessage;
  GetPopularDealsFaluire(this.errMessage);
}
