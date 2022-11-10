part of 'global_cubit.dart';

@immutable
abstract class GlobalState extends Equatable{
  @override
  List<Object> get props => [];
}

class GlobalInitial extends GlobalState {}

class GlobalLoading extends GlobalState{}

class GlobalLoaded extends GlobalState{
  final List<UserModel> allUser;

  GlobalLoaded({required this.allUser});

  @override
  List<Object> get props => [
    allUser
  ];
}
