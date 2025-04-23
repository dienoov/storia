import 'dart:convert';

import 'package:http/http.dart';
import 'package:storia/models/user.dart';

class AuthApi {
  static const String _baseUrl = "https://story-api.dicoding.dev/v1";

  Future<User> login(String email, String password) async {
    final Response response = await post(
      Uri.parse("$_baseUrl/login"),
      body: {"email": email, "password": password},
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)["loginResult"]);
    }

    if (response.body.isNotEmpty) {
      throw Exception(jsonDecode(response.body)["message"]);
    } else {
      throw Exception("Failed to login");
    }
  }

  Future<User> register(String name, String email, String password) async {
    final Response response = await post(
      Uri.parse("$_baseUrl/register"),
      body: {"name": name, "email": email, "password": password},
    );

    if (response.statusCode == 201) {
      return await login(email, password);
    }

    if (response.body.isNotEmpty) {
      throw Exception(jsonDecode(response.body)["message"]);
    } else {
      throw Exception("Failed to register");
    }
  }
}
