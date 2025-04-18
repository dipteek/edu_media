import 'dart:convert';

import 'package:edu_media/setting/convert.dart';
import 'package:edu_media/user/UserProfile.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = urlMY;
  final String? token;

  UserService({this.token});

  Future<UserProfile> getUserProfileById(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return UserProfile.fromJson(data['user']);
      }
    }
    throw Exception('Failed to load user profile');
  }

  // Follow/unfollow methods
  Future<bool> followUser(int userId) async {
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/follow'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> unfollowUser(int userId) async {
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/unfollow'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return response.statusCode == 200;
  }
}
