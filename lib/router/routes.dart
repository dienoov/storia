sealed class StoriaRoute {}

final class LoginRoute extends StoriaRoute {}

final class RegisterRoute extends StoriaRoute {}

final class HomeRoute extends StoriaRoute {}

final class StoryRoute extends StoriaRoute {
  final String? id;

  StoryRoute(this.id);
}

final class UploadRoute extends StoriaRoute {}
