import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String? fullName;
  String? avatarURL;
  String? content;
  String? id;
  Timestamp? createAt;

  Comment({this.fullName, this.avatarURL, this.id, this.content, this.createAt});

  Comment.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    avatarURL = json['avatarURL'];
    id = json['id'];
    content = json['content'];
    createAt = json['createAt'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullName'] = this.fullName;
    data['avatarURL'] = this.avatarURL;
    data['id'] = this.id;
    data['content'] = this.content;
    data['createAt'] = this.createAt;
    return data;
  }
}