import 'dart:convert';

import 'package:http/http.dart';
import 'package:storia/models/story.dart';

class StoriesApi {
  static const String _baseUrl = "https://story-api.dicoding.dev/v1";

  final Map<String, String> _headers;

  StoriesApi(token) : _headers = {"Authorization": "Bearer $token"};

  Future<List<Story>> all() async {
    try {
      final Response response = await get(
        Uri.parse("$_baseUrl/stories"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["listStory"];
        return (data as List).map((story) => Story.fromJson(story)).toList();
      }

      if (response.body.isNotEmpty) {
        throw Exception(jsonDecode(response.body)["message"]);
      } else {
        throw Exception("Failed to load stories");
      }
    } catch (e) {
      throw Exception("Failed to load stories");
    }
  }

  Future<Story> detail(String id) async {
    try {
      final Response response = await get(
        Uri.parse("$_baseUrl/stories/$id"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["story"];
        return Story.fromJson(data);
      }

      if (response.body.isNotEmpty) {
        throw Exception(jsonDecode(response.body)["message"]);
      } else {
        throw Exception("Failed to load story");
      }
    } catch (e) {
      throw Exception("Failed to load story");
    }
  }
}
