import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject{
  @HiveField(0)
  String? _id;
  @HiveField(1)
  String? _fullName;
  @HiveField(2)
  String? _avatarURL;
  @HiveField(3)
  String? _email;
  @HiveField(4)
  bool? _isOnline;

  UserModel(
      [this._id, this._fullName, this._avatarURL, this._email, this._isOnline]);

  UserModel.fromJson(Map<dynamic, dynamic> json) {
    _id = json['id'];
    _fullName = json['fullName'];
    _avatarURL = json['avatarURL'];
    _email = json['email'];
    _isOnline = json['is_online'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._id;
    data['_fullName'] = this._fullName;
    data['_avatarURL'] = this._avatarURL;
    data['_email'] = this._email;
    data['_is_online'] = this._isOnline;
    return data;
  }


  bool get isOnline => _isOnline ?? false;

  String get email => _email ?? "";

  String get avatarURL => _avatarURL ?? "";

  String get fullName => _fullName ?? "Anonymus";

  String get id => _id ?? "";
}