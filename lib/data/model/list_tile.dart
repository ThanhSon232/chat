import 'package:chat/data/model/user.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MessageTile {
  String? id;
  UserModel? user;
  String? date;
  types.TextMessage? message;

  MessageTile({this.id, this.user, this.message, this.date});

  MessageTile copyWith({String? id, UserModel? user, types.TextMessage? message}) => MessageTile(
    id: id ?? this.id,
    user: user ?? this.user,
    message: message ?? this.message,
  );


}