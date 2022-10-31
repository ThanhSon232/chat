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

class MessageListLoading extends MessageState{}

class MessageError extends MessageState{
  final String error;

  MessageError({required this.error});
  @override
  List<Object> get props => [
    error
  ];
}

class MessageListLoaded extends MessageState {
  final MessageTile message;

  MessageListLoaded({required this.message});
  @override
  List<Object> get props => [
    message
  ];
}

class MessageListDelete extends MessageState{
  final String message;

  MessageListDelete({required this.message});

  @override
  List<Object> get props => [
    message
  ];
}

