import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:chat/screens/call/call_page.dart';
import 'package:chat/screens/chat/chat_screen.dart';
import 'package:chat/screens/dashboard/dashboard_page.dart';
import 'package:chat/screens/login/login_screen.dart';
import 'package:chat/screens/message/message_page.dart';
import 'package:chat/screens/people/people_screen.dart';
import 'package:chat/screens/register/register_screen.dart';
import 'package:chat/screens/search/search.dart';
import 'package:chat/screens/settings/settings.dart';
import 'package:chat/screens/welcome/welcome_screen.dart';

import 'initial_route.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(page: LoginScreen),
    AutoRoute(
      path: "/",
      page: DashboardPage,
      guards: [GetInitialRoute],
      children: [
        AutoRoute(page: MessagePage),
        AutoRoute(page: CallPage),
        AutoRoute(page: PeopleScreen)
      ],
    ),
    AutoRoute(page: ChatScreen),
    CustomRoute(page: SettingPage, children: [

    ],
        transitionsBuilder: TransitionsBuilders.slideTop
    ),
    CustomRoute(
        page: SearchPage, transitionsBuilder: TransitionsBuilders.fadeIn),
    AutoRoute(page: WelcomeScreen),
    AutoRoute(page: RegisterScreen)
  ],
)
// extend the generated private router
class $AppRouter {}
