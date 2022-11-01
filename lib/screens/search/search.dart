import 'package:auto_route/auto_route.dart';
import 'package:chat/bloc/search/search_cubit.dart';
import 'package:chat/theme/style.dart';
import 'package:chat/widgets/custom_circle_avatar_status.dart';
import 'package:chat/widgets/custom_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/user.dart';
import '../../route.gr.dart';
import '../../theme/color.dart';
import '../../theme/dimension.dart';

class SearchPage extends StatefulWidget implements AutoRouteWrapper {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: this, // this as the child Important!
    );
  }
}

class _SearchPageState extends State<SearchPage> {
  late SearchCubit cubit;

  @override
  void initState() {
    cubit = BlocProvider.of(context);
    cubit.init();
    super.initState();
  }

  @override
  void dispose() {
    cubit.textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: CustomSearch(
          controller: cubit.textEditingController,
        ),
        backgroundColor: white,
        elevation: 0,
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              context.router.pop();
            },
            child: const Text("Cancel"),
          )
        ],
      ),
      backgroundColor: white,
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SearchSuggestion) {
            cubit.userList = state.userList;
            return suggestion(state.userList);
          } else if (state is SearchLoaded) {
            return result(state.userList);
          }
          return Container();
        },
      ),
    );
  }

  Widget result(List<UserModel> suggestionList) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(size_15_h),
            child: Text(
              "Result",
              style: subtitle.copyWith(fontSize: size_16_sp),
            ),
          ),
        ),
        SliverFillRemaining(
          child: suggestionList.isEmpty
              ? const Center(
                  child: Text("No result"),
                )
              : ListView.separated(
                  itemBuilder: (_, index) {
                    return ListTile(
                      onTap: () {
                        context.router.pop();
                        context.router.push(ChatScreenRoute(
                            userModel: suggestionList[index], chatID: ""));
                      },
                      leading:
                          CustomCircleAvatarStatus(user: suggestionList[index]),
                      contentPadding: EdgeInsets.zero,
                      title: Text(suggestionList[index].fullName),
                    );
                  },
                  separatorBuilder: (_, index) {
                    return SizedBox(
                      height: size_10_h,
                    );
                  },
                  itemCount: suggestionList.length),
        )
      ],
    );
  }

  Widget suggestion(List<UserModel> suggestionList) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(size_15_h),
            child: Text(
              "Suggestion",
              style: subtitle.copyWith(fontSize: size_16_sp),
            ),
          ),
        ),
        SliverFillRemaining(
          child: suggestionList.isEmpty ? const Center(child: Text(""),) : ListView.separated(
              itemBuilder: (_, index) {
                return ListTile(
                  onTap: () {
                    context.router.pop();
                    context.router.push(ChatScreenRoute(
                        userModel: suggestionList[index], chatID: ""));
                  },
                  leading:
                      CustomCircleAvatarStatus(user: suggestionList[index]),
                  contentPadding: EdgeInsets.zero,
                  title: Text(suggestionList[index].fullName),
                );
              },
              separatorBuilder: (_, index) {
                return SizedBox(
                  height: size_10_h,
                );
              },
              itemCount: suggestionList.length),
        )
      ],
    );
  }
}
