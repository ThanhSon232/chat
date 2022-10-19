import 'package:auto_route/auto_route.dart';
import 'package:chat/bloc/message/message_cubit.dart';
import 'package:chat/theme/color.dart';
import 'package:chat/theme/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocConsumer<MessageCubit, MessageState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: white,
            title: Text(
              "Messages", style: header.copyWith(fontWeight: FontWeight.w500),),
            centerTitle: false,
            elevation: 0,
            actions: [
              if(state is MessageLoading)
                const CircularProgressIndicator(),
              if(state is MessageLoaded)
              cubit.currentUser.avatarURL!.isEmpty ? CircleAvatar(
                child: Text(cubit.currentUser.fullName?[0] ?? ""),
              ) : IconButton(onPressed: () {},
                  icon: Image.network(cubit.currentUser.avatarURL!))
            ],
          ),
        );
      },
    );
  }
}
