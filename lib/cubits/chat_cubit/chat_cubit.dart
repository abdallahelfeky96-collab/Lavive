import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:vegesea/models/message_model.dart';
import 'package:vegesea/services/chat_services.dart';

import '../../shared/shared/Network/end_points.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  late PusherChannelsFlutter pusher;
  late PusherChannel channel;
  MessageModel? cachedMessages; // Variable to store cached messages

  ChatCubit() : super(ChatInitial()) {
    _initPusher();
    _initFirebaseListener();
  }

  void _initFirebaseListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Firebase Message Received in Foreground: ${message.data}");
      // Check if it's a chat message
      bool isChat = message.notification?.title == "لديك رسالة جديدة" ||
          message.notification?.title == "New Message" ||
          message.data['type'] == 'chat';

      if (isChat) {
        print("💬 Refreshing chat due to Firebase notification...");
        getMyChat();
      }
    });
  }

  void _initPusher() async {
    print("🚀 Initializing Pusher...");
    print("App ID: 2102618"); // Provided by user
    print("Cluster: eu");

    pusher = PusherChannelsFlutter.getInstance();

    try {
      await pusher.init(
        apiKey: "61b3bb288980fb285312",
        cluster: "eu",
        authEndpoint: "$BASE_URL/chat",
        onConnectionStateChange: (currentState, previousState) {
          print(
              "📡 Pusher Connection State: $currentState (was: $previousState)");
          if (currentState == 'DISCONNECTED') {
            emit(ChatErrorState(errMessage: "Pusher disconnected"));
          }
        },
        onError: (message, code, error) {
          print("❌ Pusher Error: $message | Code: $code | Error: $error");
          emit(ChatErrorState(errMessage: "Pusher error: $message"));
        },
        onEvent: (event) {
          print(
              "📥 Global Event Received: ${event.eventName} | Data: ${event.data}");
        },
        onSubscriptionSucceeded: (channelName, data) {
          print("✅ Subscribed successfully to channel: $channelName");
        },
        onSubscriptionError: (message, error) {
          print("❌ Subscription Error for channel: $message | Error: $error");
        },
      );

      await pusher.connect();
      print("🔗 Pusher connected successfully!");

      // Subscribe to the channel
      channel = await pusher.subscribe(
        channelName: 'admin_channel',
        onEvent: (event) {
          print("📩 Channel Event Received: ${event.eventName}");
          print("📊 Event Data: ${event.data}");

          if (event.eventName == 'admin_event') {
            print("🔔 New message notification on Pusher!");

            try {
              // Try to parse the new message from event data for immediate update
              final dynamic rawData =
                  event.data is String ? jsonDecode(event.data) : event.data;

              // Handle potential nested 'message' or direct data
              Map<String, dynamic>? data;
              if (rawData is Map<String, dynamic>) {
                if (rawData.containsKey('message') &&
                    rawData['message'] is Map) {
                  data = Map<String, dynamic>.from(rawData['message']);
                } else if (rawData.containsKey('message') &&
                    rawData['message'] is String) {
                  data = rawData;
                } else {
                  data = rawData;
                }
              }

              if (data != null && data['message'] != null) {
                print("📝 Parsing message from Pusher data...");
                final newMessage = Messages.fromJson(data);
                _addNewMessageToState(newMessage);
              } else {
                print(
                    "ℹ️ Pusher data empty or nested differently, refreshing from API...");
              }
            } catch (e) {
              print("⚠️ Error parsing event data: $e");
            }

            // Always fetch from API to ensure sync, with a tiny delay to allow DB to catch up
            Future.delayed(
                const Duration(milliseconds: 700), () => getMyChat());
          }
        },
      );

      print("📡 Subscribed to channel: admin_channel");
    } catch (e) {
      print("⚠️ Pusher initialization error: $e");
    }
  }

  Future<void> sendMessageCubit(SendMessageModel message) async {
    try {
      // Add the sent message to the state immediately for pessimistic UI update
      final newMessage = Messages(
        message: message.message,
        createdAt: DateTime.now().toString(),
      );
      _addNewMessageToState(newMessage);

      await sendMessage(message);
      emit(SendMessageSuccess());

      // Refresh to get the actual ID from server
      getMyChat();
    } catch (e) {
      emit(SendMessageFaluire(errMessage: e.toString()));
    }
  }

  void _addNewMessageToState(Messages newMessage) {
    MessageModel? currentModel;
    if (state is GetMyChatSuccess) {
      currentModel = (state as GetMyChatSuccess).myChat;
    } else {
      currentModel = cachedMessages;
    }

    if (currentModel?.data != null) {
      List<Messages> currentMessages =
          List.from(currentModel!.data!.messages ?? []);

      // Avoid duplicate messages if the message already exists (e.g. by ID or content/time)
      final bool alreadyExists = currentMessages.any((m) =>
          (m.id != null && newMessage.id != null && m.id == newMessage.id) ||
          (m.message == newMessage.message &&
              (m.createdAt == newMessage.createdAt ||
                  m.id == null ||
                  newMessage.id == null)));

      if (!alreadyExists) {
        currentMessages.add(newMessage);

        final updatedData =
            currentModel.data!.copyWith(messages: currentMessages);
        final updatedChat = currentModel.copyWith(data: updatedData);

        // Update cache immediately so fallback UI (during SendMessageSuccess) is correct
        cachedMessages = updatedChat;

        emit(GetMyChatSuccess(myChat: updatedChat));
      }
    }
  }

  Future<void> getMyChat() async {
    try {
      final myChat = await fetchMyChat();
      print("Fetched chat messages: ${myChat.data!.messages}");
      cachedMessages = myChat; // Update cached messages
      emit(GetMyChatSuccess(myChat: myChat));
    } catch (e) {
      print("Failed to fetch chat messages: $e");
      emit(GetMyChatFaluire(errMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    pusher.disconnect();
    return super.close();
  }
}
