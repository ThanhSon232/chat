import 'package:auto_route/auto_route.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/bloc/profile/profile_cubit.dart';
import 'package:chat/data/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../route.gr.dart';
import '../../theme/color.dart';
import '../../theme/dimension.dart';
import '../../theme/style.dart';
import '../../widgets/custom_circle_avatar_status.dart';

class ProfilePage extends StatefulWidget implements AutoRouteWrapper {
  final UserModel currentUser;
  final UserModel user;

  const ProfilePage({Key? key, required this.currentUser, required this.user})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: this, // this as the child Important!
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileCubit cubit;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    cubit = BlocProvider.of(context);
    cubit.init(widget.user, widget.currentUser);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final space = SizedBox(
      height: size_10_h,
    );

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
          title: Text(
            "",
            style: header,
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(children: [
              GestureDetector(
                onTap: () async {},
                child: CustomCircleAvatarStatus(
                  radius: 50,
                  onOff: false,
                  user: widget.user,
                ),
              ),
              SizedBox(
                height: size_5_h,
              ),
              Text(
                widget.user.fullName,
                style: header,
              ),
              BlocBuilder<ProfileCubit, ProfileState>(
                buildWhen: (prev,cur) => prev!=cur && cur is ProfileInitial,
                builder: (context, state) {
                  return Visibility(
                    visible: (widget.currentUser.id != widget.user.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if(!cubit.isSend){
                                  await cubit.addFriend(context);
                                  setState(() {
                                    cubit.isSend = !cubit.isSend;
                                  });
                                } else {
                                  await cubit.removeFriend(context);
                                  setState(() {
                                    cubit.isSend = !cubit.isSend;
                                  });
                                }

                              },
                              label: !cubit.isSend
                                  ? const Text("Follow")
                                  : const Text("Unfollow"),
                              icon: cubit.isSend
                                  ? const Icon(Icons.remove)
                                  : const Icon(Icons.add),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 4,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.router.popAndPush(ChatScreenRoute(
                                    userModel: widget.user, chatID: ""));
                              },
                              label: const Text("Chat"),
                              icon: const Icon(Icons.message),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            ]),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is ProfileLoaded) {
                  cubit.posts = state.posts;
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      if (index == state.posts.length) {
                        return const Center(
                          child: Text("End"),
                        );
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        color: white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: CustomCircleAvatarStatus(
                                user: state.posts[index].author!,
                                radius: 30,
                              ),
                              title: Text(
                                state.posts[index].author!.fullName,
                                style: title.copyWith(color: black),
                              ),
                              subtitle: Text(
                                state.posts[index].convertedCreateAt!,
                                style: subtitle,
                              ),
                              trailing: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.more_horiz,
                                  color: black,
                                ),
                              ),
                            ),
                            space,
                            Text(
                              state.posts[index].caption!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                              style: title,
                            ),
                            space,
                            state.posts[index].type == "text"
                                ? Container()
                                : (state.posts[index].type == "image"
                                ? CachedNetworkImage(
                              imageUrl: state.posts[index].uri ?? "",
                              placeholder: (context, str) {
                                return AspectRatio(
                                  aspectRatio:
                                  state.posts[index].aspectRatio!,
                                  child: Container(
                                    color: grey,
                                  ),
                                );
                              },
                            )
                                : AspectRatio(
                              aspectRatio:
                              state.posts[index].aspectRatio!,
                              child: BetterPlayer(
                                controller: state.posts[index]
                                    .metadata!["controller"],
                              ),
                            )),
                            Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          cubit.likedPost(index);
                                        },
                                        icon: state.posts[index].likedByMe!
                                            ? const Icon(
                                          Icons.favorite_outlined,
                                          color: red,
                                        )
                                            : const Icon(
                                          Icons.favorite_border,
                                          color: black,
                                        ),
                                        label: Text(
                                          state.posts[index].likes?.length
                                              .toString() ??
                                              "0",
                                          style: title,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: white,
                                            elevation: 0),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape:
                                              const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                    Radius.circular(16.0),
                                                    topRight:
                                                    Radius.circular(16.0)),
                                              ),
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (BuildContext
                                                  context,
                                                      void Function(
                                                          void Function())
                                                      setState) {
                                                    return Container(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          10),
                                                      height:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                          0.7,
                                                      child: SafeArea(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              "Comments",
                                                              style: header,
                                                            ),
                                                            const Divider(),
                                                            Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                itemBuilder:
                                                                    (_, i) {
                                                                  return ListTile(
                                                                    leading:
                                                                    CircleAvatar(
                                                                      radius:
                                                                      20,
                                                                      backgroundImage: NetworkImage(cubit
                                                                          .currentUser
                                                                          .avatarURL),
                                                                    ),
                                                                    title:
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        Text(
                                                                          state.posts[index].comment?[i].fullName ??
                                                                              "",
                                                                          style:
                                                                          title.copyWith(fontWeight: FontWeight.w700),
                                                                        ),
                                                                        Text(state.posts[index].comment?[i].content ??
                                                                            "")
                                                                      ],
                                                                    ),
                                                                    subtitle: Text(state
                                                                        .posts[index]
                                                                        .comment?[i]
                                                                        .createAt!
                                                                        .toDate()
                                                                        .toString() ??
                                                                        ""),
                                                                  );
                                                                },
                                                                itemCount: state
                                                                    .posts[
                                                                index]
                                                                    .comment
                                                                    ?.length ??
                                                                    0,
                                                              ),
                                                            ),
                                                            const Divider(),
                                                            TextFormField(
                                                              controller:
                                                              controller,
                                                              decoration:
                                                              InputDecoration(
                                                                  hintText:
                                                                  "Comment here",
                                                                  border: InputBorder
                                                                      .none,
                                                                  prefixIcon:
                                                                  Padding(
                                                                    padding:
                                                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                                                    child:
                                                                    CircleAvatar(
                                                                      backgroundImage: NetworkImage(cubit
                                                                          .currentUser
                                                                          .avatarURL),
                                                                    ),
                                                                  ),
                                                                  suffixIcon:
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons.send),
                                                                    onPressed:
                                                                        () {
                                                                      if (controller.text !=
                                                                          "") {
                                                                        setState(() {
                                                                          cubit.commentPost(index, controller.text);
                                                                          controller.clear();
                                                                        });
                                                                      }
                                                                    },
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              });
                                        },
                                        icon: const Icon(
                                          Icons.message_outlined,
                                          color: black,
                                        ),
                                        label: Text(
                                          state.posts[index].comment?.length
                                              .toString() ??
                                              "0",
                                          style: title,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: white,
                                            elevation: 0),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      context.router.push(LikePageRoute(
                                          list: state.posts[index].likes!,
                                          user: cubit.currentUser));
                                    },
                                    child: AvatarStack(
                                      height: 30,
                                      avatars: [
                                        for (var n = 0;
                                        n <
                                            state
                                                .posts[index].likes!.length;
                                        n++)
                                          NetworkImage(state.posts[index]
                                              .likes![n].avatarURL!),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                    itemCount: state.posts.length + 1,
                    separatorBuilder: (BuildContext context, int index) {
                      return space;
                    },
                  );
                }
                return Container();
              },
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //
      //   },
      //   child: const Center(
      //     child: Icon(Icons.add),
      //   ),
      // ),
    );
  }
}
