import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/bloc/chat/chat_cubit.dart';
import 'package:chat/data/model/user.dart';
import 'package:chat/route.gr.dart';
import 'package:chat/theme/dimension.dart';
import 'package:chat/widgets/custom_circle_avatar_status.dart';
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

  // @override
  // void deactivate() async {
  //   await cubit.setSeen();
  //   super.deactivate();
  // }

  @override
  void dispose() async{
    super.dispose();
    await cubit.streamSub?.cancel();
    for (var element in cubit.messageList) {
      if (element.type == types.MessageType.custom) {
        element.metadata!["controller"].dispose();
      }
    }

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
          actions: [
            IconButton(onPressed: (){
              context.router.popAndPush(ProfilePageRoute(currentUser: cubit.currentUser,user: widget.userModel));
            }, icon: const Icon(Icons.info_outline, color: blue,))
          ],
        ),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
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
                  },
                  textMessageOptions:
                      const chat_ui.TextMessageOptions(isTextSelectable: false),
                  onEndReachedThreshold: 1.0,
                  onEndReached: () async {
                    await cubit.loadMore();
                  },
                  // imageMessageBuilder: ,
                  customBottomWidget: customBottomWidget(),
                  customMessageBuilder: customMessageBuilder),
            );
          },
        ));
  }

  Widget imageBuilder(types.ImageMessage image, {required int messageWidth}) {
    return CachedNetworkImage(
      imageUrl: image.uri,
      key: Key(image.name),
      placeholder: (context, str) {
        return AspectRatio(aspectRatio: image.metadata!["aspect_ratio"], child: Container(color: grey,),);
      },
    );
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (message.type == types.MessageType.text)
            TextButton.icon(
                onPressed: () async {
                  cubit.copyText(context, message);
                },
                icon: const Icon(Icons.copy),
                label: const Text("Copy")),
          if (message.type == types.MessageType.image ||
              message.type == types.MessageType.custom)
            TextButton.icon(
                onPressed: () {
                  cubit.downloadMedia(context, message);
                },
                icon: const Icon(Icons.save),
                label: const Text("Save")),
          if (cubit.user.id == message.author.id)
            TextButton.icon(
                onPressed: () {
                  cubit.removeMessage(message).then((value) {
                    Navigator.of(context).pop();
                  });
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
            Flexible(
                flex: 4,
                child: Row(
                  children: [
                    IconButton(
                      icon:
                      const Icon(Icons.attach_file, color: blue),
                      onPressed: () {},
                    ),
                    IconButton(
                        onPressed: () {
                          cubit.openCameraSelector(context);
                        },
                        key: cubit.secondKey,
                        icon: const Icon(
                          Icons.camera_alt,
                          color: blue,
                        )),
                    IconButton(
                      key: cubit.key,
                      icon: const Icon(Icons.perm_media_outlined,
                          color: blue),
                      onPressed: () {
                        cubit.openMediaSelector(context);
                      },
                    ),
                  ],
                )),
            Flexible(
                flex: 5,
                child: TextFormField(
                  controller: cubit.msgController,
                  autofocus: true,
                  decoration: InputDecoration(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10),
                    filled: true,
                    hintText: "Type your message...",
                    fillColor: grey_100,
                    border: OutlineInputBorder(
                        gapPadding: 0,
                        borderRadius: BorderRadius.circular(16)),
                  ),
                )),
            Flexible(
                flex: 1,
                child: IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: blue,
                  ),
                  onPressed: () async {
                    if (cubit.msgController.text.isNotEmpty) {
                      await cubit.sendMessage(types.PartialText(
                          text: cubit.msgController.text));
                      cubit.msgController.clear();
                    }
                  },
                ))
          ],
        ),
      ),
    );
  }

  // Widget customBottomWidget() {
  //   return cubit.isBlocked
  //       ? Align(
  //           alignment: Alignment.topCenter,
  //           child: Container(
  //               width: MediaQuery.of(context).size.width,
  //               height: size_200_h,
  //               padding: const EdgeInsets.all(10),
  //               margin: const EdgeInsets.all(10),
  //               decoration: BoxDecoration(
  //                   color: grey_100, borderRadius: BorderRadius.circular(16)),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   CustomCircleAvatarStatus(user: widget.userModel),
  //                   SizedBox(
  //                     height: size_5_h,
  //                   ),
  //                   Text(
  //                     widget.userModel.fullName,
  //                     style: header,
  //                   ),
  //                   SizedBox(
  //                     height: size_5_h,
  //                   ),
  //                   cubit.isBlockedByMe
  //                       ? SizedBox(
  //                           width: double.infinity,
  //                           child: TextButton(
  //                             child: const Text("Unblock"),
  //                             onPressed: () async {
  //                               await cubit.unblock();
  //                             },
  //                           ),
  //                         )
  //                       : Text(
  //                           "Blocked",
  //                           style: title,
  //                         ),
  //                 ],
  //               )),
  //         )
  //       : (cubit.isNotFriend
  //           ? Align(
  //               alignment: Alignment.topCenter,
  //               child: Container(
  //                 width: MediaQuery.of(context).size.width,
  //                 height: size_200_h,
  //                 padding: const EdgeInsets.all(10),
  //                 margin: const EdgeInsets.all(10),
  //                 decoration: BoxDecoration(
  //                     color: grey_100, borderRadius: BorderRadius.circular(16)),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     CustomCircleAvatarStatus(user: widget.userModel),
  //                     SizedBox(
  //                       height: size_5_h,
  //                     ),
  //                     Text(
  //                       widget.userModel.fullName,
  //                       style: header,
  //                     ),
  //                     SizedBox(
  //                       height: size_5_h,
  //                     ),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         TextButton(
  //                             onPressed: () async {
  //                               cubit.acceptButton(widget.userModel);
  //                             },
  //                             child: const Text("Accept")),
  //                         TextButton(
  //                             onPressed: () async {
  //                               cubit.cancelButton(widget.userModel, context);
  //                             },
  //                             child: const Text("Block"))
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             )
  //           : SafeArea(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(10.0),
  //                 child: Row(
  //                   children: [
  //                     Flexible(
  //                         flex: 4,
  //                         child: Row(
  //                           children: [
  //                             IconButton(
  //                               icon:
  //                                   const Icon(Icons.attach_file, color: blue),
  //                               onPressed: () {},
  //                             ),
  //                             IconButton(
  //                                 onPressed: () {
  //                                   cubit.openCameraSelector(context);
  //                                 },
  //                                 key: cubit.secondKey,
  //                                 icon: const Icon(
  //                                   Icons.camera_alt,
  //                                   color: blue,
  //                                 )),
  //                             IconButton(
  //                               key: cubit.key,
  //                               icon: const Icon(Icons.perm_media_outlined,
  //                                   color: blue),
  //                               onPressed: () {
  //                                 cubit.openMediaSelector(context);
  //                               },
  //                             ),
  //                           ],
  //                         )),
  //                     Flexible(
  //                         flex: 5,
  //                         child: TextFormField(
  //                           controller: cubit.msgController,
  //                           autofocus: true,
  //                           decoration: InputDecoration(
  //                             contentPadding:
  //                                 const EdgeInsets.symmetric(horizontal: 10),
  //                             filled: true,
  //                             hintText: "Type your message...",
  //                             fillColor: grey_100,
  //                             border: OutlineInputBorder(
  //                                 gapPadding: 0,
  //                                 borderRadius: BorderRadius.circular(16)),
  //                           ),
  //                         )),
  //                     Flexible(
  //                         flex: 1,
  //                         child: IconButton(
  //                           icon: const Icon(
  //                             Icons.send,
  //                             color: blue,
  //                           ),
  //                           onPressed: () async {
  //                             if (cubit.msgController.text.isNotEmpty) {
  //                               await cubit.sendMessage(types.PartialText(
  //                                   text: cubit.msgController.text));
  //                               cubit.msgController.clear();
  //                             }
  //                           },
  //                         ))
  //                   ],
  //                 ),
  //               ),
  //             ));
  // }
}
