import 'package:auto_route/auto_route.dart';
import 'package:chat/bloc/global_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../route.gr.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<GlobalCubit>(context).init();
    WidgetsBinding.instance.addObserver(this);
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'_is_online': true});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'_is_online': true});
    } else {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'_is_online': false});
    }
  }

  @override
  Widget build(context) {
    return AutoTabsScaffold(
      routes: const [
        MessagePageRoute(),
        PeopleScreenRoute(),
        NotificationPageRoute(),
        HomePageRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.blue,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chat_bubble_2), label: "Messages"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_2), label: "People"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.bell), label: "Notification"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home), label: "Home"),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    BlocProvider.of<GlobalCubit>(context).listener.cancel();
    super.dispose();
  }
}
