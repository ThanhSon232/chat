import 'package:auto_route/auto_route.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/bloc/home/home_cubit.dart';
import 'package:chat/route.gr.dart';
import 'package:chat/theme/style.dart';
import 'package:chat/widgets/custom_circle_avatar_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../bloc/global_cubit.dart';
import '../../notification.dart';
import '../../theme/color.dart';
import '../../theme/dimension.dart';
import '../../widgets/custom_search.dart';

class HomePage extends StatefulWidget implements AutoRouteWrapper {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeCubit(),
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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late GlobalCubit globalCubit;
  late HomeCubit cubit;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    globalCubit = BlocProvider.of<GlobalCubit>(context);
    cubit = BlocProvider.of(context);
    cubit.init(globalCubit.currentUser);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // await cubit.fetchPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = SizedBox(
      height: size_10_h,
    );
    return BlocListener<GlobalCubit, GlobalState>(
      listener: (context, state) {
        if (state is GlobalNewUser) {
          cubit.userModel = state.userModel;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            "assets/logo.png",
            height: 40,
          ),
          elevation: 0,
          backgroundColor: white,
          centerTitle: false,
          actions: [
            IconButton(onPressed: () async{
              context.router.push(SearchPageRoute(from: "home"));
            }, icon: const Icon(Icons.search, color: black,))
          ],
        ),
        resizeToAvoidBottomInset: true,
        backgroundColor: grey_100,
        body: RefreshIndicator(
          onRefresh: () => cubit.refreshPost(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [userActions(), space, posts()],
            ),
          ),
        ),
      ),
    );
  }

  Widget posts() {
    final space = SizedBox(
      height: size_10_h,
    );
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is HomeLoaded) {
          cubit.posts = state.posts;
          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (_, index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                color: white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      onTap: () {
                        context.router.push(ProfilePageRoute(
                            currentUser: cubit.userModel,
                            user: state.posts[index].author!));
                      },
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
                                aspectRatio: state.posts[index].aspectRatio!,
                                child: BetterPlayer(
                                  controller: state
                                      .posts[index].metadata!["controller"],
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
                                  state.posts[index].likes?.length.toString() ??
                                      "0",
                                  style: title,
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: white, elevation: 0),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16.0),
                                            topRight: Radius.circular(16.0)),
                                      ),
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                              void Function(void Function())
                                                  setState) {
                                            return Container(

                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context).viewInsets.bottom),                                              height: MediaQuery.of(context)
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
                                                      child: ListView.builder(
                                                        itemBuilder: (_, i) {
                                                          return ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                              radius: 20,
                                                              backgroundImage:
                                                                  NetworkImage(cubit
                                                                      .userModel
                                                                      .avatarURL),
                                                            ),
                                                            title: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  state
                                                                          .posts[
                                                                              index]
                                                                          .comment?[
                                                                              i]
                                                                          .fullName ??
                                                                      "",
                                                                  style: title.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                ),
                                                                Text(state
                                                                        .posts[
                                                                            index]
                                                                        .comment?[
                                                                            i]
                                                                        .content ??
                                                                    "")
                                                              ],
                                                            ),
                                                            subtitle: Text(state
                                                                    .posts[
                                                                        index]
                                                                    .comment?[i]
                                                                    .createAt!
                                                                    .toDate()
                                                                    .toString() ??
                                                                ""),
                                                          );
                                                        },
                                                        itemCount: state
                                                                .posts[index]
                                                                .comment
                                                                ?.length ??
                                                            0,
                                                      ),
                                                    ),
                                                    const Divider(),
                                                    TextFormField(
                                                      controller: controller,
                                                      decoration:
                                                          InputDecoration(
                                                              hintText:
                                                                  "Comment here",
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              prefixIcon:
                                                                  Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundImage:
                                                                      NetworkImage(cubit
                                                                          .userModel
                                                                          .avatarURL),
                                                                ),
                                                              ),
                                                              suffixIcon:
                                                                  IconButton(
                                                                icon: const Icon(
                                                                    Icons.send),
                                                                onPressed: () {
                                                                  if (controller
                                                                          .text !=
                                                                      "") {
                                                                    setState(
                                                                        () {
                                                                      cubit.commentPost(
                                                                          index,
                                                                          controller
                                                                              .text);
                                                                      controller
                                                                          .clear();
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
                                    backgroundColor: white, elevation: 0),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              context.router.push(LikePageRoute(
                                  list: state.posts[index].likes!,
                                  user: cubit.userModel));
                            },
                            child: AvatarStack(
                              height: 30,
                              avatars: [
                                for (var n = 0;
                                    n < state.posts[index].likes!.length;
                                    n++)
                                  NetworkImage(
                                      state.posts[index].likes![n].avatarURL!),
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
            itemCount: state.posts.length,
            separatorBuilder: (BuildContext context, int index) {
              return space;
            },
          );
        }
        return Container();
      },
    );
  }

  Widget userActions() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: CustomCircleAvatarStatus(
                    user: globalCubit.currentUser,
                    radius: 30,
                    onOff: false,
                  )),
              Expanded(
                flex: 8,
                child: TextFormField(
                  onTap: () async {
                    var value = await context.router
                        .push(NewPostsPageRoute(user: globalCubit.currentUser));
                    value as Map;
                    if (value["result"]) {
                      await cubit.fetchPost();
                    }
                  },
                  readOnly: true,
                  decoration: const InputDecoration(
                      hintText: "How are you today?", border: InputBorder.none),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: customElevatedButton(
                    prefix: SvgPicture.asset(
                      "assets/picture-icon.svg",
                      semanticsLabel: 'A red up arrow',
                      height: size_22_w,
                    ),
                    text: Text(
                      "Pictures",
                      style: subtitle.copyWith(color: black),
                    ),
                    onPressed: () {
                      cubit.sendPicture().then((value) {
                        if (value != null) {
                          context.router
                              .push(NewPostsPageRoute(
                                  user: globalCubit.currentUser,
                                  xFile: value,
                                  type: "image"))
                              .then((value) async {
                            value as Map;
                            if (value["result"]) {
                              await cubit.fetchPost();
                            }
                          });
                        }
                      });
                    }),
              ),
              SizedBox(
                width: size_10_w,
              ),
              Expanded(
                flex: 5,
                child: customElevatedButton(
                    prefix: SvgPicture.asset(
                      "assets/video-icon.svg",
                      semanticsLabel: 'A red up arrow',
                      height: size_22_w,
                    ),
                    text: Text(
                      "Videos",
                      style: subtitle.copyWith(color: black),
                    ),
                    onPressed: () {
                      cubit.sendVideo().then((value) {
                        if (value != null) {
                          context.router
                              .push(NewPostsPageRoute(
                                  user: globalCubit.currentUser,
                                  xFile: value,
                                  type: "video"))
                              .then((value) async {
                            value as Map;
                            if (value["result"]) {
                              await cubit.fetchPost();
                            }
                          });
                        }
                      });
                    }),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget customElevatedButton(
      {required Widget text,
      Widget? prefix,
      Color? backgroundColor,
      required void Function()? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: backgroundColor ?? grey_100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          prefix ?? const SizedBox.shrink(),
          SizedBox(
            width: size_5_w,
          ),
          text
        ],
      ),
    );
  }
}
