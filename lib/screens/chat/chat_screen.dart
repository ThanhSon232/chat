import 'package:auto_route/auto_route.dart';
import 'package:chat/bloc/chat/chat_cubit.dart';
import 'package:chat/data/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;

import '../../theme/color.dart';
import '../../theme/style.dart';

class ChatScreen extends StatefulWidget implements AutoRouteWrapper {
  final UserModel userModel;

  const ChatScreen({Key? key, required this.userModel}) : super(key: key);

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
    cubit.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color:  black,),
          onPressed: (){
            context.router.pop();
          },
        ),
        title: Text(widget.userModel.fullName, style: header,),
      ),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if(state is ChatLoading) return CircularProgressIndicator();
            return chat_ui.Chat(
              messages: [],
              onSendPressed: (PartialText) {},
              user: cubit.user,

            );
          },
        )
    );
  }
}
