import 'package:bloc/bloc.dart';
import 'package:vegesea/models/banners_model.dart';
import 'package:vegesea/services/get_banners_service.dart';

part 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  BannersModel? cachedBanners; // Variable to store cached banners
  BannersCubit() : super(BannersInitial());

  Future<void> getBanners() async {
    emit(BannersLoading());
    try {
      final bannersModel = await fetchAllBanners();
      cachedBanners = bannersModel; // Cache the banners
      emit(BannersSuccess(bannersModel: bannersModel));
    } catch (e) {
      emit(BannersFailure(error: e.toString()));
    }
  }
}
