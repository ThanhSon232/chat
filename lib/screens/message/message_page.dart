import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/bloc/message/message_cubit.dart';
import 'package:chat/theme/color.dart';
import 'package:chat/theme/dimension.dart';
import 'package:chat/theme/style.dart';
import 'package:chat/widgets/custom_circle_avatar.dart';
import 'package:chat/widgets/custom_circle_avatar_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skeletons/skeletons.dart';

import '../../route.gr.dart';

class MessagePage extends StatefulWidget implements AutoRouteWrapper {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => MessageCubit(),
      child: this, // this as the child Important!
    );
  }
}

class _MessagePageState extends State<MessagePage> {
  late MessageCubit cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cubit = BlocProvider.of(context);
    cubit.init();
  }

  @override
  void dispose() {
    super.dispose();
    cubit.streamSub?.cancel();
    cubit.timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = SizedBox(
      height: size_20_h,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        title: Text(
          "Messages",
          style: header.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          BlocBuilder<MessageCubit, MessageState>(
            buildWhen: (prev, cur) => prev != cur && cur is MessageInitial,
            builder: (context, state) {
              if (state is MessageLoading) {
                return const SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                      shape: BoxShape.circle, width: 30, height: 30),
                );
              }
              return CachedNetworkImage(
                imageUrl: cubit.currentUser.avatarURL,
                cacheKey: cubit.currentUser.avatarURL,
                errorWidget: (
                  BuildContext context,
                  String url,
                  dynamic error,
                ) {
                  return CircleAvatar(
                    child: Text(cubit.currentUser.fullName[0]),
                  );
                },
                imageBuilder: (context, imageProvider) {
                  return CircleAvatar(
                    backgroundImage: imageProvider,
                  );
                },
              );
            },
          )
        ],
      ),
      backgroundColor: white,
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: size_15_w, vertical: size_10_h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [searchBar(), spacing, onlineUserList(), messageList()],
        ),
      ),
    );
  }

  Widget searchBar() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search,
          color: grey,
        ),
        hintText: "Search",
        contentPadding: EdgeInsets.zero,
        fillColor: grey_100,
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget onlineUserList() {
    return BlocConsumer<MessageCubit, MessageState>(
      listener: (context, state) {
        if (state is MessageOnlineUserLoaded) {
          cubit.userList = state.userList;
        }
      },
      buildWhen: (prev, cur) => prev != cur && cur is MessageOnlineUserLoaded,
      builder: (context, state) {
        if (state is MessageOnlineUserLoading) {
          return const CircularProgressIndicator();
        }
        return SizedBox(
          height: size_130_h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    context.router.push(ChatScreenRoute(
                        userModel: cubit.userList[index], chatID: ""));
                  },
                  child: CustomCircleAvatar(user: cubit.userList[index]));
            },
            itemCount: cubit.userList.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                width: size_20_w,
              );
            },
          ),
        );
      },
    );
  }

  Widget messageList() {
    return BlocConsumer<MessageCubit, MessageState>(
      listener: (context, state) {
        if (state is MessageListLoaded) {
          if (state.message.id != null) {
            int found = -1;
            for (int i = 0; i < cubit.messageList.length; i++) {
              if (cubit.messageList[i].id == state.message.id) {
                found = i;
                break;
              }
            }
            if (found == -1) {
              cubit.messageList.add(state.message);
            } else {
              cubit.messageList.removeAt(found);
              cubit.messageList.insert(0, state.message);
            }
          }
        }
      },
      buildWhen: (prev, cur) => (cur is MessageListLoaded),
      builder: (context, state) {
        if (state is MessageListLoading) {
          return const CircularProgressIndicator();
        }
        return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (_, index) {
              return Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  dragDismissible: false,
                  children: [
                    SlidableAction(
                      backgroundColor: red,
                      foregroundColor: white,
                      icon: Icons.delete,
                      label: 'Delete',
                      onPressed: (BuildContext context) {},
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () {
                    context.router.push(ChatScreenRoute(
                        userModel: cubit.messageList[index].user!,
                        chatID: cubit.messageList[index].id ?? ""));
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: CustomCircleAvatarStatus(
                    user: cubit.messageList[index].user!,
                    radius: size_30_w,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                          flex: 7,
                          child: Text(
                            cubit.messageList[index].user?.fullName ?? "",
                            overflow: TextOverflow.ellipsis,
                            style: title.copyWith(
                                color: black,
                                fontWeight: FontWeight.w500,
                                fontSize: size_18_sp),
                          )),
                      Expanded(
                          flex: 3,
                          child: Text(
                            "08:24 AM",
                            style: subtitle,
                            textAlign: TextAlign.end,
                          ))
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        flex: 9,
                        child: Text(
                          cubit.messageList[index].message?.text ?? "",
                          style: subtitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Expanded(
                      //     flex: 1,
                      //     child: CircleAvatar(
                      //       radius: size_15_h,
                      //       child: Text("2"),
                      //     ))
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, index) {
              return SizedBox(
                height: size_10_h,
              );
            },
            itemCount: cubit.messageList.length);
      },
    );
  }
}
