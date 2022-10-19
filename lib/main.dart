import 'package:chat/data/model/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  if(!Hive.isAdapterRegistered(0)){
    Hive.registerAdapter(UserModelAdapter());
  }
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}