sealed class ProviderState {}

class NoneState extends ProviderState {}

class LoadingState extends ProviderState {}

class ErrorState extends ProviderState {
  final String error;

  ErrorState(this.error);
}

class LoadedState extends ProviderState {
  final dynamic data;

  LoadedState(this.data);
}
