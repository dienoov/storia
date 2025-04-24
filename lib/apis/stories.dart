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

  Future<bool> add(String description, String path) async {
    try {
      final request = MultipartRequest("POST", Uri.parse("$_baseUrl/stories"));

      request.headers.addAll(_headers);
      request.fields["description"] = description;
      request.files.add(
        await MultipartFile.fromPath(
          "photo",
          path,
          filename: path.split("/").last,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 201) {
        final data = await response.stream.bytesToString();
        final json = jsonDecode(data);
        return json["error"] == false;
      }

      throw Exception("Failed to add story");
    } catch (e) {
      throw Exception("Failed to add story");
    }
  }
}
