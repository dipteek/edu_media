import 'dart:convert';
import 'package:edu_media/setting/convert.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = urlMY;

  static Future<List<dynamic>> fetchVideos(String query) async {
    print(baseUrl);

    final response = await http.get(Uri.parse('$baseUrl/youtube?q=$query'));
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    } else {
      throw Exception("Failed to load videos");
    }
  }
}
