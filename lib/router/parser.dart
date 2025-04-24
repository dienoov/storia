import 'package:flutter/material.dart';
import 'package:storia/router/routes.dart';

class StoriaRouteParser extends RouteInformationParser<StoriaRoute> {
  @override
  Future<StoriaRoute> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = Uri.parse(routeInformation.uri.toString());

    if (uri.pathSegments.isNotEmpty) {
      switch (uri.pathSegments[0].toLowerCase()) {
        case 'login':
          return LoginRoute();
        case 'register':
          return RegisterRoute();
        case 'story':
          if (uri.pathSegments.length == 2) {
            return StoryRoute(uri.pathSegments[1]);
          }
        case 'upload':
          return UploadRoute();
      }
    }

    return HomeRoute();
  }

  @override
  RouteInformation? restoreRouteInformation(StoriaRoute configuration) {
    return switch (configuration) {
      LoginRoute() => RouteInformation(uri: Uri.parse("/login")),
      RegisterRoute() => RouteInformation(uri: Uri.parse("/register")),
      StoryRoute() => RouteInformation(
        uri: Uri.parse("/story/${configuration.id}"),
      ),
      UploadRoute() => RouteInformation(uri: Uri.parse("/upload")),
      _ => RouteInformation(uri: Uri.parse("/")),
    };
  }
}
