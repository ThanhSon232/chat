import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:chat/bloc/global_cubit.dart';
import 'package:chat/data/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../../data/model/comment.dart';
import '../../data/model/like.dart';
import '../../data/model/post.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late UserModel user;
  late UserModel currentUser;
  List<Post> posts = [];
  bool isSend = false;

  void init(UserModel u, UserModel current) async {
    user = u;
    emit(ProfileLoading());
    var box = await Hive.openBox("box");
    currentUser = await box.get("user");
    currentUser.friends!.forEach((key, value) {
      print(key);
    });
    currentUser.friends!.containsKey(user.id) ? isSend = true : isSend;
    emit(ProfileInitial());
    await fetchPosts();
  }

  Future<void> fetchPosts() async {
    emit(ProfileLoading());
    var response = await firebaseFirestore
        .collection("posts")
        .where("uploadBy", isEqualTo: user.id)
        .orderBy("createAt", descending: true)
        .limit(10)
        .get();
    List<Post> post = [];
    for (var element in response.docs) {
      Post temp = Post.fromJson(element.data());
      temp.convertedCreateAt = temp.createAt!.toDate().toString();

      for (var element in temp.likes!) {
        if (element.id == currentUser.id) {
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
    emit(ProfileLoaded(posts: post, dateTime: DateTime.now()));
  }

  void likedPost(int index) async {
    Likes like = Likes.fromJson({
      "id": currentUser.id,
      "avatarURL": currentUser.avatarURL,
      "fullName": currentUser.fullName
    });
    if (!posts[index].likedByMe!) {
      firebaseFirestore.collection("posts").doc(posts[index].postID).update({
        "likes": FieldValue.arrayUnion([like.toJson()]),
      });

      posts[index].likes!.add(like);
      posts[index].likedByMe = true;
    } else {
      firebaseFirestore.collection("posts").doc(posts[index].postID).update({
        "likes": FieldValue.arrayRemove([
          {
            "id": currentUser.id,
            "avatarURL": currentUser.avatarURL,
            "fullName": currentUser.fullName
          }
        ]),
      });
      for (var element in posts[index].likes!) {
        if (element.id == currentUser.id) {
          posts[index].likes!.remove(element);
          break;
        }
      }
      posts[index].likedByMe = false;
    }

    emit(ProfileLoaded(posts: posts, dateTime: DateTime.now()));
  }

  void commentPost(int index, String text) async {
    Comment comment = Comment.fromJson({
      "id": currentUser.id,
      "avatarURL": currentUser.avatarURL,
      "fullName": currentUser.fullName,
      "content": text,
      "createAt": Timestamp.now()
    });
    firebaseFirestore.collection("posts").doc(posts[index].postID).update({
      "comment": FieldValue.arrayUnion([comment.toJson()]),
    });
    posts[index].comment!.add(comment);
    emit(ProfileLoaded(posts: posts, dateTime: DateTime.now()));
  }

  Future<void> addFriend(BuildContext context) async {
    await firebaseFirestore.collection("users").doc(currentUser.id).set({
      "friends": {
        user.id: {
          '_fullName': user.fullName,
          '_id': user.id,
          '_avatarURL': user.avatarURL
        }
      }
    }, SetOptions(merge: true));
    await firebaseFirestore.collection("notification").add({
      'type': "friend-request",
      'from': {
        '_fullName': user.fullName,
        '_id': user.id,
        '_avatarURL': user.avatarURL
      },
      'to': currentUser.id,
      'content': "sent you a friend request",
      'createAt': Timestamp.now(),
      'seen': false
    }).then((value){
      BlocProvider.of<GlobalCubit>(context).dispose();
      BlocProvider.of<GlobalCubit>(context).init();
    });



    currentUser.friends?.putIfAbsent(
        user.id,
        () => {
              '_fullName': user.fullName,
              '_id': user.id,
              '_avatarURL': user.avatarURL
            });
    var box = await Hive.openBox("box");
    await box.put("user", currentUser);
  }

  Future<void> removeFriend(BuildContext context) async {
    await firebaseFirestore.collection("users").doc(currentUser.id).set({
      "friends": {
        user.id: FieldValue.delete()
      }
    }, SetOptions(merge: true)).then((value){
      BlocProvider.of<GlobalCubit>(context).dispose();
      BlocProvider.of<GlobalCubit>(context).init();
    });
    currentUser.friends?.remove(user.id);
    var box = await Hive.openBox("box");
    await box.put("user", currentUser);
  }
}
