import 'dart:convert';
import 'package:edu_media/Model/Post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = fetchPosts();
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('http://your-backend-url.com/api/posts'),
      headers: {
        'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['posts'] as List;
      return data.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: FutureBuilder<List<Post>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];
              return Card(
                child: Column(
                  children: [
                    Image.network('${post.imagePath}${post.imagePath}'),
                    if (post.caption.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(post.caption),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
