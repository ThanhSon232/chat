import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  bool check = false;
  bool obscureText = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginCubit() : super(LoginInitial());

  void onClickCheckbox(bool val){
    emit(LoginCheckBox(check: val));
  }

  void onClickObscureText(){
    emit(LoginObscureText(obscureText: !obscureText));
  }

  String? emailValidator(String val){
    if(val.isEmpty){
      return "Email field must be filled";
    } else if(!isEmail(val)){
      return "That's not an email. Try another one";
    }
    return null;
  }


  bool isEmail(String em) {

    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  String? passwordValidator(String val){
    if(val.isEmpty){
      return "Password field must be filled";
    } else if(val.length <= 8){
      return "Password length must be greater than 8 digits";
    }
    return null;
  }

  void validateAndSave() {
    final FormState? form = formKey.currentState;
    if (form!.validate()) {
      print('Form is valid');
    } else {
      print('Form is invalid');
    }
  }
}
