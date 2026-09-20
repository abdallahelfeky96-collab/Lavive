part of 'notis_cubit.dart';

class NotisState {}

final class NotisInitial extends NotisState {}

final class GetNotisCountSuccess extends NotisState {
  final NotisCountModel notisCount;
  GetNotisCountSuccess({required this.notisCount});
}

final class GetNotisCountFaluire extends NotisState {
  final String errMessage;
  GetNotisCountFaluire(this.errMessage);
}

final class GetNotisLoading extends NotisState {}

final class GetNotisSuccess extends NotisState {
  final NotisModel allnotis;
  GetNotisSuccess({required this.allnotis});
}

final class GetNotisFaluire extends NotisState {
  final String errMessage;

  GetNotisFaluire(this.errMessage);
}
