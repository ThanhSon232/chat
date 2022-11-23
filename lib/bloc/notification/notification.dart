import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/color.dart';
import '../../theme/style.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notification",
          style: header,
        ),
        elevation: 0,
        backgroundColor: white,
        centerTitle: false
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(child: Text("Is being updated"),),
      ),
    );
  }
}
