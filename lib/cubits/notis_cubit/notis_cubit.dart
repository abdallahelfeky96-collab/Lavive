import 'package:bloc/bloc.dart';
import 'package:vegesea/models/notis_model.dart';
import 'package:vegesea/services/notis_services.dart';

part 'notis_state.dart';

class NotisCubit extends Cubit<NotisState> {
  NotisCubit() : super(NotisInitial());
  NotisCountModel? _lastNotisCount; // الاحتفاظ بالبيانات السابقة

  Future<void> getNotisCount() async {
    try {
      final notisCount = await fetchNotisCount();

      if (_lastNotisCount != notisCount) {
        _lastNotisCount = notisCount;
        emit(GetNotisCountSuccess(notisCount: notisCount));
      }
    } catch (e) {
      emit(GetNotisCountFaluire(e.toString()));
    }
  }

  Future<void> getAllNotis() async {
    try {
      final allNotis = await fetchAllNotis();
      emit(GetNotisSuccess(allnotis: allNotis));
    } catch (e) {
      emit(GetNotisFaluire(e.toString()));
    }
  }
}
