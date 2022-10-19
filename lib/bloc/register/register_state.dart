part of 'register_cubit.dart';

@immutable
abstract class RegisterState extends Equatable{
  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {

}

class RegisterObscurePassword extends RegisterState {
  final bool obscureText;

  RegisterObscurePassword({required this.obscureText});

  @override
  List<Object> get props => [
    obscureText
  ];
}

class RegisterObscureConfirmPassword extends RegisterState {
  final bool obscureText;

  RegisterObscureConfirmPassword({required this.obscureText});

  @override
  List<Object> get props => [
    obscureText
  ];
}

class RegisterLoaded extends RegisterState {

}

