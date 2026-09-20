import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vegesea/models/popular_deals_model.dart';
import 'package:vegesea/services/get_popular_deals_service.dart';

part 'get_popular_deals_state.dart';

class GetPopularDealsCubit extends Cubit<GetPopularDealsState> {
  GetPopularDealsCubit() : super(GetPopularDealsInitial());

  Future<void> getPopularDeals() async {
    try {
      emit(GetPopularDealsLoading());
      final deals = await fetchPopularDeals();
      emit(GetPopularDealsSuccess(deals));
    } catch (error) {
      emit(GetPopularDealsFaluire(error.toString()));
    }
  }
}
