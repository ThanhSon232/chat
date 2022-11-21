import 'package:chat/data/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  UserModel? author;
  String? uploadBy;
  String? postID;
  Timestamp? createAt;
  String? convertedCreateAt;
  List<UserModel>? likes;
  List<String>? comment;
  String? caption;
  String? type;
  String? uri;
  String? thumbnail;
  int? size;
  String? name;
  double? aspectRatio;
  Map? metadata;
  bool? likedByMe;

  Post(
      {this.author,
        this.uploadBy,
        this.postID,
        this.createAt,
        this.likes,
        this.comment,
        this.caption,
        this.type,
        this.uri,
        this.thumbnail,
        this.size,
        this.name,
        this.likedByMe,
        this.aspectRatio});

  Post.fromJson(Map<String, dynamic> json) {

    author =  json['author'] != null ? UserModel.fromJson(json['author']) : null;
    postID = json['postID'];
    likedByMe = json['likedByMe'];
    createAt = json['createAt'];
    if (json['likes'] != null) {
      likes = <UserModel>[];
      json['likes'].forEach((v) {
        likes!.add(UserModel.fromJson(v));
      });
    }    comment = json['comment'].cast<String>();
    caption = json['caption'];
    type = json['type'];
    uri = json['uri'];
    uploadBy = json['uploadBy'];
    thumbnail = json['thumbnail'];
    size = json['size'];
    name = json['name'];
    aspectRatio = json['aspect_ratio'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.author != null) {
      data['author'] = this.author!.toJson();
    }
    data['uploadBy'] = this.uploadBy;
    data['postID'] = this.postID;
    data['createAt'] = this.createAt;
    if (this.likes != null) {
      data['likes'] = this.likes!.map((v) => v.toJson()).toList();
    }
    data['comment'] = this.comment;
    data['caption'] = this.caption;
    data['type'] = this.type;
    data['uri'] = this.uri;
    data['thumbnail'] = this.thumbnail;
    data['size'] = this.size;
    data['name'] = this.name;
    data['aspect_ratio'] = this.aspectRatio;
    return data;
  }
}