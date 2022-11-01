import 'package:auto_route/auto_route.dart';
import 'package:chat/bloc/people/people_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../route.gr.dart';
import '../../theme/color.dart';
import '../../theme/dimension.dart';
import '../../theme/style.dart';
import '../../widgets/custom_circle_avatar_status.dart';

class PeopleScreen extends StatefulWidget implements AutoRouteWrapper {
  const PeopleScreen({Key? key}) : super(key: key);

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => PeopleCubit(),
      child: this, // this as the child Important!
    );
  }
}

class _PeopleScreenState extends State<PeopleScreen> {
  late PeopleCubit cubit;

  @override
  void initState() {
    cubit = BlocProvider.of(context);
    cubit.init();
    super.initState();

  }

  @override
  void dispose() {
    cubit.timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "People",
          style: header,
        ),
        centerTitle: false,
        backgroundColor: white,
        elevation: 0,
        actions: [
          IconButton(onPressed: (){
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (builder){
                  return Container(
                    height: MediaQuery.of(context).size.height*.95,
                    color: Colors.transparent, //could change this to Color(0xFF737373),
                    //so you don't have to change MaterialApp canvasColor
                    child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:  BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0))),
                        child: const Center(
                          child:  Text("This is a modal sheet"),
                        )),
                  );
                }
            );
          }, icon: const Icon(Icons.add, color: blue,))
        ],
      ),
      backgroundColor: white,
      body: BlocConsumer<PeopleCubit, PeopleState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is PeopleInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else
            if (state is PeopleLoaded) {
            var peopleList = state.userModelList;
            return peopleList.isNotEmpty
                ? ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CustomCircleAvatarStatus(
                          user: peopleList[index],
                          radius: size_30_w,
                        ),
                        title: Text(
                          peopleList[index].fullName,
                          overflow: TextOverflow.ellipsis,
                          style: title.copyWith(
                              color: black,
                              fontWeight: FontWeight.w500,
                              fontSize: size_18_sp),
                        ),
                        onTap: () {
                          context.router.push(ChatScreenRoute(
                              userModel: peopleList[index],
                              chatID:    ""));
                        },
                      );
                    },
                    separatorBuilder: (_, index) {
                      return SizedBox(
                        height: size_10_h,
                      );
                    },
                    itemCount: peopleList.length,
                  )
                : const Center(
                    child: Text("No one is online bro"),
                  );
          }

          return const Text("Error");
        },
      ),
    );
  }
}
