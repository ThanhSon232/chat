import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:better_player/better_player.dart';
import 'package:chat/bloc/chat/chat_cubit.dart';
import 'package:chat/data/model/user.dart';
import 'package:chat/theme/dimension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

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
                  bubbleBuilder: bubbleBuilder,
                  onMessageLongPress: (context, msg) {
                    onLongPress(msg);
                    // print(msg.metadata?["key"]);
                  },
                  textMessageOptions:
                      const chat_ui.TextMessageOptions(isTextSelectable: false),
                  // onEndReachedThreshold: 1.0,
                  onEndReached: () async {
                    await cubit.loadMore();
                  },
                  customBottomWidget: customBottomWidget(),
                  customMessageBuilder: customMessageBuilder),
            );
          },
        ));
  }

  void onLongPress(types.Message message) {
    GlobalKey key = message.metadata?["key"];
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    bool isAuthor = cubit.user.id == message.author.id;
    Widget? child;
    if (message.type == types.MessageType.text) {
      message = message as types.TextMessage;
      child = Text(
        message.text,
        style: TextStyle(
            fontWeight: FontWeight.w600, color: isAuthor ? white : black),
      );
    } else if (message.type == types.MessageType.image) {
      message = message as types.ImageMessage;
      child = Image.network(message.uri);
    } else if (message.type == types.MessageType.custom) {
      child = BetterPlayer(
        controller: message.metadata?["controller"],
      );
    }

    showDialog(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.0,
              sigmaY: 10.0,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size_16_w),
              child: Stack(
                  alignment:
                      isAuthor ? Alignment.centerRight : Alignment.centerLeft,
                  children: [
                    Positioned(
                      top: position.dy - 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: isAuthor
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          previewBuilder(
                              child: child, box: box, message: message),
                          const SizedBox(
                            height: 10,
                          ),
                          menu(message: message)
                        ],
                      ),
                    ),
                  ]),
            ),
          );
        });
  }

  Widget previewBuilder(
      {Widget? child, required RenderBox box, required types.Message message}) {
    return Container(
      height: box.size.height,
      alignment: Alignment.center,
      width: box.size.width,
      decoration: BoxDecoration(
          color: message.type == types.MessageType.image
              ? grey_100
              : cubit.user.id == message.author.id
                  ? blue
                  : grey_100,
          borderRadius: BorderRadius.circular(16)),
      child: Center(child: child),
    );
  }

  Widget menu({required types.Message message}) {
    return Container(
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (message.type == types.MessageType.text)
            TextButton.icon(
                onPressed: () async {
                  message as types.TextMessage;
                  await Clipboard.setData(ClipboardData(text: message.text))
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Copied to your clipboard !'),
                      duration: Duration(milliseconds: 1000),
                    ));
                    Navigator.of(context).pop();
                  });
                },
                icon: const Icon(Icons.copy),
                label: const Text("Copy")),
          if (message.type == types.MessageType.image ||
              message.type == types.MessageType.custom)
            TextButton.icon(
                onPressed: ()  {
                  cubit.downloadMedia(message).then((value){
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Saved !!!'),
                      duration: Duration(milliseconds: 1000),
                    ));
                    Navigator.of(context).pop();

                  });
                },
                icon: const Icon(Icons.save),
                label: const Text("Save")),
          if (cubit.user.id == message.author.id)
            TextButton.icon(
                onPressed: () {
                  cubit.removeMessage(message);
                },
                icon: const Icon(Icons.delete),
                label: const Text("Remove")),
        ],
      ),
    );
  }

  Widget bubbleBuilder(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  }) {
    return Container(
      key: message.metadata?["key"],
      decoration: BoxDecoration(
          color: message.type == types.MessageType.image
              ? grey_100
              : cubit.user.id == message.author.id
                  ? blue
                  : grey_100,
          borderRadius: BorderRadius.circular(16)),
      child: child,
      // child: child,
    );
  }

  Widget scrollToBottomButton() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 70),
          decoration: BoxDecoration(color: grey_100, shape: BoxShape.circle),
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
      child: BetterPlayerMultipleGestureDetector(
        onLongPress: () {
          onLongPress(msg);
        },
        child: BetterPlayer(
          controller: msg.metadata!["controller"],
        ),
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
