import 'package:chat/bloc/global_cubit.dart';
import 'package:chat/initial_route.dart';
import 'package:chat/route.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final key = GlobalKey();

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final appRouter = AppRouter(getInitialRoute: GetInitialRoute());

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      key: key,
      designSize: const Size(414, 896),
      builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          onTap: () {
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          },
          child: BlocProvider(
            create: (context) => GlobalCubit(),
            child: MaterialApp.router(
              builder: EasyLoading.init(),
              routerDelegate: appRouter.delegate(),
              routeInformationParser: appRouter.defaultRouteParser(),
            ),
          ),
        );
      },
    );
  }
}
