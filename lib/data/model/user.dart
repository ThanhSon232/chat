import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject{
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? fullName;
  @HiveField(2)
  String? avatarURL;
  @HiveField(3)
  String? email;
  @HiveField(4)
  bool? isOnline;

  UserModel(
      {this.id, this.fullName, this.avatarURL, this.email, this.isOnline});

  UserModel.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    avatarURL = json['avatarURL'];
    email = json['email'];
    isOnline = json['is_online'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fullName'] = this.fullName;
    data['avatarURL'] = this.avatarURL;
    data['email'] = this.email;
    data['is_online'] = this.isOnline;
    return data;
  }
}