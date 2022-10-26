import 'package:auto_route/auto_route.dart';
import 'package:better_player/better_player.dart';
import 'package:chat/bloc/chat/chat_cubit.dart';
import 'package:chat/data/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../theme/color.dart';
import '../../theme/style.dart';

class ChatScreen extends StatefulWidget implements AutoRouteWrapper {
  final UserModel userModel;
  final String chatID;

  const ChatScreen({Key? key, required this.userModel, required this.chatID})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(),
      child: this, // this as the child Important!
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatCubit cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cubit = BlocProvider.of(context);
    cubit.init(widget.userModel, widget.chatID);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cubit.streamSub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          backgroundColor: white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: black,
            ),
            onPressed: () {
              context.router.pop();
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userModel.fullName,
                style: header,
              ),
              Text(
                widget.userModel.isOnline ? "Online" : "Offline",
                style: widget.userModel.isOnline
                    ? subtitle.copyWith(color: green)
                    : subtitle,
              )
            ],
          ),
        ),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const CircularProgressIndicator();
            }
            return SafeArea(
              child: chat_ui.Chat(
                  messages: cubit.messageList,
                  onSendPressed: (msg) {},
                  user: cubit.user,
                  isLastPage: cubit.isEnd,
                  onEndReachedThreshold: 1.0,
                  onEndReached: () async {
                    await cubit.loadMore();
                  },
                  customBottomWidget: customBottomWidget(),
                  customMessageBuilder: customMessageBuilder),
            );
          },
        ));
  }

  Widget scrollToBottomButton() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 70),
          decoration: BoxDecoration(
              color: grey_100, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_downward,
              color: blue,
            ),
            onPressed: () {},
          ),
        ));
  }

  Widget customMessageBuilder(types.CustomMessage msg,
      {required int messageWidth}) {
    return AspectRatio(
      aspectRatio: msg.metadata!["aspect_ratio"],
      child: BetterPlayer(
        controller: msg.metadata!["controller"],
      ),
    );
  }

  Widget customBottomWidget() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
                flex: 3,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: blue),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: cubit.key,
                      icon: const Icon(Icons.perm_media_outlined, color: blue),
                      onPressed: () {
                        cubit.openMenu(context);
                      },
                    ),
                  ],
                )),
            Expanded(
                flex: 6,
                child: TextFormField(
                  controller: cubit.msgController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    filled: true,
                    hintText: "Type your message...",
                    fillColor: grey_100,
                    border: OutlineInputBorder(
                        gapPadding: 0, borderRadius: BorderRadius.circular(16)),
                  ),
                )),
            Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: blue,
                  ),
                  onPressed: () async {
                    if (cubit.msgController.text.isNotEmpty) {
                      await cubit.sendMessage(
                          types.PartialText(text: cubit.msgController.text));
                      cubit.msgController.clear();
                    }
                  },
                ))
          ],
        ),
      ),
    );
  }
}
