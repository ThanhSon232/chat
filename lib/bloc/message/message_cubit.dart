import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat/data/model/list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';

import '../../data/model/user.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  late UserModel currentUser;

  List<UserModel> userList = [];
  List<MessageTile> messageList = [];
  Timer? timer;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? streamSub;

  MessageCubit() : super(MessageInitial());

  Future<void> init() async {
    emit(MessageLoading());
    var box = await Hive.openBox("box");
    currentUser = await box.get("user");
    emit(MessageInitial());
    getUserOnlineList().then((value) {
      getMessageList();
      timer = Timer.periodic(const Duration(seconds: 30), (timer) {
        getUserOnlineList();
      });
    });
  }

  Future<void> deleteAllMessage(MessageTile msg) async {
    try {
      var response = await firebaseFirestore
          .collection("chat")
          .doc(msg.id)
          .collection("users")
          .doc(currentUser.id)
          .delete()
          .timeout(const Duration(seconds: 30));
      messageList.remove(msg);
    } catch (e) {
      if (e is FirebaseException) {
        print(e.message);
      }
    }
  }

  Future<void> getMessageList() async {
    List<MessageTile> msgList = [];

    var data = await firebaseFirestore
        .collection("chat")
        .where('users', arrayContainsAny: [
          {currentUser.id: null}
        ])
        .orderBy("createAt", descending: true)
        .limit(10)
        .get();
    for (var element in data.docs) {
      if (element.data().containsKey("last_message")) {
        var data = element.data();
        var message = data["last_message"];
        var listUser = data["users"] as List;
        Map guest = listUser.first.containsKey(currentUser.id)
            ? listUser.last
            : listUser.first;

        UserModel parsedUser = userList.firstWhere(
            (element) => element.id == guest.keys.first,
            orElse: () => UserModel());

        if (parsedUser.id.isEmpty) {
          var author = await firebaseFirestore
              .collection("users")
              .doc(guest.keys.first)
              .get();

          parsedUser = UserModel.fromJson(author.data() ?? {});
          for (int i = 0; i < userList.length; i++) {
            if (userList[i] == author.data()?["id"]) {
              userList[i] = parsedUser;
              emit(MessageOnlineUserLoaded(userList: userList));
            }
          }
        }

        // print(DateFormat('dd-MM-yyyy – kk:mm')
        //     .format(DateTime.parse(data["createAt"].toDate().toString())));
        //
        // print(DateTime.now().month);

        MessageTile messageTile = MessageTile(
            id: element.id,
            user: parsedUser,
            message: types.TextMessage(
                id: message["messageID"],
                author: types.User(
                    id: message["sender"]["id"],
                    lastName: message["sender"]["lastName"],
                    imageUrl: message["sender"]["imageUrl"]),
                text: message["msg"]),
            date: DateFormat('kk:mm dd-MM-yyyy')
                .format(DateTime.parse(data["createAt"].toDate().toString())));

        msgList.add(messageTile);
      }
    }
    emit(MessageListLoaded(message: msgList));

    streamSub = firebaseFirestore
        .collection("chat")
        .where('users', arrayContainsAny: [
          {currentUser.id: null}
        ])
        .orderBy("createAt", descending: true)
        .snapshots()
        .listen((event) async {
          for (var element in event.docChanges) {
            if (element.type == DocumentChangeType.removed) {
              emit(MessageListDelete(message: element.doc.id));
            } else if (element.type == DocumentChangeType.modified &&
                !element.doc.metadata.hasPendingWrites) {
              var data = element.doc.data() ?? {};
              if (data.containsKey("last_message")) {
                var message = data["last_message"];
                var listUser = data["users"] as List;
                Map guest = listUser.first.containsKey(currentUser.id)
                    ? listUser.last
                    : listUser.first;

                print(guest);

                UserModel parsedUser = userList.firstWhere(
                    (element) => element.id == guest.keys.first,
                    orElse: () => UserModel());

                if (parsedUser.id.isEmpty) {
                  var author = await firebaseFirestore
                      .collection("users")
                      .doc(guest.keys.first)
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
                    date: DateFormat('kk:mm dd-MM-yyyy').format(
                        DateTime.parse(data["createAt"].toDate().toString())),
                    message: types.TextMessage(
                        id: message["messageID"],
                        author: types.User(
                            id: message["sender"]["id"],
                            lastName: message["sender"]["lastName"],
                            imageUrl: message["sender"]["imageUrl"]),
                        text: message["msg"]));

                MessageTile existed = messageList.firstWhere(
                    (element) => element.id == messageTile.id,
                    orElse: () => MessageTile());
                if (existed.id != null) {
                  messageList.remove(existed);
                  messageList.insert(0, messageTile);
                } else {
                  messageList.insert(0, messageTile);
                }
              }
            }
          }
          emit(MessageListLoaded(message: messageList));
        });
    // } catch (e) {
    //   if (e is FirebaseException) {
    //     streamSub?.cancel();
    //     emit(MessageError(error: e.message.toString()));
    //   } else {
    //     print(e.toString());
    //   }
    // }
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

        // print( messageList.indexWhere((e) => e.user?.id == element.id));

        // MessageTile? us = messageList.firstWhere(
        //     (e) => element.id == e.user!.id,
        //     orElse: () => MessageTile());
        // if (us.id != null) {
        //   us.user?.isOnline = friend.data()!["_is_online"];
        //
        //   // emit(MessageListLoaded(message: us));
        // }
      }
    } catch (e) {
      if (e is FirebaseException) {
        timer?.cancel();
        emit(MessageError(error: e.message.toString()));
      } else {
        print(e.toString());
      }
    }
    userList = tempList;
    emit(MessageOnlineUserLoaded(userList: tempList));
  }
}
