import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vegesea/cubits/chat_cubit/chat_cubit.dart';
import 'package:vegesea/models/message_model.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import '../../shared/shared/constants.dart';
import '../Auth/login.dart';
import '../Auth/register.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch initial chat messages
    BlocProvider.of<ChatCubit>(context).getMyChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate("live chat")),
        actions: const [
          HomeButton(),
        ],
      ),
      body: token == null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    defaultButton(
                      height: screenHeight * 0.059,
                      width: screenWidth * 0.5,
                      function: () async {
                        navigateTo(context, const ShopLoginScreen());
                      },
                      text: AppLocalizations.of(context).translate("login"),
                      isUpperCase: true,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    SizedBox(
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.055,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: kMainColor),
                            borderRadius: BorderRadius.circular(
                                CupertinoContextMenu.kOpenBorderRadius),
                          ),
                          child: TextButton(
                              onPressed: () {
                                navigateTo(context, const ShopRegisterScreen());
                              },
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate("create account"),
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        color: kMainColor,
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ))),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Expanded(
                    child: ChatMessageList(scrollController: _scrollController),
                  ),
                  ChatInputField(
                    textController: textController,
                    onSendMessage: () async {
                      if (textController.text.trim().isEmpty) return;
                      final message =
                          SendMessageModel(message: textController.text);
                      textController.clear();

                      // Scroll to bottom immediately (offset 0 in reverse mode)
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }

                      await BlocProvider.of<ChatCubit>(context)
                          .sendMessageCubit(message);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class ChatMessageList extends StatelessWidget {
  final ScrollController scrollController;

  const ChatMessageList({required this.scrollController, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final chatCubit = BlocProvider.of<ChatCubit>(context);
        List<Messages> messages = [];

        if (state is GetMyChatSuccess) {
          messages = state.myChat.data!.messages ?? [];
        } else if (chatCubit.cachedMessages?.data?.messages != null) {
          messages = chatCubit.cachedMessages!.data!.messages!;
        }

        if (messages.isEmpty) {
          if (state is ChatInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: CircularProgressIndicator());
          /* return Center(
              child: Text(
            AppLocalizations.of(context).translate("No messages yet."),
            style: GoogleFonts.poppins(color: Colors.grey),
          ));*/
        }

        // Reverse messages so the newest is at the bottom (index 0) in the reversed list view
        final reversedMessages = messages.reversed.toList();

        return ListView.builder(
          reverse: true, // Start from bottom
          controller: scrollController,
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          itemCount: reversedMessages.length,
          itemBuilder: (context, index) {
            final message = reversedMessages[index];
            final isSender = message.adminId == null;
            final isSending = message.id == null;

            return Align(
              alignment:
                  isSender ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSender ? kMainColor : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft:
                        isSender ? const Radius.circular(20) : Radius.zero,
                    bottomRight:
                        isSender ? Radius.zero : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.message ?? "",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: isSender ? Colors.white : Colors.black87,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (isSender) ...[
                      const SizedBox(height: 6),
                      if (isSending)
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.white70,
                        )
                      else
                        const Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ChatInputField extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSendMessage;

  const ChatInputField({
    required this.textController,
    required this.onSendMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          blurStyle: BlurStyle.outer,
          blurRadius: 2,
          offset: Offset.fromDirection(10),
        )
      ], borderRadius: BorderRadius.circular(32), color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration:
                  const InputDecoration.collapsed(hintText: 'Say something...'),
            ),
          ),
          CircleAvatar(
            maxRadius: 25,
            backgroundColor: kMainColor,
            child: IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: onSendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
