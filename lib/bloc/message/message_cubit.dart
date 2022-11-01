import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat/data/model/list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../data/model/user.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  late UserModel currentUser;

  MessageCubit() : super(MessageInitial());
  List<UserModel> userList = [];
  List<MessageTile> messageList = [];
  Timer? timer;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? streamSub;

  Future<void> init() async {
    emit(MessageLoading());
    var box = await Hive.openBox("box");
    currentUser = await box.get("user");
    emit(MessageInitial());
    getMessageList();
    getUserOnlineList().then((value) {
      timer = Timer.periodic(const Duration(seconds: 30), (timer) {
        getUserOnlineList();
      });
    });
  }

  Future<void> deleteAllMessage(MessageTile msg) async {
    try {
      var response = await firebaseFirestore
          .collection("chat")
          .doc(msg.id).collection("users").doc(currentUser.id).delete()
          .timeout(const Duration(seconds: 30));
      messageList.remove(msg);

    } catch (e) {
      if (e is FirebaseException) {
        print(e.message);
      }
    }
  }

  Future<void> getMessageList() async {
    try {
      // var data = await firebaseFirestore
      //     .collection("chat").orderBy("createAt").where('users.${currentUser.id}', isNull: true).get();
      // for (var element in data.docChanges) {
      //   print(element.doc.data());
      // }

      streamSub = firebaseFirestore
          .collection("chat")
          .where('users.${currentUser.id}', isNull: true)
          .snapshots()
          .listen((event) async {
        for (var element in event.docChanges) {
          if (element.type == DocumentChangeType.removed) {
            emit(MessageListDelete(message: element.doc.id));
          } else if (element.type == DocumentChangeType.added ||
              element.type == DocumentChangeType.modified) {
            print(element.doc.data());
            if (element.doc.data()?["last_message"] != null) {
              var message = element.doc.data()?["last_message"];
              Map receiver = element.doc.data()?["users"];
              receiver.remove(currentUser.id);
              UserModel? parsedUser = userList.firstWhere(
                  (element) => element.id == receiver.keys.first,
                  orElse: () => UserModel());

              if (parsedUser.id.isEmpty) {
                var author = await firebaseFirestore
                    .collection("users")
                    .doc(receiver.keys.first)
                    .get();

                parsedUser = UserModel.fromJson(author.data() ?? {});
                for (int i = 0; i < userList.length; i++) {
                  if (userList[i] == author.data()?["id"]) {
                    userList[i] = parsedUser;
                    emit(MessageOnlineUserLoaded(userList: userList));
                  }
                }
              }

              MessageTile messageTile = MessageTile(
                  id: element.doc.id,
                  user: parsedUser,
                  message: types.TextMessage(
                      id: message["messageID"],
                      author: types.User(
                          id: message["sender"]["id"],
                          lastName: message["sender"]["lastName"],
                          imageUrl: message["imageURL"]),
                      text: message["msg"]));

              emit(MessageListLoaded(message: messageTile));
            }
          }
        }
      });
    } catch (e) {
      if (e is FirebaseException) {
        streamSub?.cancel();
        emit(MessageError(error: e.message.toString()));
      }
    }
  }

  Future<void> getUserOnlineList() async {
    emit(MessageOnlineUserLoading());
    List<UserModel> tempList = [];
    try {
      var snapshot = await firebaseFirestore
          .collection("users")
          .doc(currentUser.id)
          .collection("friends")
          .limit(20)
          .get()
          .timeout(const Duration(seconds: 30));

      for (var element in snapshot.docs) {
        var friend =
            await firebaseFirestore.collection("users").doc(element.id).get();
        if (friend.data()!["_is_online"]) {
          tempList.add(UserModel.fromJson(friend.data() ?? {}));
        }
        MessageTile? us = messageList.firstWhere(
            (e) => element.id == e.user!.id,
            orElse: () => MessageTile());
        if (us.id != null) {
          us.user?.isOnline = friend.data()!["_is_online"];
          emit(MessageListLoaded(message: us));
        }
      }
    } catch (e) {
      if (e is FirebaseException) {
        timer?.cancel();
        emit(MessageError(error: e.message.toString()));
      } else {
        print(e.toString());
      }
    }
    emit(MessageOnlineUserLoaded(userList: tempList));
  }
}
