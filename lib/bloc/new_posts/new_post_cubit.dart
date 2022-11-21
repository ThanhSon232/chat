import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../data/model/user.dart';

part 'new_post_state.dart';

class NewPostCubit extends Cubit<NewPostState> {
  NewPostCubit() : super(NewPostInitial());
  UserModel? userModel;
  ImagePicker _picker = ImagePicker();
  TextEditingController textEditingController = TextEditingController();
  String type = "text";
  XFile? xFile;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }

  void init(UserModel current, XFile? file, String? type){
    userModel = current;
    if(file != null && type != null){
      xFile = file;
      this.type = type;
      emit(NewPostAdded(xFile: file, type: type));
    }

  }

  Future<void> sendPicture(String type) async {
    XFile? file = await _picker.pickImage(
        imageQuality: 50,
        source: type == "gallery" ? ImageSource.gallery : ImageSource.camera);
    if (file != null) {
      xFile = file;
      this.type = "image";
      emit(NewPostAdded(xFile: file, type: "image"));
    }
  }

  Future<void> sendVideo(String type) async {
    XFile? file = await _picker.pickVideo(
        maxDuration: const Duration(seconds: 30),
        source: type == "gallery" ? ImageSource.gallery : ImageSource.camera);
    if (file != null) {
      xFile = file;
      this.type = "video";
      emit(NewPostAdded(xFile: file, type: "video"));
    }
  }

  void removeMedias(){
    xFile = null;
    type = "text";
    emit(NewPostRemove());
  }

  Future<void> uploadToStorage(String type, XFile file, String caption) async {
    Reference ref = _storage.ref("$type/${file.name}");
    File newFile = File(file.path);
    UploadTask uploadTask = ref.putFile(newFile);
    Map info = await getThumbnail(file, type);
    var createAt = FieldValue.serverTimestamp();
    String id = generateRandomString(10);

    await uploadTask.then((res) {
      res.ref.getDownloadURL().then((value) {
        firebaseFirestore.collection("posts").doc(id).set({
          if (type == "video") 'thumbnail': info["thumbnail"],
          'createAt': createAt,
          'type': type,
          'likes': [],
          'comment': [],
          'caption': caption,
          'postID': id,
          'likedByMe': false,
          'uploadBy': userModel!.id,
          'author': userModel?.toJson(),
          'name': file.name,
          'size': File(file.path).lengthSync(),
          'uri': value,
          'aspect_ratio': info["width"] / info["height"]
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

  Future<void> publish() async {
    if(xFile != null){
      await uploadToStorage(type, xFile!, textEditingController.text);
      return;
    }
    var createAt = FieldValue.serverTimestamp();
    String id = generateRandomString(10);
    await firebaseFirestore.collection("posts").add({
      'createAt': createAt,
      'type': type,
      'likes': [],
      'comment': [],
      'likedByMe': false,
      'caption': textEditingController.text,
      'postID': id,
      'author': userModel?.toJson(),
      'uploadBy': userModel!.id
    });
  }



}
