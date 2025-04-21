import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale("id");

  LocalizationProvider() {
    _get();
  }

  Locale get locale => _locale;

  set locale(Locale locale) {
    _locale = locale;
    _set(locale);
    notifyListeners();
  }

  Future<void> _get() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    _locale = languageCode != null ? Locale(languageCode) : const Locale("id");
    notifyListeners();
  }

  Future<void> _set(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }
}
