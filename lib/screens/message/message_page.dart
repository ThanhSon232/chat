import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/bloc/message/message_cubit.dart';
import 'package:chat/theme/color.dart';
import 'package:chat/theme/dimension.dart';
import 'package:chat/theme/style.dart';
import 'package:chat/widgets/custom_circle_avatar.dart';
import 'package:chat/widgets/custom_circle_avatar_status.dart';
import 'package:chat/widgets/custom_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skeletons/skeletons.dart';

import '../../bloc/global_cubit.dart';
import '../../route.gr.dart';

class MessagePage extends StatefulWidget implements AutoRouteWrapper {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MessageCubit(),
          child: this, // this as the child Important!
        ),
        BlocProvider.value(
          value: BlocProvider.of<GlobalCubit>(context),
          child: this,
        )
      ],
      child: this,
    );
  }
}

class _MessagePageState extends State<MessagePage> {
  late MessageCubit cubit;
  late GlobalCubit globalCubit;

  @override
  void initState() {
    globalCubit = BlocProvider.of<GlobalCubit>(context);
    cubit = BlocProvider.of(context);
    cubit.init();
    super.initState();
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
              return GestureDetector(
                onTap: () {
                  context.router.pushNamed("/setting-page");
                },
                child: CachedNetworkImage(
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
                ),
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
    return CustomSearch(
      onTap: () {
        context.router.pushNamed("/search-page");
      },
      readOnly: true,
    );
  }

  Widget onlineUserList() {
    return BlocBuilder<GlobalCubit, GlobalState>(
      buildWhen: (prev, cur) => cur is GlobalLoaded,
      builder: (context, state) {
        if (state is GlobalLoaded) {
          var onlineList = state.allUser;
          return SizedBox(
            height: size_130_h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if(!onlineList[index].isOnline) return const SizedBox.shrink();
                return GestureDetector(
                    onTap: () {
                      context.router.push(ChatScreenRoute(
                          userModel: onlineList[index], chatID: ""));
                    },
                    child: CustomCircleAvatar(user: onlineList[index]));
              },
              itemCount: onlineList.length > 30 ? 30 : onlineList.length,
              separatorBuilder: (BuildContext context, int index) {
                if(!onlineList[index].isOnline) return const SizedBox.shrink();
                return SizedBox(
                  width: size_20_w,
                );
              },
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget messageList() {
    return BlocConsumer<GlobalCubit, GlobalState>(
      listener: (context, state) async {
        if(state is GlobalLoaded){
          await cubit.getMessageList(state.allUser);
        }
      },
      builder: (context, state) {
        return BlocConsumer<MessageCubit, MessageState>(
          listener: (context, state) {
            if (state is MessageListLoaded) {
              cubit.messageList = state.message;
            } else if (state is MessageListDelete) {
              for (var element in cubit.messageList) {
                if (element.id == state.message) {
                  cubit.messageList.remove(element);
                  break;
                }
              }
            }
          },
          builder: (context, state) {
            if (state is MessageListLoading || state is GlobalLoaded) {
              return const CircularProgressIndicator();
            } else if (state is MessageListLoaded) {
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
                            onPressed: (BuildContext context) async {
                              await cubit
                                  .deleteAllMessage(cubit.messageList[index]);
                            },
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
                                  cubit.messageList[index].date ?? "",
                                  style: subtitle.copyWith(fontSize: 12),
                                  textAlign: TextAlign.end,
                                ))
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              flex: 9,
                              child: Text(
                                "${cubit.messageList[index].message?.text ?? ""}",
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
            }
            return Container();
          },
        );
      },
    );
  }
}
