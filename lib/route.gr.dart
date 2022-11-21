// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i13;
import 'package:flutter/cupertino.dart' as _i16;
import 'package:flutter/material.dart' as _i14;
import 'package:image_picker/image_picker.dart' as _i18;

import 'data/model/user.dart' as _i17;
import 'initial_route.dart' as _i15;
import 'screens/call/call_page.dart' as _i11;
import 'screens/chat/chat_screen.dart' as _i4;
import 'screens/dashboard/dashboard_page.dart' as _i2;
import 'screens/home/home.dart' as _i9;
import 'screens/login/login_screen.dart' as _i1;
import 'screens/message/message_page.dart' as _i10;
import 'screens/new_posts/new_posts.dart' as _i3;
import 'screens/people/people_screen.dart' as _i12;
import 'screens/register/register_screen.dart' as _i8;
import 'screens/search/search.dart' as _i6;
import 'screens/settings/settings.dart' as _i5;
import 'screens/welcome/welcome_screen.dart' as _i7;

class AppRouter extends _i13.RootStackRouter {
  AppRouter({
    _i14.GlobalKey<_i14.NavigatorState>? navigatorKey,
    required this.getInitialRoute,
  }) : super(navigatorKey);

  final _i15.GetInitialRoute getInitialRoute;

  @override
  final Map<String, _i13.PageFactory> pagesMap = {
    LoginScreenRoute.name: (routeData) {
      return _i13.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i13.WrappedRoute(child: const _i1.LoginScreen()),
      );
    },
    DashboardPageRoute.name: (routeData) {
      return _i13.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.DashboardPage(),
      );
    },
    NewPostsPageRoute.name: (routeData) {
      final args = routeData.argsAs<NewPostsPageRouteArgs>();
      return _i13.CustomPage<dynamic>(
        routeData: routeData,
        child: _i13.WrappedRoute(
            child: _i3.NewPostsPage(
          key: args.key,
          user: args.user,
          xFile: args.xFile,
          type: args.type,
        )),
        transitionsBuilder: _i13.TransitionsBuilders.slideBottom,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ChatScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ChatScreenRouteArgs>();
      return _i13.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i13.WrappedRoute(
            child: _i4.ChatScreen(
          key: args.key,
          userModel: args.userModel,
          chatID: args.chatID,
        )),
      );
    },
    SettingPageRoute.name: (routeData) {
      return _i13.CustomPage<dynamic>(
        routeData: routeData,
        child: _i13.WrappedRoute(child: const _i5.SettingPage()),
        transitionsBuilder: _i13.TransitionsBuilders.slideTop,
        opaque: true,
        barrierDismissible: false,
      );
    },
    SearchPageRoute.name: (routeData) {
      return _i13.CustomPage<dynamic>(
        routeData: routeData,
        child: _i13.WrappedRoute(child: const _i6.SearchPage()),
        transitionsBuilder: _i13.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    WelcomeScreenRoute.name: (routeData) {
      return _i13.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.WelcomeScreen(),
      );
    },
    RegisterScreenRoute.name: (routeData) {
      return _i13.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i13.WrappedRoute(child: const _i8.RegisterScreen()),
      );
    },
    HomePageRoute.name: (routeData) {
      return _i13.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i13.WrappedRoute(child: const _i9.HomePage()),
      );
    },
    MessagePageRoute.name: (routeData) {
      return _i13.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i13.WrappedRoute(child: const _i10.MessagePage()),
      );
    },
    CallPageRoute.name: (routeData) {
      return _i13.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i11.CallPage(),
      );
    },
    PeopleScreenRoute.name: (routeData) {
      return _i13.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i13.WrappedRoute(child: const _i12.PeopleScreen()),
      );
    },
  };

  @override
  List<_i13.RouteConfig> get routes => [
        _i13.RouteConfig(
          LoginScreenRoute.name,
          path: '/login-screen',
        ),
        _i13.RouteConfig(
          DashboardPageRoute.name,
          path: '/',
          guards: [getInitialRoute],
          children: [
            _i13.RouteConfig(
              HomePageRoute.name,
              path: 'home-page',
              parent: DashboardPageRoute.name,
            ),
            _i13.RouteConfig(
              MessagePageRoute.name,
              path: 'message-page',
              parent: DashboardPageRoute.name,
            ),
            _i13.RouteConfig(
              CallPageRoute.name,
              path: 'call-page',
              parent: DashboardPageRoute.name,
            ),
            _i13.RouteConfig(
              PeopleScreenRoute.name,
              path: 'people-screen',
              parent: DashboardPageRoute.name,
            ),
          ],
        ),
        _i13.RouteConfig(
          NewPostsPageRoute.name,
          path: '/new-posts-page',
        ),
        _i13.RouteConfig(
          ChatScreenRoute.name,
          path: '/chat-screen',
        ),
        _i13.RouteConfig(
          SettingPageRoute.name,
          path: '/setting-page',
        ),
        _i13.RouteConfig(
          SearchPageRoute.name,
          path: '/search-page',
        ),
        _i13.RouteConfig(
          WelcomeScreenRoute.name,
          path: '/welcome-screen',
        ),
        _i13.RouteConfig(
          RegisterScreenRoute.name,
          path: '/register-screen',
        ),
      ];
}

/// generated route for
/// [_i1.LoginScreen]
class LoginScreenRoute extends _i13.PageRouteInfo<void> {
  const LoginScreenRoute()
      : super(
          LoginScreenRoute.name,
          path: '/login-screen',
        );

  static const String name = 'LoginScreenRoute';
}

/// generated route for
/// [_i2.DashboardPage]
class DashboardPageRoute extends _i13.PageRouteInfo<void> {
  const DashboardPageRoute({List<_i13.PageRouteInfo>? children})
      : super(
          DashboardPageRoute.name,
          path: '/',
          initialChildren: children,
        );

  static const String name = 'DashboardPageRoute';
}

/// generated route for
/// [_i3.NewPostsPage]
class NewPostsPageRoute extends _i13.PageRouteInfo<NewPostsPageRouteArgs> {
  NewPostsPageRoute({
    _i16.Key? key,
    required _i17.UserModel user,
    _i18.XFile? xFile,
    String? type,
  }) : super(
          NewPostsPageRoute.name,
          path: '/new-posts-page',
          args: NewPostsPageRouteArgs(
            key: key,
            user: user,
            xFile: xFile,
            type: type,
          ),
        );

  static const String name = 'NewPostsPageRoute';
}

class NewPostsPageRouteArgs {
  const NewPostsPageRouteArgs({
    this.key,
    required this.user,
    this.xFile,
    this.type,
  });

  final _i16.Key? key;

  final _i17.UserModel user;

  final _i18.XFile? xFile;

  final String? type;

  @override
  String toString() {
    return 'NewPostsPageRouteArgs{key: $key, user: $user, xFile: $xFile, type: $type}';
  }
}

/// generated route for
/// [_i4.ChatScreen]
class ChatScreenRoute extends _i13.PageRouteInfo<ChatScreenRouteArgs> {
  ChatScreenRoute({
    _i16.Key? key,
    required _i17.UserModel userModel,
    required String chatID,
  }) : super(
          ChatScreenRoute.name,
          path: '/chat-screen',
          args: ChatScreenRouteArgs(
            key: key,
            userModel: userModel,
            chatID: chatID,
          ),
        );

  static const String name = 'ChatScreenRoute';
}

class ChatScreenRouteArgs {
  const ChatScreenRouteArgs({
    this.key,
    required this.userModel,
    required this.chatID,
  });

  final _i16.Key? key;

  final _i17.UserModel userModel;

  final String chatID;

  @override
  String toString() {
    return 'ChatScreenRouteArgs{key: $key, userModel: $userModel, chatID: $chatID}';
  }
}

/// generated route for
/// [_i5.SettingPage]
class SettingPageRoute extends _i13.PageRouteInfo<void> {
  const SettingPageRoute()
      : super(
          SettingPageRoute.name,
          path: '/setting-page',
        );

  static const String name = 'SettingPageRoute';
}

/// generated route for
/// [_i6.SearchPage]
class SearchPageRoute extends _i13.PageRouteInfo<void> {
  const SearchPageRoute()
      : super(
          SearchPageRoute.name,
          path: '/search-page',
        );

  static const String name = 'SearchPageRoute';
}

/// generated route for
/// [_i7.WelcomeScreen]
class WelcomeScreenRoute extends _i13.PageRouteInfo<void> {
  const WelcomeScreenRoute()
      : super(
          WelcomeScreenRoute.name,
          path: '/welcome-screen',
        );

  static const String name = 'WelcomeScreenRoute';
}

/// generated route for
/// [_i8.RegisterScreen]
class RegisterScreenRoute extends _i13.PageRouteInfo<void> {
  const RegisterScreenRoute()
      : super(
          RegisterScreenRoute.name,
          path: '/register-screen',
        );

  static const String name = 'RegisterScreenRoute';
}

/// generated route for
/// [_i9.HomePage]
class HomePageRoute extends _i13.PageRouteInfo<void> {
  const HomePageRoute()
      : super(
          HomePageRoute.name,
          path: 'home-page',
        );

  static const String name = 'HomePageRoute';
}

/// generated route for
/// [_i10.MessagePage]
class MessagePageRoute extends _i13.PageRouteInfo<void> {
  const MessagePageRoute()
      : super(
          MessagePageRoute.name,
          path: 'message-page',
        );

  static const String name = 'MessagePageRoute';
}

/// generated route for
/// [_i11.CallPage]
class CallPageRoute extends _i13.PageRouteInfo<void> {
  const CallPageRoute()
      : super(
          CallPageRoute.name,
          path: 'call-page',
        );

  static const String name = 'CallPageRoute';
}

/// generated route for
/// [_i12.PeopleScreen]
class PeopleScreenRoute extends _i13.PageRouteInfo<void> {
  const PeopleScreenRoute()
      : super(
          PeopleScreenRoute.name,
          path: 'people-screen',
        );

  static const String name = 'PeopleScreenRoute';
}
