import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetInitialRoute extends AutoRouteGuard {

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async{
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      router.replaceNamed('/login-screen');
    } else {
      resolver.next(true);
    }
  }
}