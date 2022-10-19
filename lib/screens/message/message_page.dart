import 'package:auto_route/auto_route.dart';
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
  Widget build(BuildContext context) {
    final spacing = SizedBox(
      height: size_20_h,
    );

    return BlocConsumer<MessageCubit, MessageState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
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
              if (state is MessageLoading) const CircularProgressIndicator(),
              if (state is MessageLoaded)
                cubit.currentUser.avatarURL.isEmpty
                    ? CircleAvatar(
                        child: Text(cubit.currentUser.fullName[0]),
                      )
                    : CircleAvatar(
                        backgroundImage:
                            NetworkImage(cubit.currentUser.avatarURL),
                      )
            ],
          ),
          backgroundColor: white,
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: size_15_w, vertical: size_10_h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                searchBar(),
                spacing,
                if (state is MessageLoaded) onlineUserList(),
                if (state is MessageLoaded) messageList()
              ],
            ),
          ),
        );
      },
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
    return SizedBox(
      height: size_130_h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return CustomCircleAvatar(user: cubit.currentUser);
        },
        itemCount: 10,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: size_20_w,
          );
        },
      ),
    );
  }

  Widget messageList() {
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
              contentPadding: EdgeInsets.zero,
              leading: CustomCircleAvatarStatus(
                user: cubit.currentUser,
                radius: size_30_w,
              ),
              title: Row(
                children: [
                  Expanded(
                      flex: 7,
                      child: Text(
                        cubit.currentUser.fullName,
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
                      "what are you doing?",
                      style: subtitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: CircleAvatar(
                        radius: size_15_h,
                        child: Text("2"),
                      ))
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
        itemCount: 10);
  }
}
