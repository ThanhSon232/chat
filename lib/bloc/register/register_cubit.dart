import 'package:auto_route/auto_route.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meta/meta.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final firebaseInstance = FirebaseAuth.instance;
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void onClickObscurePassword() {
    emit(RegisterObscurePassword(obscureText: !obscurePassword));
  }

  void onClickObscureConfirmPassword() {
    emit(RegisterObscureConfirmPassword(obscureText: !obscureConfirmPassword));
  }

  String? nameValidator(String val) {
    if (val.isEmpty) {
      return "Name field can't be null";
    }
    return null;
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(p);

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

  String? emailValidator(String val) {
    if (val.isEmpty) {
      return "Email field must be filled";
    } else if (!isEmail(val)) {
      return "That's not an email. Try another one";
    }
    return null;
  }

  String? confirmPasswordValidator(String val) {
    if (val.isEmpty) {
      return "Password field must be filled";
    } else if (val != passwordController.text) {
      return "Confirm password doesn't match";
    }
    return null;
  }

  void validateAndSave(BuildContext context) {
    final FormState? form = formKey.currentState;
    if (form!.validate()) {
      // print('Form is valid');
      EasyLoading.show();
      //register an account then create information in firestore
      firebaseInstance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((value) {
        //if create successfully
        firestoreInstance.collection("users").doc(value.user?.uid).set({
          "_id": value.user?.uid,
          "_fullName": nameController.text,
          "_lower_case": nameController.text.toLowerCase(),
          "_avatarURL":
              "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/640px-Image_created_with_a_mobile_phone.png",
          "_email": emailController.text,
          "_is_online": false,
          "friends": {
            "rK1BByZLgWaYgIa1OgQZhPK48ak1": {
              "_fullName": "Test",
              "_id": "rK1BByZLgWaYgIa1OgQZhPK48ak1",
              "_avatarURL":
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/640px-Image_created_with_a_mobile_phone.png"
            }
          }
        }).then((value) {
          context.router.pop();
          Fluttertoast.showToast(msg: "Success bro! You're good");
          EasyLoading.dismiss();
        }).timeout(const Duration(seconds: 30), onTimeout: () {
          Fluttertoast.showToast(
              msg: "Timeout, check your connection or try later");
          EasyLoading.dismiss();
        }).onError((FirebaseException error, stackTrace) {
          firebaseInstance.currentUser?.delete().then((value) {
            Fluttertoast.showToast(msg: error.message.toString());
            EasyLoading.dismiss();
          });
        });
      }).onError((FirebaseAuthException error, stackTrace) {
        Fluttertoast.showToast(msg: error.message.toString());
        EasyLoading.dismiss();
      }).timeout(const Duration(seconds: 30), onTimeout: () {
        Fluttertoast.showToast(
            msg: "Timeout, check your connection or try later");
        EasyLoading.dismiss();
      });
    } else {
      print('Form is invalid');
    }
  }
}
