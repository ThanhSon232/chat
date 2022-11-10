import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:bloc/bloc.dart';
import 'package:chat/theme/color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
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
  // StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? accountSub;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  GlobalKey key = GlobalKey();
  GlobalKey secondKey = GlobalKey();
  OverlayEntry? overlayEntry;
  final ImagePicker _picker = ImagePicker();
  bool isEnd = false;
  bool isShow = false;
  bool isNotFriend = false;
  bool isBlocked = false;
  bool isBlockedByMe = false;

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

    // if (id.isNotEmpty) {
    //   chatID = id;
    //   Map friends = currentUser.friends ?? {};
    //   if (currentUser.id == userModel.id) {
    //     isBlocked = true;
    //   } else {
    //     if (friends.containsKey(userModel.id) == false) {
    //       isNotFriend = true;
    //     }
    //   }
    // } else {
      await checkUser(userModel, currentUser);
    // }
    await getMessage();
    emit(ChatInitial());
  }

  Future<void> acceptButton(UserModel userModel) async {
    await firebaseFirestore.collection("users").doc(user.id).set({
      "friends": {userModel.id: true}
    }, SetOptions(merge: true));
    var box = await Hive.openBox("box");
    UserModel currentUser = await box.get("user");
    currentUser.friends?.putIfAbsent(userModel.id, () => true);
    await box.put("user", currentUser);
    isNotFriend = false;
    emit(ChatInitial());
  }

  Future<void> cancelButton(UserModel userModel, BuildContext context) async {
    await firebaseFirestore.collection("chat").doc(chatID).set({
      "blocked": true,
      "blockedBy": user.id

    },SetOptions(merge: true));
    await firebaseFirestore.collection("users").doc(user.id).set(
        {
          "friends": {
            userModel.id: false
          }
        }, SetOptions(merge: true));
    var box = await Hive.openBox("box");
    UserModel currentUser = await box.get("user");
    await currentUser.friends?.putIfAbsent(userModel.id, () => false);
    await box.put("user", currentUser).then((value) {
      context.router.pop();
    });
  }


  Future<void> unblock() async{
    await firebaseFirestore.collection("chat").doc(chatID).set({
      "blocked": false,
      "blockedBy": null
    },SetOptions(merge: true));
    isBlocked = false;
    emit(ChatInitial());
  }





  Future<void> checkUser(UserModel userModel, UserModel currentUser) async {
    try {
      await firebaseFirestore
          .collection("chat")
          .where('users', whereIn: [
            [
              {currentUser.id: null},
              {userModel.id: null}
            ],
            [
              {userModel.id: null},
              {currentUser.id: null}
            ],
            [
              {userModel.id: null}
            ]
          ])
          .limit(1)
          .get()
          .then(
            (QuerySnapshot querySnapshot) async {
              if (querySnapshot.docs.isNotEmpty) {
                chatID = querySnapshot.docs.single.id;
                Map friends = currentUser.friends ?? {};
                if (currentUser.id == userModel.id) {
                  isBlocked = true;
                } else {
                  if (friends.containsKey(userModel.id) == false) {
                    isNotFriend = true;
                  }
                }
                var data = querySnapshot.docs.first.data() as Map;
                if(data["blocked"]){
                  isBlocked = true;
                  if(data["blockedBy"] == currentUser.id){
                    isBlockedByMe = true;
                  }
                }
              } else {
                await firebaseFirestore.collection("chat").add({
                  'users': [
                    {userModel.id: null},
                    {currentUser.id: null}
                  ],
                  'createAt': FieldValue.serverTimestamp(),
                  "blocked": false
                }).then((value) => {chatID = value.id});
                isNotFriend = false;
                await firebaseFirestore
                    .collection("users")
                    .doc(currentUser.id)
                    .set({
                  "friends": {userModel.id: true}
                }, SetOptions(merge: true));
                var box = await Hive.openBox("box");
                currentUser.friends?.putIfAbsent(userModel.id, () => true);
                await box.put("user", currentUser);
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
    var createAt = FieldValue.serverTimestamp();
    try {
      FieldValue.serverTimestamp();
      firebaseFirestore
          .collection("chat")
          .doc(chatID)
          .collection('message')
          .add({
        'createAt': FieldValue.serverTimestamp(),
        'msg': message.text,
        'type': 'text',
        'messageID': generateRandomString(10),
        'sender': user.toJson()
      }).then((value) async {
        var response = await value.get();
        await firebaseFirestore
            .collection("chat")
            .doc(chatID)
            .update({"last_message": response.data(), "createAt": createAt});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> loadMore() async {
    if (isEnd) return;
    var data = await firebaseFirestore
        .collection("chat")
        .doc(chatID)
        .collection("message")
        .orderBy("createAt", descending: true)
        .startAfter(
            [Timestamp.fromMillisecondsSinceEpoch(messageList.last.createdAt!)])
        .limit(15)
        .get();
    if (data.size > 0) {
      for (var value in data.docChanges) {
        messageList.add(parseMessage(value));
      }
    } else {
      isEnd = true;
    }
    emit(ChatInitial());
  }

  Future<void> getMessage() async {

    streamSub = firebaseFirestore
        .collection("chat")
        .doc(chatID)
        .collection("message")
        .orderBy("createAt", descending: false)
        .snapshots()
        .listen((data) {
      var size = data.docChanges.length > 15 ? 15 : data.docChanges.length;
      var i = 0;
      for (var element in data.docChanges.reversed) {
        if (i > size) break;
        if (element.type == DocumentChangeType.added) {
          if (element.doc.data()?["msg"] != null) {
            if (size == 1) {
              messageList.insert(0, parseMessage(element));
            } else {
              messageList.add(parseMessage(element));
            }
          }
        } else if (element.type == DocumentChangeType.removed) {
          for (var value in messageList) {
            if (value.id == element.doc.id) {
              messageList.remove(value);
              break;
            }
          }
        }
        i++;
      }
      emit(ChatInitial());
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
          createdAt: change.doc.data()!["createAt"] == null
              ? DateTime.now().millisecondsSinceEpoch
              : change.doc.data()!["createAt"].toDate().millisecondsSinceEpoch,
          size: change.doc.data()!["size"],
          name: change.doc.data()!["name"],
          metadata: {"key": GlobalKey(), "aspect_ratio": change.doc.data()?["aspect_ratio"] ?? 9/16},
          uri: change.doc.data()!["uri"]);
    } else if (change.doc.data()?["type"] == "video") {
      return types.CustomMessage(
          author: types.User(
            id: change.doc.data()!["sender"]["id"],
            lastName: change.doc.data()?["sender"]["lastName"],
            imageUrl: change.doc.data()?["sender"]["imageURL"],
            createdAt: change.doc.data()!["createAt"] == null
                ? DateTime.now().millisecondsSinceEpoch
                : change.doc
                    .data()!["createAt"]
                    .toDate()
                    .millisecondsSinceEpoch,
          ),
          id: change.doc.id,
          createdAt: change.doc.data()!["createAt"] == null
              ? DateTime.now().millisecondsSinceEpoch
              : change.doc.data()!["createAt"].toDate().millisecondsSinceEpoch,
          metadata: {
            "size": change.doc.data()!["size"],
            "name": change.doc.data()!["name"],
            "uri": change.doc.data()!["uri"],
            "key": GlobalKey(),
            "aspect_ratio": change.doc.data()!["aspect_ratio"],
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
                    fullScreenAspectRatio: change.doc.data()!["aspect_ratio"],
                    placeholder: change.doc.data()!["thumbnail"] != null
                        ? Image.network(change.doc.data()!["thumbnail"])
                        : null,
                    aspectRatio: change.doc.data()!["aspect_ratio"]),
                betterPlayerDataSource: BetterPlayerDataSource(
                  BetterPlayerDataSourceType.network,
                  change.doc.data()!["uri"],
                ))
          });
    }
    return types.TextMessage(
        author: types.User(
          id: change.doc.data()!["sender"]["id"],
          lastName: change.doc.data()?["sender"]["lastName"],
          imageUrl: change.doc.data()?["sender"]["imageURL"],
        ),
        createdAt: change.doc.data()!["createAt"] == null
            ? DateTime.now().millisecondsSinceEpoch
            : change.doc.data()!["createAt"].toDate().millisecondsSinceEpoch,
        id: change.doc.id,
        metadata: {"key": GlobalKey()},
        text: change.doc.data()?["msg"]);
  }

  void openCameraSelector(BuildContext context) {
    RenderBox box = secondKey.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    showOverlay(context, position: position, type: "camera");
  }

  void openMediaSelector(BuildContext context) {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    showOverlay(context, position: position, type: "gallery");
  }

  void showOverlay(BuildContext context,
      {required Offset position, required String type}) async {
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
                                  sendPicture(type);
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
                                  sendVideo(type);
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

  Future<void> sendPicture(String type) async {
    XFile? file = await _picker.pickImage(
      imageQuality: 50,
        source: type == "gallery" ? ImageSource.gallery : ImageSource.camera);
    if (file != null) {
      await uploadToStorage("image", file);
    }
  }

  Future<void> sendVideo(String type) async {
    XFile? file = await _picker.pickVideo(
      maxDuration: const Duration(seconds: 30),
        source: type == "gallery" ? ImageSource.gallery : ImageSource.camera);
    if (file != null) {
      uploadToStorage("video", file);
    }
  }

  Future<void> uploadToStorage(String type, XFile file) async {
    Reference ref = _storage.ref("$type/${file.name}");
    File newFile = File(file.path);
    UploadTask uploadTask = ref.putFile(newFile);
    Map info = await getThumbnail(file, type);
    var createAt = FieldValue.serverTimestamp();

    await uploadTask.then((res) {
      res.ref.getDownloadURL().then((value) {
        firebaseFirestore
            .collection("chat")
            .doc(chatID)
            .collection('message')
            .add({
          if (type == "video") 'thumbnail': info["thumbnail"],
          'createAt': createAt,
          'msg': "${type.toUpperCase()}!! Click to see",
          'type': type,
          'messageID': generateRandomString(10),
          'sender': user.toJson(),
          'name': file.name,
          'size': File(file.path).lengthSync(),
          'uri': value,
          'aspect_ratio': info["width"] / info["height"]
        }).then((value) async {
          var response = await value.get();
          await firebaseFirestore
              .collection("chat")
              .doc(chatID)
              .update({"last_message": response.data(), 'createAt': createAt});
        });
      });
    });
  }

  Future<Map<String, dynamic>> getThumbnail(XFile file, String type) async {
    try {


      if(type == "video") {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          quality: 25,
        );
        var fileName = "${generateRandomString(10)}.jpeg";
        var decodedImage = await decodeImageFromList(uint8list!);
        final tempDir = await getTemporaryDirectory();
        File f = await File('${tempDir.path}/$fileName').create();
        f.writeAsBytesSync(uint8list);
        Reference ref = _storage.ref("/thumbnail/$fileName");
        UploadTask uploadTask = ref.putFile(f);
        await uploadTask.timeout(const Duration(seconds: 30));
        var link = await ref.getDownloadURL();
        return {
          "thumbnail": link,
          "width": decodedImage.width,
          "height": decodedImage.height
        };
      }

      var decodedImage = await decodeImageFromList(await file.readAsBytes());



      return {
        "width": decodedImage.width,
        "height": decodedImage.height
      };
    } catch (e) {
      print(e.toString());
    }
    return {};
  }

  Future<void> downloadMedia(
      BuildContext context, types.Message message) async {
    var dio = Dio();
    if (message is types.ImageMessage) {
      var tempDir = await getApplicationDocumentsDirectory();
      String fullPath = "${tempDir.path}/${message.name}";
      await dio.download(message.uri, fullPath).then((value) {
        GallerySaver.saveImage(fullPath).then((success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Saved !!!'),
            duration: Duration(milliseconds: 1000),
          ));
          Navigator.of(context).pop();
        }, onError: (e) {});
      });
    } else {
      var tempDir = await getApplicationDocumentsDirectory();
      String fullPath = "${tempDir.path}/${message.metadata!["name"]}";
      await dio.download(message.metadata!["uri"], fullPath).then((value) {
        GallerySaver.saveVideo(fullPath).then((success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Saved !!!'),
            duration: Duration(milliseconds: 1000),
          ));
          Navigator.of(context).pop();
        }, onError: (e) {});
      });
    }
  }

  Future<void> removeMessage(types.Message message) async {
    await firebaseFirestore
        .collection("chat")
        .doc(chatID)
        .collection('message')
        .doc(message.id)
        .delete();
  }

  Future<void> copyText(BuildContext context, types.Message message) async {
    message as types.TextMessage;
    await Clipboard.setData(ClipboardData(text: message.text)).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Copied to your clipboard !'),
        duration: Duration(milliseconds: 1000),
      ));
      Navigator.of(context).pop();
    });
  }
}
