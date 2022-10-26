import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:chat/theme/color.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../data/model/user.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  late types.User user;
  List<types.Message> messageList = [];
  TextEditingController msgController = TextEditingController();
  String chatID = "";
  StreamSubscription<QuerySnapshot>? streamSub;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  GlobalKey key = GlobalKey();
  OverlayEntry? overlayEntry;
  final ImagePicker _picker = ImagePicker();

  ChatCubit() : super(ChatInitial());

  void init(UserModel userModel, String id) async {
    emit(ChatLoading());
    var box = await Hive.openBox("box");
    UserModel currentUser = await box.get("user");
    user = types.User(
      id: currentUser.id,
      lastName: currentUser.fullName,
      imageUrl: currentUser.avatarURL,
    );
    if (id.isNotEmpty) {
      chatID = id;
    } else {
      await checkUser(userModel, currentUser);
    }
    await getMessage(currentUser);
    emit(ChatInitial());
  }

  Future<void> checkUser(UserModel userModel, UserModel currentUser) async {
    try {
      print(userModel.fullName);
      print(currentUser.fullName);
      await firebaseFirestore
          .collection("chat")
          .where('users', isEqualTo: {userModel.id: null, currentUser.id: null})
          .limit(1)
          .get()
          .then(
            (QuerySnapshot querySnapshot) async {
              if (querySnapshot.docs.isNotEmpty) {
                chatID = querySnapshot.docs.single.id;
                print(querySnapshot.docs.single.id);
              } else {
                await firebaseFirestore.collection("chat").add({
                  'users': {userModel.id: null, currentUser.id: null},
                }).then((value) => {chatID = value.id});
              }
            },
          );
    } catch (e) {
      print(e.toString());
    }
  }

  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }

  Future<void> sendMessage(types.PartialText message) async {
    try {
      firebaseFirestore
          .collection("chat")
          .doc(chatID)
          .collection('message')
          .add({
        'createAt': DateTime.now().microsecondsSinceEpoch,
        'msg': message.text,
        'type': 'text',
        'messageID': generateRandomString(10),
        'sender': user.toJson()
      }).then((value) async {
        var response = await value.get();
        await firebaseFirestore
            .collection("chat")
            .doc(chatID)
            .update({"last_message": response.data()});
      });
      emit(ChatInitial());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> loadMore() async{
    var data = await firebaseFirestore
        .collection("chat")
        .doc(chatID)
        .collection("message")
        .orderBy("createAt", descending: false).startAfter(messageList).limitToLast(1).get();
    // print(data.docs.first.data());
  }

  Future<void> getMessage(UserModel userModel) async {
    streamSub = firebaseFirestore
        .collection("chat")
        .doc(chatID)
        .collection("message")
        .orderBy("createAt", descending: false)
        .snapshots()
        .listen((data) {
      for (var change in data.docChanges) {
        messageList.insert(0, parseMessage(change));
        emit(ChatInitial());
      }
    });
  }

  types.Message parseMessage(DocumentChange<Map<String, dynamic>> change) {
    if (change.doc.data()?["type"] == "image") {
      return types.ImageMessage(
          author: types.User(
            id: change.doc.data()!["sender"]["id"],
            lastName: change.doc.data()?["sender"]["lastName"],
            imageUrl: change.doc.data()?["sender"]["imageURL"],
          ),
          id: change.doc.id,
          size: change.doc.data()!["size"],
          name: change.doc.data()!["name"],
          uri: change.doc.data()!["uri"]);
    } else if (change.doc.data()?["type"] == "video") {
      return types.CustomMessage(
          author: types.User(
            id: change.doc.data()!["sender"]["id"],
            lastName: change.doc.data()?["sender"]["lastName"],
            imageUrl: change.doc.data()?["sender"]["imageURL"],
          ),
          id: change.doc.id,
          metadata: {
            "size": change.doc.data()!["size"],
            "name": change.doc.data()!["name"],
            "uri": change.doc.data()!["uri"],
            "aspect_ratio": change.doc.data()!["aspect_ratio"],
            "controller": BetterPlayerController(
                BetterPlayerConfiguration(
                    autoDispose: false,
                    aspectRatio: change.doc.data()!["aspect_ratio"]),
                betterPlayerDataSource: BetterPlayerDataSource(
                  BetterPlayerDataSourceType.network,
                  change.doc.data()!["uri"],
                  // cacheConfiguration: const BetterPlayerCacheConfiguration(
                  //   useCache: true,
                  //   preCacheSize: 10 * 1024 * 1024,
                  //   maxCacheSize: 10 * 1024 * 1024,
                  //   maxCacheFileSize: 10 * 1024 * 1024,
                  //
                  //   ///Android only option to use cached video between app sessions
                  //   key: "testCacheKey",
                  // ),
                ))
          });
    }
    return types.TextMessage(
        author: types.User(
          id: change.doc.data()!["sender"]["id"],
          lastName: change.doc.data()?["sender"]["lastName"],
          imageUrl: change.doc.data()?["sender"]["imageURL"],
        ),
        id: change.doc.id,
        text: change.doc.data()?["msg"]);
  }

  void openMenu(BuildContext context) {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    showOverlay(context, position: position);
  }

  void showOverlay(BuildContext context, {required Offset position}) async {
    OverlayState? overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Stack(
        children: [
          Positioned.fill(
              child: GestureDetector(
                  onTap: () {
                    if (overlayEntry != null) {
                      print("removed");
                      overlayEntry!.remove();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                  ))),
          Positioned(
              left: position.dx - 25,
              top: position.dy - 105,
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        color: grey_100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blueGrey)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: double.infinity,
                            child: TextButton(
                                onPressed: () {
                                  sendPicture();
                                  overlayEntry!.remove();
                                },
                                child: const Text("Picture"))),
                        const SizedBox(
                          width: double.infinity,
                          child: Divider(
                            height: 1,
                          ),
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: TextButton(
                                onPressed: () {
                                  sendVideo();
                                  overlayEntry!.remove();
                                },
                                child: const Text("Video"))),
                      ],
                    ),
                  ),
                  // SizedBox(height: size_5_h,),
                  const Icon(
                    Icons.arrow_drop_down_sharp,
                    color: blue,
                  )
                ],
              ))
        ],
      );
    });
    overlayState!.insert(overlayEntry!);
  }

  Future<void> sendPicture() async {
    XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await uploadToStorage("image", file);
    }
  }

  Future<void> sendVideo() async {
    XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      uploadToStorage("video", file);
    }
  }

  Future<void> uploadToStorage(String type, XFile file) async {
    Reference ref = _storage.ref("$type/${file.name}");
    File newFile = File(file.path);
    UploadTask uploadTask = ref.putFile(newFile);
    Map size = {};
    var thumbnailLink = '';
    if (type == "video") {
      size = await getThumbnail(file);
      // Uint8List? thumbnail = size["thumbnail"];
      // String thumbName = File.fromRawPath(thumbnail!).path.split("/").last;
      // Reference r = _storage.ref("images/$thumbName");
      // UploadTask uploadThumbnail = r.putFile(File.fromRawPath(thumbnail!));
      // await uploadThumbnail.then((res) async {
      //  thumbnailLink =  await res.ref.getDownloadURL();
      //  print(thumbnailLink);
      // });
    }

    await uploadTask.then((res) {
      res.ref.getDownloadURL().then((value) {
        firebaseFirestore
            .collection("chat")
            .doc(chatID)
            .collection('message')
            .add({
          // if (type == "video")
          // 'thumbnail': thumbnailLink,
          'createAt': DateTime.now().microsecondsSinceEpoch,
          'msg': "${type.toUpperCase()}!! Click to see",
          'type': type,
          'messageID': generateRandomString(10),
          'sender': user.toJson(),
          'name': file.name,
          'size': File(file.path).lengthSync(),
          'uri': value,
          if (type == "video") 'aspect_ratio': size["width"] / size["height"]
        }).then((value) async {
          var response = await value.get();
          await firebaseFirestore
              .collection("chat")
              .doc(chatID)
              .update({"last_message": response.data()});
        });
      });
    });
  }

  Future<Map<String, dynamic>> getThumbnail(XFile file) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      quality: 25,
    );

    var decodedImage = await decodeImageFromList(uint8list!);

    return {
      "thumbnail": uint8list,
      "width": decodedImage.width,
      "height": decodedImage.height
    };
  }
}
