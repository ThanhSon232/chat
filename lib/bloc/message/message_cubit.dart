import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../../data/model/user.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  late UserModel currentUser;
  MessageCubit() : super(MessageInitial());

  Future<void> init() async{
    emit(MessageLoading());
    var box = await Hive.openBox("box");
    currentUser = await box.get("user");
    emit(MessageLoaded());
  }
}
