import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../../data/model/user.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  List<UserModel> userList = [];
  List<UserModel> result = [];
  TextEditingController textEditingController = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  UserModel? currentUser;
  Timer? debounce;
  int debounceTime = 300;

  SearchCubit() : super(SearchInitial());

  void init() async {
    try {
      emit(SearchLoading());
      textEditingController.addListener(onSearchChanged);

      var box = await Hive.openBox("box");
      currentUser = box.get("user");
      List<UserModel> suggestionList = [];
      var data = await firebaseFirestore
          .collection("users")
          .doc(currentUser!.id)
          .collection("friends")
          .limit(50)
          .get();
      for (var element in data.docs) {
        var userInfo =
            await firebaseFirestore.collection("users").doc(element.id).get();
        suggestionList.add(UserModel.fromJson(userInfo.data() ?? {}));
      }
      emit(SearchSuggestion(userList: suggestionList));
    } catch (e) {
      if (e is FirebaseException) {
        print(e.message);
      }
    }
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(p);

    return regExp.hasMatch(em);
  }

  void search(String query) async {
    try {
      emit(SearchLoading());
      List<UserModel> result = [];
      bool email = isEmail(query);
      for (var element in userList) {
        if (email) {
          if (element.email.contains(query)) {
            result.add(element);
          }
        } else {
          if (element.fullName.contains(query)) {
            result.add(element);
          }
        }
      }

      if (result.isEmpty) {
        var data = await firebaseFirestore
            .collection("users")
            .orderBy(email ? "_email" : "_lower_case")
            .startAt([query]).endAt(['$query\uf8ff']).get();
        for (var element in data.docs) {
          result.add(UserModel.fromJson(element.data()));
        }
      }

      emit(SearchLoaded(userList: result));
    } catch (e) {
      if (e is FirebaseException) {
        print(e.message);
      }
    }
  }

  onSearchChanged() {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(Duration(milliseconds: debounceTime), () {
      if (textEditingController.text != "") {
        search(textEditingController.text);
      } else {
        emit(SearchSuggestion(userList: userList));
      }
    });
  }
}
