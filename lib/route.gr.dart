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
import 'package:auto_route/auto_route.dart' as _i15;
import 'package:flutter/cupertino.dart' as _i18;
import 'package:flutter/material.dart' as _i16;
import 'package:image_picker/image_picker.dart' as _i21;

import 'bloc/notification/notification.dart' as _i13;
import 'data/model/like.dart' as _i20;
import 'data/model/user.dart' as _i19;
import 'initial_route.dart' as _i17;
import 'screens/chat/chat_screen.dart' as _i6;
import 'screens/dashboard/dashboard_page.dart' as _i2;
import 'screens/home/home.dart' as _i11;
import 'screens/like/like_page.dart' as _i4;
import 'screens/login/login_screen.dart' as _i1;
import 'screens/message/message_page.dart' as _i12;
import 'screens/new_posts/new_posts.dart' as _i5;
import 'screens/people/people_screen.dart' as _i14;
import 'screens/profile/profile.dart' as _i3;
import 'screens/register/register_screen.dart' as _i10;
import 'screens/search/search.dart' as _i8;
import 'screens/settings/settings.dart' as _i7;
import 'screens/welcome/welcome_screen.dart' as _i9;

class AppRouter extends _i15.RootStackRouter {
  AppRouter({
    _i16.GlobalKey<_i16.NavigatorState>? navigatorKey,
    required this.getInitialRoute,
  }) : super(navigatorKey);

  final _i17.GetInitialRoute getInitialRoute;

  @override
  final Map<String, _i15.PageFactory> pagesMap = {
    LoginScreenRoute.name: (routeData) {
      return _i15.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i15.WrappedRoute(child: const _i1.LoginScreen()),
      );
    },
    DashboardPageRoute.name: (routeData) {
      return _i15.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.DashboardPage(),
      );
    },
    ProfilePageRoute.name: (routeData) {
      final args = routeData.argsAs<ProfilePageRouteArgs>();
      return _i15.CustomPage<dynamic>(
        routeData: routeData,
        child: _i15.WrappedRoute(
            child: _i3.ProfilePage(
          key: args.key,
          currentUser: args.currentUser,
          user: args.user,
        )),
        transitionsBuilder: _i15.TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    LikePageRoute.name: (routeData) {
      final args = routeData.argsAs<LikePageRouteArgs>();
      return _i15.CustomPage<dynamic>(
        routeData: routeData,
        child: _i4.LikePage(
          key: args.key,
          list: args.list,
          user: args.user,
        ),
        transitionsBuilder: _i15.TransitionsBuilders.slideLeft,
        opaque: true,
        barrierDismissible: false,
      );
    },
    NewPostsPageRoute.name: (routeData) {
      final args = routeData.argsAs<NewPostsPageRouteArgs>();
      return _i15.CustomPage<dynamic>(
        routeData: routeData,
        child: _i15.WrappedRoute(
            child: _i5.NewPostsPage(
          key: args.key,
          user: args.user,
          xFile: args.xFile,
          type: args.type,
        )),
        transitionsBuilder: _i15.TransitionsBuilders.slideBottom,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ChatScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ChatScreenRouteArgs>();
      return _i15.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i15.WrappedRoute(
            child: _i6.ChatScreen(
          key: args.key,
          userModel: args.userModel,
          chatID: args.chatID,
        )),
      );
    },
    SettingPageRoute.name: (routeData) {
      return _i15.CustomPage<dynamic>(
        routeData: routeData,
        child: _i15.WrappedRoute(child: const _i7.SettingPage()),
        transitionsBuilder: _i15.TransitionsBuilders.slideTop,
        opaque: true,
        barrierDismissible: false,
      );
    },
    SearchPageRoute.name: (routeData) {
      final args = routeData.argsAs<SearchPageRouteArgs>();
      return _i15.CustomPage<dynamic>(
        routeData: routeData,
        child: _i15.WrappedRoute(
            child: _i8.SearchPage(
          from: args.from,
          key: args.key,
        )),
        transitionsBuilder: _i15.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    WelcomeScreenRoute.name: (routeData) {
      return _i15.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i9.WelcomeScreen(),
      );
    },
    RegisterScreenRoute.name: (routeData) {
      return _i15.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i15.WrappedRoute(child: const _i10.RegisterScreen()),
      );
    },
    HomePageRoute.name: (routeData) {
      return _i15.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i15.WrappedRoute(child: const _i11.HomePage()),
      );
    },
    MessagePageRoute.name: (routeData) {
      return _i15.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i15.WrappedRoute(child: const _i12.MessagePage()),
      );
    },
    NotificationPageRoute.name: (routeData) {
      return _i15.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i13.NotificationPage(),
      );
    },
    PeopleScreenRoute.name: (routeData) {
      return _i15.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i15.WrappedRoute(child: const _i14.PeopleScreen()),
      );
    },
  };

  @override
  List<_i15.RouteConfig> get routes => [
        _i15.RouteConfig(
          LoginScreenRoute.name,
          path: '/login-screen',
        ),
        _i15.RouteConfig(
          DashboardPageRoute.name,
          path: '/',
          guards: [getInitialRoute],
          children: [
            _i15.RouteConfig(
              HomePageRoute.name,
              path: 'home-page',
              parent: DashboardPageRoute.name,
            ),
            _i15.RouteConfig(
              MessagePageRoute.name,
              path: 'message-page',
              parent: DashboardPageRoute.name,
            ),
            _i15.RouteConfig(
              NotificationPageRoute.name,
              path: 'notification-page',
              parent: DashboardPageRoute.name,
            ),
            _i15.RouteConfig(
              PeopleScreenRoute.name,
              path: 'people-screen',
              parent: DashboardPageRoute.name,
            ),
          ],
        ),
        _i15.RouteConfig(
          ProfilePageRoute.name,
          path: '/profile-page',
        ),
        _i15.RouteConfig(
          LikePageRoute.name,
          path: '/like-page',
        ),
        _i15.RouteConfig(
          NewPostsPageRoute.name,
          path: '/new-posts-page',
        ),
        _i15.RouteConfig(
          ChatScreenRoute.name,
          path: '/chat-screen',
        ),
        _i15.RouteConfig(
          SettingPageRoute.name,
          path: '/setting-page',
        ),
        _i15.RouteConfig(
          SearchPageRoute.name,
          path: '/search-page',
        ),
        _i15.RouteConfig(
          WelcomeScreenRoute.name,
          path: '/welcome-screen',
        ),
        _i15.RouteConfig(
          RegisterScreenRoute.name,
          path: '/register-screen',
        ),
      ];
}

/// generated route for
/// [_i1.LoginScreen]
class LoginScreenRoute extends _i15.PageRouteInfo<void> {
  const LoginScreenRoute()
      : super(
          LoginScreenRoute.name,
          path: '/login-screen',
        );

  static const String name = 'LoginScreenRoute';
}

/// generated route for
/// [_i2.DashboardPage]
class DashboardPageRoute extends _i15.PageRouteInfo<void> {
  const DashboardPageRoute({List<_i15.PageRouteInfo>? children})
      : super(
          DashboardPageRoute.name,
          path: '/',
          initialChildren: children,
        );

  static const String name = 'DashboardPageRoute';
}

/// generated route for
/// [_i3.ProfilePage]
class ProfilePageRoute extends _i15.PageRouteInfo<ProfilePageRouteArgs> {
  ProfilePageRoute({
    _i18.Key? key,
    required _i19.UserModel currentUser,
    required _i19.UserModel user,
  }) : super(
          ProfilePageRoute.name,
          path: '/profile-page',
          args: ProfilePageRouteArgs(
            key: key,
            currentUser: currentUser,
            user: user,
          ),
        );

  static const String name = 'ProfilePageRoute';
}

class ProfilePageRouteArgs {
  const ProfilePageRouteArgs({
    this.key,
    required this.currentUser,
    required this.user,
  });

  final _i18.Key? key;

  final _i19.UserModel currentUser;

  final _i19.UserModel user;

  @override
  String toString() {
    return 'ProfilePageRouteArgs{key: $key, currentUser: $currentUser, user: $user}';
  }
}

/// generated route for
/// [_i4.LikePage]
class LikePageRoute extends _i15.PageRouteInfo<LikePageRouteArgs> {
  LikePageRoute({
    _i18.Key? key,
    required List<_i20.Likes> list,
    required _i19.UserModel user,
  }) : super(
          LikePageRoute.name,
          path: '/like-page',
          args: LikePageRouteArgs(
            key: key,
            list: list,
            user: user,
          ),
        );

  static const String name = 'LikePageRoute';
}

class LikePageRouteArgs {
  const LikePageRouteArgs({
    this.key,
    required this.list,
    required this.user,
  });

  final _i18.Key? key;

  final List<_i20.Likes> list;

  final _i19.UserModel user;

  @override
  String toString() {
    return 'LikePageRouteArgs{key: $key, list: $list, user: $user}';
  }
}

/// generated route for
/// [_i5.NewPostsPage]
class NewPostsPageRoute extends _i15.PageRouteInfo<NewPostsPageRouteArgs> {
  NewPostsPageRoute({
    _i18.Key? key,
    required _i19.UserModel user,
    _i21.XFile? xFile,
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

  final _i18.Key? key;

  final _i19.UserModel user;

  final _i21.XFile? xFile;

  final String? type;

  @override
  String toString() {
    return 'NewPostsPageRouteArgs{key: $key, user: $user, xFile: $xFile, type: $type}';
  }
}

/// generated route for
/// [_i6.ChatScreen]
class ChatScreenRoute extends _i15.PageRouteInfo<ChatScreenRouteArgs> {
  ChatScreenRoute({
    _i18.Key? key,
    required _i19.UserModel userModel,
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

  final _i18.Key? key;

  final _i19.UserModel userModel;

  final String chatID;

  @override
  String toString() {
    return 'ChatScreenRouteArgs{key: $key, userModel: $userModel, chatID: $chatID}';
  }
}

/// generated route for
/// [_i7.SettingPage]
class SettingPageRoute extends _i15.PageRouteInfo<void> {
  const SettingPageRoute()
      : super(
          SettingPageRoute.name,
          path: '/setting-page',
        );

  static const String name = 'SettingPageRoute';
}

/// generated route for
/// [_i8.SearchPage]
class SearchPageRoute extends _i15.PageRouteInfo<SearchPageRouteArgs> {
  SearchPageRoute({
    required String from,
    _i18.Key? key,
  }) : super(
          SearchPageRoute.name,
          path: '/search-page',
          args: SearchPageRouteArgs(
            from: from,
            key: key,
          ),
        );

  static const String name = 'SearchPageRoute';
}

class SearchPageRouteArgs {
  const SearchPageRouteArgs({
    required this.from,
    this.key,
  });

  final String from;

  final _i18.Key? key;

  @override
  String toString() {
    return 'SearchPageRouteArgs{from: $from, key: $key}';
  }
}

/// generated route for
/// [_i9.WelcomeScreen]
class WelcomeScreenRoute extends _i15.PageRouteInfo<void> {
  const WelcomeScreenRoute()
      : super(
          WelcomeScreenRoute.name,
          path: '/welcome-screen',
        );

  static const String name = 'WelcomeScreenRoute';
}

/// generated route for
/// [_i10.RegisterScreen]
class RegisterScreenRoute extends _i15.PageRouteInfo<void> {
  const RegisterScreenRoute()
      : super(
          RegisterScreenRoute.name,
          path: '/register-screen',
        );

  static const String name = 'RegisterScreenRoute';
}

/// generated route for
/// [_i11.HomePage]
class HomePageRoute extends _i15.PageRouteInfo<void> {
  const HomePageRoute()
      : super(
          HomePageRoute.name,
          path: 'home-page',
        );

  static const String name = 'HomePageRoute';
}

/// generated route for
/// [_i12.MessagePage]
class MessagePageRoute extends _i15.PageRouteInfo<void> {
  const MessagePageRoute()
      : super(
          MessagePageRoute.name,
          path: 'message-page',
        );

  static const String name = 'MessagePageRoute';
}

/// generated route for
/// [_i13.NotificationPage]
class NotificationPageRoute extends _i15.PageRouteInfo<void> {
  const NotificationPageRoute()
      : super(
          NotificationPageRoute.name,
          path: 'notification-page',
        );

  static const String name = 'NotificationPageRoute';
}

/// generated route for
/// [_i14.PeopleScreen]
class PeopleScreenRoute extends _i15.PageRouteInfo<void> {
  const PeopleScreenRoute()
      : super(
          PeopleScreenRoute.name,
          path: 'people-screen',
        );

  static const String name = 'PeopleScreenRoute';
}
