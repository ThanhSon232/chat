import 'package:auto_route/auto_route.dart';
import 'package:bloc/bloc.dart';
import 'package:chat/data/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  bool check = false;
  bool obscureText = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final firebaseInstance = FirebaseAuth.instance;
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  LoginCubit() : super(LoginInitial());

  void onClickCheckbox(bool val) {
    emit(LoginCheckBox(check: val));
  }

  void onClickObscureText() {
    emit(LoginObscureText(obscureText: !obscureText));
  }

  String? emailValidator(String val) {
    if (val.isEmpty) {
      return "Email field must be filled";
    } else if (!isEmail(val)) {
      return "That's not an email. Try another one";
    }
    return null;
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  String? passwordValidator(String val) {
    if (val.isEmpty) {
      return "Password field must be filled";
    } else if (val.length <= 8) {
      return "Password length must be greater than 8 digits";
    }
    return null;
  }

  void validateAndSave(BuildContext context) async {
    final FormState? form = formKey.currentState;
    if (form!.validate()) {
      try {
        EasyLoading.show();
        var user = await firebaseInstance.signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        await firestoreInstance
            .collection("users")
            .doc(user.user?.uid)
            .update({'_is_online': true});

        var response =  await firestoreInstance
            .collection("users")
            .doc(user.user?.uid).get();


        var box = await Hive.openBox("box");
        await box.put("user", UserModel.fromJson(response.data() ?? {}));

        Fluttertoast.showToast(msg: "Login successfully").then((value){
          context.router.replaceNamed("/");
        });
        EasyLoading.dismiss();
      } catch (error) {
        if (error is FirebaseAuthException) {
          Fluttertoast.showToast(msg: error.message.toString());
        } else if (error is FirebaseException) {
          Fluttertoast.showToast(msg: error.message.toString());
        } else {
          print(error.toString());
        }
        EasyLoading.dismiss();
      }
    } else {
      print('Form is invalid');
    }
  }
}
