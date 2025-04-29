import 'package:flutter/material.dart';
import 'package:storia/apis/stories.dart';
import 'package:storia/models/story.dart';
import 'package:storia/providers/state.dart';

class StoriesProvider extends ChangeNotifier {
  late StoriesApi _storiesApi;

  set token(String token) {
    _storiesApi = StoriesApi(token);
  }

  ProviderState _state = NoneState();

  ProviderState get state => _state;

  int page = 1;
  bool isLast = false;

  List<Story> stories = [];

  Future<void> init() async {
    _state = LoadingState();
    notifyListeners();

    page = 1;
    isLast = false;

    try {
      stories = await _storiesApi.all();
      _state = LoadedState(stories);
    } catch (e) {
      _state = ErrorState(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> load() async {
    try {
      final List<Story> newStories = await _storiesApi.all(page: ++page);
      stories.addAll(newStories);
      isLast = newStories.isEmpty;
      _state = LoadedState(stories);
    } catch (e) {
      _state = ErrorState(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
