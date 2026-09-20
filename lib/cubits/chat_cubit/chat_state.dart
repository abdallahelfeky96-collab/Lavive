part of 'chat_cubit.dart';

class ChatState {}

final class ChatInitial extends ChatState {}

final class SendMessageSuccess extends ChatState {}

final class SendMessageFaluire extends ChatState {
  final String errMessage;

  SendMessageFaluire({required this.errMessage});
}

final class GetMyChatSuccess extends ChatState {
  final MessageModel myChat;

  GetMyChatSuccess({required this.myChat});
}

final class GetMyChatFaluire extends ChatState {
  final String errMessage;

  GetMyChatFaluire({required this.errMessage});
}

final class ChatErrorState extends ChatState {
  final String errMessage;

  ChatErrorState({required this.errMessage});
}
