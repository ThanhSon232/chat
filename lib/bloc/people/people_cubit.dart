import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../../data/model/user.dart';

part 'people_state.dart';

class PeopleCubit extends Cubit<PeopleState> {
  PeopleCubit() : super(PeopleInitial());
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Timer? timer;
  late UserModel currentUser;

  void init() async{
    var box = await Hive.openBox("box");
    currentUser = await box.get("user");
    await getUserOnlineList().then((value){
      timer = Timer.periodic(const Duration(seconds: 30), (timer) async{
        await getUserOnlineList();
      });
    });
  }

  Future<void> getUserOnlineList() async {
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
      }

    } catch (e) {
      if (e is FirebaseException) {
        timer?.cancel();
        // emit(MessageError(error: e.message.toString()));
      } else {
        print(e.toString());
      }
    }
    emit(PeopleLoaded(userModelList: tempList));
  }
}
