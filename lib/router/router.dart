import 'package:flutter/material.dart';
import 'package:storia/models/user.dart';
import 'package:storia/repositories/auth.dart';
import 'package:storia/router/routes.dart';
import 'package:storia/screens/home.dart';
import 'package:storia/screens/login.dart';
import 'package:storia/screens/register.dart';
import 'package:storia/screens/story.dart';
import 'package:storia/screens/upload.dart';

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
  String? story;

  bool hasAccount = true;
  bool isUploading = false;

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
            user: user!,
            toStory: (String id) {
              story = id;
              notifyListeners();
            },
            refresh: load,
            toUpload: () {
              isUploading = true;
              notifyListeners();
            },
          ),
        ),
        if (story != null)
          MaterialPage(
            key: ValueKey("StoryPage-$story"),
            child: StoryScreen(user: user!, id: story!, refresh: load),
          ),
        if (isUploading)
          MaterialPage(
            key: const ValueKey("StoryPage"),
            child: UploadScreen(
              user: user!,
              refresh: load,
              toHome: () {
                isUploading = false;
                notifyListeners();
              },
            ),
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
          if (page.child is UploadScreen) {
            isUploading = false;
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
    story = null;
    hasAccount = true;
    isUploading = false;

    switch (configuration) {
      case RegisterRoute():
        hasAccount = false;
        break;
      case StoryRoute():
        story = configuration.id.toString();
        break;
      case UploadRoute():
        isUploading = true;
        break;
      default:
    }
    notifyListeners();
  }

  @override
  StoriaRoute? get currentConfiguration {
    if (user == null) {
      return hasAccount ? LoginRoute() : RegisterRoute();
    }

    if (user != null) {
      if (isUploading) {
        return UploadRoute();
      }

      return story != null ? StoryRoute(story!) : HomeRoute();
    }

    return null;
  }
}
