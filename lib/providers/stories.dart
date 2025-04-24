import 'package:flutter/material.dart';
import 'package:storia/apis/stories.dart';
import 'package:storia/providers/state.dart';

class StoriesProvider extends ChangeNotifier {
  late StoriesApi _storiesApi;

  set token(String token) {
    _storiesApi = StoriesApi(token);
  }

  ProviderState _state = NoneState();

  ProviderState get state => _state;

  Future<void> all() async {
    _state = LoadingState();
    notifyListeners();

    try {
      _state = LoadedState(await _storiesApi.all());
    } catch (e) {
      _state = ErrorState(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
