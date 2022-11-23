import 'package:auto_route/auto_route.dart';
import 'package:chat/bloc/settings/setting_cubit.dart';
import 'package:chat/theme/dimension.dart';
import 'package:chat/widgets/custom_circle_avatar_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/global_cubit.dart';
import '../../route.gr.dart';
import '../../theme/color.dart';
import '../../theme/style.dart';

class SettingPage extends StatefulWidget implements AutoRouteWrapper {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingCubit(),
      child: this,
    );
  }
}

class _SettingPageState extends State<SettingPage> {
  late SettingCubit cubit;

  @override
  void initState() {
    cubit = BlocProvider.of(context);
    cubit.init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: white,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  context.router.pop();
                },
                icon: const Icon(
                  Icons.cancel_outlined,
                  color: black,
                ))
          ],
        ),
        backgroundColor: white,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: userInfo()),

            SliverFillRemaining(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: black,),
                    title: Text("Profile", style: title.copyWith(color: black, fontSize: size_18_sp),),
                    onTap: () {
                      context.router.push(ProfilePageRoute(currentUser: BlocProvider.of<GlobalCubit>(context).currentUser,user: BlocProvider.of<GlobalCubit>(context).currentUser));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: black,),
                    title: Text("Log out", style: title.copyWith(color: black, fontSize: size_18_sp),),
                    onTap: () async{
                      await BlocProvider.of<GlobalCubit>(context).dispose();
                      await cubit.logout().then((value) async {
                        context.router.pop().then((value){
                          context.router.replaceNamed("/login-screen");
                        });
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Widget userInfo() {
    return BlocBuilder<SettingCubit, SettingState>(
      builder: (context, state) {
        if(state is SettingLoaded) {
          return Column(children: [
          GestureDetector(
            onTap: () async{
              cubit.openBottomSheet(context);
            },
            child: CustomCircleAvatarStatus(
              user: cubit.userModel,
            ),
          ),
          SizedBox(
            height: size_5_h,
          ),
          Text(
            cubit.userModel.fullName,
            style: header,
          )
        ]);
        }
        return Container();
      },
    );
  }

}
