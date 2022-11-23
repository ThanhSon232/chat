import 'package:auto_route/auto_route.dart';
import 'package:chat/bloc/global_cubit.dart';
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
    return BlocProvider.value(
      value: BlocProvider.of<GlobalCubit>(context),
      child: this, // this as the child Important!
    );
  }
}

class _PeopleScreenState extends State<PeopleScreen> {
  late GlobalCubit cubit;

  @override
  void initState() {
    cubit = BlocProvider.of(context);
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
        title: Text(
          "People",
          style: header,
        ),
        centerTitle: false,
        backgroundColor: white,
        elevation: 0,
      ),
      backgroundColor: white,
      body: BlocConsumer<GlobalCubit, GlobalState>(
        listener: (context, state) {

        },
        builder: (context, state) {
          if (state is GlobalInitial) {
            return Container();
          } else if (state is GlobalLoaded) {
            var peopleList = state.allUser;
            return peopleList.isNotEmpty
                ? ListView.separated(
                    itemBuilder: (context, index) {
                      // if(!peopleList[index].isOnline) return const SizedBox.shrink();
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
                              userModel: peopleList[index], chatID: ""));
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
