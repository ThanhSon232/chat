part of 'message_cubit.dart';

@immutable
abstract class MessageState {
  @override
  List<Object> get props => [];
}

class MessageInitial extends MessageState {}

class MessageOnlineUserLoading extends MessageState{}

class MessageOnlineUserLoaded extends MessageState{
  final List<UserModel> userList;

  MessageOnlineUserLoaded({required this.userList});
  @override
  List<Object> get props => [
    userList
  ];
}

class MessageLoading extends MessageState{}

class MessageLoaded extends MessageState {
  // List<UserModel> userList;
  //
  // MessageLoaded({required this.userList});
  // @override
  // List<Object> get props => [
  //   userList
  // ];
}

