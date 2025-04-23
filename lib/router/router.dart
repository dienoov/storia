import 'package:flutter/material.dart';
import 'package:storia/models/user.dart';
import 'package:storia/repositories/auth.dart';
import 'package:storia/router/routes.dart';
import 'package:storia/screens/home.dart';
import 'package:storia/screens/login.dart';
import 'package:storia/screens/register.dart';
import 'package:storia/screens/story.dart';

class StoriaRouter extends RouterDelegate<StoriaRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;
  final AuthRepository authRepository;

  StoriaRouter(this.authRepository)
    : _navigatorKey = GlobalKey<NavigatorState>() {
    load();
  }

  Future<void> load() async {
    user = await authRepository.user();
    notifyListeners();
  }

  List<Page> pages = [];

  User? user;

  bool hasAccount = true;
  String? story;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      pages = [
        MaterialPage(
          key: const ValueKey("LoginPage"),
          child: LoginScreen(
            toRegister: () {
              hasAccount = false;
              notifyListeners();
            },
            refresh: load,
          ),
        ),
        if (!hasAccount)
          MaterialPage(
            key: const ValueKey("RegisterPage"),
            child: RegisterScreen(
              toLogin: () {
                hasAccount = true;
                notifyListeners();
              },
              refresh: load,
            ),
          ),
      ];
    } else {
      pages = [
        MaterialPage(
          key: const ValueKey("HomePage"),
          child: HomeScreen(
            token: user!.token,
            toStory: (String id) {
              story = id;
              notifyListeners();
            },
          ),
        ),
        if (story != null)
          MaterialPage(
            key: ValueKey("StoryPage-$story"),
            child: StoryScreen(token: user!.token, id: story!),
          ),
      ];
    }

    return Navigator(
      pages: pages,
      onDidRemovePage: (page) {
        if (page is MaterialPage) {
          if (page.child is StoryScreen) {
            story = null;
          }
        }
        notifyListeners();
      },
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  @override
  Future<void> setNewRoutePath(StoriaRoute configuration) async {
    switch (configuration) {
      case RegisterRoute():
        hasAccount = false;
        break;
      case LoginRoute():
        hasAccount = true;
        break;
      case HomeRoute():
        story = null;
        break;
      case StoryRoute():
        story = configuration.id.toString();
        break;
    }
    notifyListeners();
  }

  @override
  StoriaRoute? get currentConfiguration {
    if (user == null) {
      return hasAccount ? LoginRoute() : RegisterRoute();
    }

    if (user != null) {
      return story != null ? StoryRoute(story!) : HomeRoute();
    }

    return null;
  }
}
