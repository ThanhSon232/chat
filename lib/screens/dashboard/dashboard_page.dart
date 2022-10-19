import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../route.gr.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).update({
      'is_online': true
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed){
      FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).update({
        'is_online': true
      });
    }
    else {
      FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).update({
        'is_online': false
      });
    }
  }


  @override
  Widget build(context) {
    return AutoTabsScaffold(
      routes: const [
        MessagePageRoute(),
        CallPageRoute()
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chat_bubble_2),label: "Messages"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.phone), label: "Calls"),
            // BottomNavigationBarItem(
            //     icon: Icon(CupertinoIcons.person_2)),
          ],
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return CupertinoTabScaffold(
  //     tabBar: CupertinoTabBar(
  //       items: const [
  //         BottomNavigationBarItem(
  //             icon: Icon(CupertinoIcons.chat_bubble_2)),
  //         BottomNavigationBarItem(
  //             icon: Icon(CupertinoIcons.phone)),
  //         BottomNavigationBarItem(
  //             icon: Icon(CupertinoIcons.person_2)),
  //       ],
  //     ),
  //     tabBuilder: (context, index) {
  //       return CupertinoTabView(
  //         builder: (context) {
  //           return pages[index];
  //         },
  //       );
  //     },
  //   );  }
}
