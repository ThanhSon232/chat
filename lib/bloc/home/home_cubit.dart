import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:chat/data/model/comment.dart';
import 'package:chat/data/model/like.dart';
import 'package:chat/data/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

import '../../data/model/post.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late UserModel userModel;
  List<Post> posts = [];


  void init(UserModel cur) async {
    userModel = cur;
    await fetchPost();
  }

  Future<void> fetchPost() async{
    Map friends = userModel.friends ?? {};

    List query = [];
    friends.forEach((key, value) {
      query.add(key);
    });

    query.add(userModel.id);
    emit(HomeLoading());
    var response = await firebaseFirestore
        .collection("posts")
        .where("uploadBy", whereIn: query).orderBy("createAt", descending: true).limit(10)
        .get();
    List<Post> post = [];
    for (var element in response.docs) {
      Post temp = Post.fromJson(element.data());
      temp.convertedCreateAt = temp.createAt!.toDate().toString();
      for (var element in temp.likes!) {
        if(element.id == userModel.id){
          temp.likedByMe = true;
          break;
        }
      }
      if (temp.type == "video") {
        temp.metadata = {
          "controller": BetterPlayerController(
              BetterPlayerConfiguration(
                  deviceOrientationsAfterFullScreen: [
                    DeviceOrientation.portraitUp
                  ],
                  autoDetectFullscreenAspectRatio: true,
                  autoDispose: false,
                  expandToFill: false,
                  fit: BoxFit.contain,
                  showPlaceholderUntilPlay: true,
                  fullScreenAspectRatio: temp.aspectRatio,
                  placeholder: temp.thumbnail != null
                      ? Image.network(temp.thumbnail!)
                      : null,
                  aspectRatio: temp.aspectRatio),
              betterPlayerDataSource: BetterPlayerDataSource(
                BetterPlayerDataSourceType.network,
                temp.uri!,
              ))
        };
      }
      post.add(temp);
    }
    emit(HomeLoaded(posts: post, datetime: DateTime.now()));
  }

  Future<XFile?> sendPicture() async {
    XFile? file = await ImagePicker().pickImage(
        imageQuality: 50,
        source: ImageSource.gallery);
    return file;
  }

  Future<XFile?> sendVideo() async {
    XFile? file = await ImagePicker().pickVideo(
        source: ImageSource.gallery);
    return file;
  }


  Future<void> refreshPost() async{
    posts.clear();
    await fetchPost();
  }

  void likedPost(int index) async{
    Likes like = Likes.fromJson(
        {
          "id": userModel.id,
          "avatarURL": userModel.avatarURL,
          "fullName": userModel.fullName
        }
    );
    if(!posts[index].likedByMe!){
      firebaseFirestore.collection("posts").doc(posts[index].postID).update({
        "likes": FieldValue.arrayUnion([
          like.toJson()
        ]),
      });

      posts[index].likes!.add(like);
      posts[index].likedByMe = true;

      // if(like.id != posts[index].author!.id){
      //   firebaseFirestore.collection("notification").doc(posts[index].author!.id).update({
      //
      //   });
      // }

    }
    else {
      firebaseFirestore.collection("posts").doc(posts[index].postID).update({
        "likes": FieldValue.arrayRemove([
          {
            "id": userModel.id,
            "avatarURL": userModel.avatarURL,
            "fullName": userModel.fullName
          }
        ]),
      });
      for (var element in posts[index].likes!) {
        if(element.id == userModel.id){
          posts[index].likes!.remove(element);
          break;
        }
      }
      posts[index].likedByMe = false;
    }


    emit(HomeLoaded(posts: posts, datetime: DateTime.now()));
  }

  void commentPost(int index, String text) async{

    Comment comment = Comment.fromJson(
        {
          "id": userModel.id,
          "avatarURL": userModel.avatarURL,
          "fullName": userModel.fullName,
          "content": text,
          "createAt": Timestamp.now()
        }
    );
    firebaseFirestore.collection("posts").doc(posts[index].postID).update({
      "comment": FieldValue.arrayUnion([
        comment.toJson()
      ]),
    });
    posts[index].comment!.add(comment);
    emit(HomeLoaded(posts: posts, datetime: DateTime.now()));
  }
}
