import 'package:auto_route/auto_route.dart';
import 'package:chat/bloc/global_cubit.dart';
import 'package:chat/data/model/user.dart';
import 'package:chat/route.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/like.dart';
import '../../theme/color.dart';
import '../../theme/dimension.dart';
import '../../theme/style.dart';

class LikePage extends StatelessWidget {
  final List<Likes> list;
  final UserModel user;

  const LikePage({Key? key, required this.list, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: black,
          ),
          onPressed: (){
            context.router.pop();
          },
        ),
        title: Text(
          "${list.length} ${list.length == 1 ? "like" : "likes"}",
          style: header,
        ),
        elevation: 0,
        backgroundColor: white,
        centerTitle: false,
      ),
      backgroundColor: grey_100,
      body: ListView.builder(
        itemBuilder: (_, index) {
          return ListTile(
            onTap: (){
              var result = BlocProvider.of<GlobalCubit>(context).allUserList.indexWhere((element) => element.id == list[index].id);
              if(result  == -1){
                context.router.push(ProfilePageRoute(currentUser: user, user: UserModel(list[index].id,list[index].fullName,list[index].avatarURL)));
              } else {
                context.router.push(ProfilePageRoute(currentUser: user, user: BlocProvider.of<GlobalCubit>(context).allUserList[result]));
              }
            },
            focusColor: white,
            leading: CircleAvatar(
              backgroundImage: NetworkImage(list[index].avatarURL!),
            ),
            title: Text(list[index].fullName!, style: title.copyWith(fontSize: size_20_sp, color: black),),
            trailing: user.id != list[index].id ?
              IconButton(
              onPressed: () {
                var result = BlocProvider.of<GlobalCubit>(context).allUserList.indexWhere((element) => element.id == list[index].id);
                if(result  == -1){
                  context.router.push(ChatScreenRoute(userModel: UserModel(list[index].id,list[index].fullName,list[index].avatarURL), chatID: ""));
                } else {
                  context.router.push(ChatScreenRoute(userModel: BlocProvider.of<GlobalCubit>(context).allUserList[result], chatID: ""));
                }
              },
              icon: const Icon(Icons.message, color: black,),

            ) : null,
          );
        },
        itemCount: list.length,
      ),
    );
  }
}
