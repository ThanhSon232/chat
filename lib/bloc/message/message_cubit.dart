import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../../data/model/user.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  late UserModel currentUser;

  MessageCubit() : super(MessageInitial());
  List<UserModel> userList = [];
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<void> init() async {
    emit(MessageLoading());
    var box = await Hive.openBox("box");
    currentUser = await box.get("user");
    emit(MessageInitial());
    getUserOnlineList().then((value) {
      Timer.periodic(const Duration(seconds: 60), (timer) {
        print(timer.tick);
        getUserOnlineList();
      });
    });
  }

  Future<void> getUserOnlineList() async {
    emit(MessageOnlineUserLoading());
    List<UserModel> tempList = [];
    var snapshot = await firebaseFirestore
        .collection("users")
        .doc(currentUser.id)
        .collection("friends")
        .get();
    for (var element in snapshot.docs) {
      var friend =
          await firebaseFirestore.collection("users").doc(element.id).get();
      if(friend.data()!["is_online"]) {
        tempList.add(UserModel.fromJson(friend.data() ?? {}));
      }
    }
    emit(MessageOnlineUserLoaded(userList: tempList));
  }
}
