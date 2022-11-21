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
import 'package:auto_route/auto_route.dart' as _i11;
import 'package:flutter/cupertino.dart' as _i14;
import 'package:flutter/material.dart' as _i12;

import 'data/model/user.dart' as _i15;
import 'initial_route.dart' as _i13;
import 'screens/call/call_page.dart' as _i9;
import 'screens/chat/chat_screen.dart' as _i3;
import 'screens/dashboard/dashboard_page.dart' as _i2;
import 'screens/login/login_screen.dart' as _i1;
import 'screens/message/message_page.dart' as _i8;
import 'screens/people/people_screen.dart' as _i10;
import 'screens/register/register_screen.dart' as _i7;
import 'screens/search/search.dart' as _i5;
import 'screens/settings/settings.dart' as _i4;
import 'screens/welcome/welcome_screen.dart' as _i6;

class AppRouter extends _i11.RootStackRouter {
  AppRouter({
    _i12.GlobalKey<_i12.NavigatorState>? navigatorKey,
    required this.getInitialRoute,
  }) : super(navigatorKey);

  final _i13.GetInitialRoute getInitialRoute;

  @override
  final Map<String, _i11.PageFactory> pagesMap = {
    LoginScreenRoute.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i11.WrappedRoute(child: const _i1.LoginScreen()),
      );
    },
    DashboardPageRoute.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.DashboardPage(),
      );
    },
    ChatScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ChatScreenRouteArgs>();
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i11.WrappedRoute(
            child: _i3.ChatScreen(
          key: args.key,
          userModel: args.userModel,
          chatID: args.chatID,
        )),
      );
    },
    SettingPageRoute.name: (routeData) {
      return _i11.CustomPage<dynamic>(
        routeData: routeData,
        child: _i11.WrappedRoute(child: const _i4.SettingPage()),
        transitionsBuilder: _i11.TransitionsBuilders.slideTop,
        opaque: true,
        barrierDismissible: false,
      );
    },
    SearchPageRoute.name: (routeData) {
      return _i11.CustomPage<dynamic>(
        routeData: routeData,
        child: _i11.WrappedRoute(child: const _i5.SearchPage()),
        transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    WelcomeScreenRoute.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.WelcomeScreen(),
      );
    },
    RegisterScreenRoute.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i11.WrappedRoute(child: const _i7.RegisterScreen()),
      );
    },
    MessagePageRoute.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i11.WrappedRoute(child: const _i8.MessagePage()),
      );
    },
    CallPageRoute.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i9.CallPage(),
      );
    },
    PeopleScreenRoute.name: (routeData) {
      return _i11.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i11.WrappedRoute(child: const _i10.PeopleScreen()),
      );
    },
  };

  @override
  List<_i11.RouteConfig> get routes => [
        _i11.RouteConfig(
          LoginScreenRoute.name,
          path: '/login-screen',
        ),
        _i11.RouteConfig(
          DashboardPageRoute.name,
          path: '/',
          guards: [getInitialRoute],
          children: [
            _i11.RouteConfig(
              MessagePageRoute.name,
              path: 'message-page',
              parent: DashboardPageRoute.name,
            ),
            _i11.RouteConfig(
              CallPageRoute.name,
              path: 'call-page',
              parent: DashboardPageRoute.name,
            ),
            _i11.RouteConfig(
              PeopleScreenRoute.name,
              path: 'people-screen',
              parent: DashboardPageRoute.name,
            ),
          ],
        ),
        _i11.RouteConfig(
          ChatScreenRoute.name,
          path: '/chat-screen',
        ),
        _i11.RouteConfig(
          SettingPageRoute.name,
          path: '/setting-page',
        ),
        _i11.RouteConfig(
          SearchPageRoute.name,
          path: '/search-page',
        ),
        _i11.RouteConfig(
          WelcomeScreenRoute.name,
          path: '/welcome-screen',
        ),
        _i11.RouteConfig(
          RegisterScreenRoute.name,
          path: '/register-screen',
        ),
      ];
}

/// generated route for
/// [_i1.LoginScreen]
class LoginScreenRoute extends _i11.PageRouteInfo<void> {
  const LoginScreenRoute()
      : super(
          LoginScreenRoute.name,
          path: '/login-screen',
        );

  static const String name = 'LoginScreenRoute';
}

/// generated route for
/// [_i2.DashboardPage]
class DashboardPageRoute extends _i11.PageRouteInfo<void> {
  const DashboardPageRoute({List<_i11.PageRouteInfo>? children})
      : super(
          DashboardPageRoute.name,
          path: '/',
          initialChildren: children,
        );

  static const String name = 'DashboardPageRoute';
}

/// generated route for
/// [_i3.ChatScreen]
class ChatScreenRoute extends _i11.PageRouteInfo<ChatScreenRouteArgs> {
  ChatScreenRoute({
    _i14.Key? key,
    required _i15.UserModel userModel,
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

  final _i14.Key? key;

  final _i15.UserModel userModel;

  final String chatID;

  @override
  String toString() {
    return 'ChatScreenRouteArgs{key: $key, userModel: $userModel, chatID: $chatID}';
  }
}

/// generated route for
/// [_i4.SettingPage]
class SettingPageRoute extends _i11.PageRouteInfo<void> {
  const SettingPageRoute()
      : super(
          SettingPageRoute.name,
          path: '/setting-page',
        );

  static const String name = 'SettingPageRoute';
}

/// generated route for
/// [_i5.SearchPage]
class SearchPageRoute extends _i11.PageRouteInfo<void> {
  const SearchPageRoute()
      : super(
          SearchPageRoute.name,
          path: '/search-page',
        );

  static const String name = 'SearchPageRoute';
}

/// generated route for
/// [_i6.WelcomeScreen]
class WelcomeScreenRoute extends _i11.PageRouteInfo<void> {
  const WelcomeScreenRoute()
      : super(
          WelcomeScreenRoute.name,
          path: '/welcome-screen',
        );

  static const String name = 'WelcomeScreenRoute';
}

/// generated route for
/// [_i7.RegisterScreen]
class RegisterScreenRoute extends _i11.PageRouteInfo<void> {
  const RegisterScreenRoute()
      : super(
          RegisterScreenRoute.name,
          path: '/register-screen',
        );

  static const String name = 'RegisterScreenRoute';
}

/// generated route for
/// [_i8.MessagePage]
class MessagePageRoute extends _i11.PageRouteInfo<void> {
  const MessagePageRoute()
      : super(
          MessagePageRoute.name,
          path: 'message-page',
        );

  static const String name = 'MessagePageRoute';
}

/// generated route for
/// [_i9.CallPage]
class CallPageRoute extends _i11.PageRouteInfo<void> {
  const CallPageRoute()
      : super(
          CallPageRoute.name,
          path: 'call-page',
        );

  static const String name = 'CallPageRoute';
}

/// generated route for
/// [_i10.PeopleScreen]
class PeopleScreenRoute extends _i11.PageRouteInfo<void> {
  const PeopleScreenRoute()
      : super(
          PeopleScreenRoute.name,
          path: 'people-screen',
        );

  static const String name = 'PeopleScreenRoute';
}
