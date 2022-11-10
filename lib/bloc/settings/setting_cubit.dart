import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bloc/bloc.dart';
import 'package:chat/data/model/user.dart';
import 'package:chat/theme/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

import '../../theme/dimension.dart';
import '../../theme/style.dart';

part 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit() : super(SettingInitial());
  late UserModel userModel;
  final ImagePicker _picker = ImagePicker();

  void init() async {
    emit(SettingLoading());
    var box = await Hive.openBox("box");
    userModel = box.get("user");
    emit(SettingLoaded());
  }

  Future<void> logout() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'_is_online': false});
    await FirebaseAuth.instance.signOut();
    var box = await Hive.openBox("box");
    await box.clear();
  }

  Future<void> sendPicture(String type) async {
    XFile? file = await _picker.pickImage(
        source: type == "gallery" ? ImageSource.gallery : ImageSource.camera);
    if (file != null) {
      // await uploadToStorage("image", file);
    }
  }

  Future<void> uploadToStorage(String type, XFile file) async {
    Reference ref = FirebaseStorage.instance.ref("$type/${file.name}");
    File newFile = File(file.path);
    UploadTask uploadTask = ref.putFile(newFile);

    await uploadTask.then((res) {
      res.ref.getDownloadURL().then((value) async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userModel.id)
            .update({
          "_avatarURL": value
        });

        var box = await Hive.openBox("box");
        userModel.avatarURL = value;
        await box.put("user", userModel);


      });
    });
  }




  void openBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Text(
                              "Change profile picture",
                              style: subtitle,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                    onPressed: () async{
                                      await sendPicture("camera");
                                    },
                                    child: const Text(
                                      "Take photo",
                                      style: TextStyle(fontSize: 20),
                                    ))),
                            const Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                    onPressed: () async{
                                      await sendPicture("gallery");
                                    },
                                    child: const Text(
                                      "Choose from library",
                                      style: TextStyle(fontSize: 20),
                                    ))),
                            const Divider(
                              thickness: 1,
                            ),
                          ],

                        )),


                    SizedBox(
                      height: size_10_h,
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                      color: white, borderRadius: BorderRadius.circular(16)),
                      child: TextButton(
                          onPressed: () {
                            context.router.pop();
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontSize: 20),
                          )),
                    )

                  ],
                ),
              ],
            ),
          );
        });
  }
}
