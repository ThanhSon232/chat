import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  const CallPage({Key? key}) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          context.router.replaceNamed('/login-screen');
        }, child: Text("LOG OUT"),
        
      ),
    );
  }
}