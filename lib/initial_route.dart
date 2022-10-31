import 'package:auto_route/auto_route.dart';
import 'package:hive/hive.dart';

class GetInitialRoute extends AutoRouteGuard {

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async{
    // var user = FirebaseAuth.instance.currentUser;
    var box = await Hive.openBox("box");
    if (box.isEmpty) {
      router.replaceNamed('/login-screen');
    } else {
      resolver.next(true);
    }
  }
}