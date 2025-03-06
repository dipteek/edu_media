import 'dart:convert';
import 'package:edu_media/setting/convert.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = urlM + "youtube";

  static Future<List<dynamic>> fetchVideos(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/videos?q=$query'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    } else {
      throw Exception("Failed to load videos");
    }
  }
}
