import 'package:bloc/bloc.dart';
import 'package:chat/screens/chat/chat_screen.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../data/model/user.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  late types.User user;
  ChatCubit() : super(ChatInitial());

  void init() async{
    emit(ChatLoading());
    var box = await Hive.openBox("box");
    UserModel currentUser = await box.get("user");
    user = types.User(
      id: currentUser.id,
      lastName: currentUser.fullName,
      imageUrl: currentUser.avatarURL,
    );
    emit(ChatInitial());
  }
}
