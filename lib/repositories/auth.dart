import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:storia/models/user.dart';

class AuthRepository {
  final String userKey = "user";

  Future<bool> login(User user) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setString(userKey, jsonEncode(user.toJson()));
  }

  Future<User?> user() async {
    final preferences = await SharedPreferences.getInstance();
    final json = preferences.getString(userKey) ?? "";
    User? user;
    try {
      user = User.fromJson(jsonDecode(json));
    } catch (e) {
      user = null;
    }
    return user;
  }

  Future<bool> logout() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.remove(userKey);
  }
}
