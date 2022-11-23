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
  @HiveField(5)
  Map? friends;
  @HiveField(6)
  Map? request;

  UserModel(
      [this._id, this._fullName, this._avatarURL, this._email, this._isOnline, this.friends, this.request]);

  UserModel.fromJson(Map<dynamic, dynamic> json) {
    _id = json['_id'];
    _fullName = json['_fullName'];
    _avatarURL = json['_avatarURL'];
    _email = json['_email'];
    _isOnline = json['_is_online'];
    friends = json['friends'];
    request = json['request'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = _id;
    data['_fullName'] = _fullName;
    data['_avatarURL'] = _avatarURL;
    data['_email'] = _email;
    data['_is_online'] = _isOnline;
    data['friends'] = friends;
    data['request'] = request;

    return data;
  }


  bool get isOnline => _isOnline ?? false;

  String get email => _email ?? "";

  String get avatarURL => _avatarURL ?? "";

  String get fullName => _fullName ?? "Anonymus";

  String get id => _id ?? "";




  set avatarURL(String value) {
    _avatarURL = value;
  }

  set isOnline(bool? value) {
    _isOnline = value;
  }
}