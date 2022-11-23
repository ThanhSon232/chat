import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../data/model/user.dart';

part 'global_state.dart';

class GlobalCubit extends Cubit<GlobalState> {
  GlobalCubit() : super(GlobalInitial());

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late UserModel currentUser;
  List<UserModel> onlineList = [];
  List<UserModel> allUserList = [];
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> listener;

  void init() async {
    emit(GlobalLoading());
    var box = await Hive.openBox("box");
    currentUser = await box.get("user");
    getUserOnlineList();
  }

  void getUserOnlineList() {
    Map friends = currentUser.friends ?? {};
    List query = [];
    friends.forEach((key, value) {
        query.add(key);
    });
    query.add(currentUser.id);

    try {
      listener = firebaseFirestore
          .collection("users")
          .where("_id", whereIn: query)
          .snapshots()
          .listen((event) {
        emit(GlobalLoading());
        for (var element in event.docChanges) {
          UserModel userModel = UserModel.fromJson(element.doc.data() ?? {});
          if (element.type == DocumentChangeType.added) {
            allUserList.add(userModel);
          } else if (element.type == DocumentChangeType.modified) {
            var index = allUserList.indexWhere((e) => e.id == userModel.id);
            allUserList[index] = userModel;
            if(userModel.id == currentUser.id){
              currentUser = userModel;
              emit(GlobalNewUser(userModel: userModel));
            }
          } else if (element.type == DocumentChangeType.removed) {
            allUserList.removeWhere((e) => e.id == userModel.id);
            if(userModel.id == currentUser.id){
              currentUser = userModel;
              emit(GlobalNewUser(userModel: userModel));
            }
          }
        }
        emit(GlobalLoaded(allUser: allUserList));
      });

    } catch (e) {
      if (e is FirebaseException) {
        print(e.message);
      } else {
        print(e.toString());
      }
      listener.cancel();
    }
  }

  Future<void> dispose() async{
    onlineList = [];
    allUserList = [];
    await listener.cancel();
  }
}
