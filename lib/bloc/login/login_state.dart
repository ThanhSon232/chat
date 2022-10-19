part of 'login_cubit.dart';

@immutable
abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginCheckBox extends LoginState {
  final bool check;

  LoginCheckBox({required this.check});

  @override
  List<Object> get props => [check];
}

class LoginObscureText extends LoginState {
  final bool obscureText;

  LoginObscureText({required this.obscureText});

  @override
  List<Object> get props => [obscureText];
}
