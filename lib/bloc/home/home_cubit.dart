import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
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
    print(posts[index].likedByMe );
    if(posts[index].likedByMe == false){
      await FirebaseFirestore.instance.collection("posts").doc(posts[index].postID).set({
        "likes": FieldValue.arrayUnion([userModel.toJson()]),
        "likedByMe": true
      }, SetOptions(merge: true));
      posts[index].likes!.add(userModel);
      posts[index].likedByMe = true;
    } else {
      await FirebaseFirestore.instance.collection("posts").doc(posts[index].postID).set({
        "likes": FieldValue.arrayRemove([userModel.toJson()]),
        "likedByMe": false
      }, SetOptions(merge: true));
      posts[index].likes!.remove(userModel);
      posts[index].likedByMe = false;
    }

    emit(HomeLoaded(posts: posts, datetime: DateTime.now()));
  }
}
