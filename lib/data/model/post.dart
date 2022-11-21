import 'package:chat/data/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  UserModel? author;
  String? uploadBy;
  String? postID;
  Timestamp? createAt;
  String? convertedCreateAt;
  List<String>? likes;
  List<String>? comment;
  String? caption;
  String? type;
  String? uri;
  String? thumbnail;
  int? size;
  String? name;
  double? aspectRatio;
  Map? metadata;

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
        this.aspectRatio});

  Post.fromJson(Map<String, dynamic> json) {

    author =  json['author'] != null ? UserModel.fromJson(json['author']) : null;
    postID = json['postID'];
    createAt = json['createAt'];
    likes = json['likes'].cast<String>();
    comment = json['comment'].cast<String>();
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
    data['author'] = this.author;
    data['uploadBy'] = this.uploadBy;
    data['postID'] = this.postID;
    data['createAt'] = this.createAt;
    data['likes'] = this.likes;
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