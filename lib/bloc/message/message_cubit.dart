import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat/data/model/list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';

import '../../data/model/user.dart';
import '../../notification.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  late UserModel currentUser;

  List<UserModel> userList = [];
  List<MessageTile> messageList = [];
  Timer? timer;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? streamSub;

  MessageCubit() : super(MessageInitial());

  void init() async{
    emit(MessageLoading());
    var box = await Hive.openBox("box");
    currentUser = await box.get("user");
    emit(MessageInitial());
  }

  Future<void> deleteAllMessage(MessageTile msg) async {
    try {
      await firebaseFirestore
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

  Future<void> getMessageList(List<UserModel> userList) async {
    List<MessageTile> msgList = [];

    try{
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
            orElse: (){
              var userInfo = data["infor"][guest.keys.first];
              return UserModel(
                userInfo["id"],
                userInfo["fullName"],
                userInfo["avatarURL"]
              );
            });

        MessageTile messageTile = MessageTile(
            id: element.id,
            user: parsedUser,
            message: types.TextMessage(
                id: message["messageID"],
                status: message["sender"]["id"] == currentUser.id ? types.Status.sent : (data["seen"] ? types.Status.seen : types.Status.delivered),
                author: types.User(
                    id: message["sender"]["id"],
                    lastName: message["sender"]["lastName"],
                    imageUrl: message["sender"]["imageUrl"]),
                text: message["msg"]),
            date: DateFormat('kk:mm dd-MM-yyyy')
                .format(DateTime.parse(data["createAt"].toDate().toString())));

        print(messageTile.message?.status);
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
            }
            else if (element.type == DocumentChangeType.modified &&
                !element.doc.metadata.hasPendingWrites) {
              var data = element.doc.data() ?? {};
              if (data.containsKey("last_message")) {
                var message = data["last_message"];
                var listUser = data["users"] as List;
                Map guest = listUser.first.containsKey(currentUser.id)
                    ? listUser.last
                    : listUser.first;
                UserModel parsedUser = userList.firstWhere(
                        (element) => element.id == guest.keys.first,
                    orElse: (){
                      var userInfo = data["infor"][guest.keys.first];
                      return UserModel(
                          userInfo["id"],
                          userInfo["fullName"],
                          userInfo["avatarURL"]
                      );
                    });

                MessageTile messageTile = MessageTile(
                    id: element.doc.id,
                    user: parsedUser,
                    date: DateFormat('kk:mm dd-MM-yyyy').format(
                        DateTime.parse(data["createAt"].toDate().toString())),
                    message: types.TextMessage(
                        id: message["messageID"],
                        status: message["sender"]["id"] == currentUser.id ? types.Status.sent : (data["seen"] ? types.Status.seen : types.Status.delivered),
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
                NotificationService().showNotification(0, messageTile.user!.fullName, messageTile.message!.text, 10);

              }
            }
          }
          emit(MessageListLoaded(message: messageList));
    });
    } catch (e) {
      if (e is FirebaseException) {
        streamSub?.cancel();
        emit(MessageError(error: e.message.toString()));
      } else {
        print(e.toString());
      }
    }
  }

}
