import 'dart:convert';

import 'package:edu_media/screen/video_player.dart';
import 'package:flutter/material.dart';
import 'package:edu_media/setting/convert.dart';
import 'package:http/http.dart' as http;

class CourseDetailPage extends StatefulWidget {
  final Map course;

  const CourseDetailPage({super.key, required this.course});

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  List<dynamic> _videos = []; // Store the list of videos
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    try {
      final response = await http
          .get(Uri.parse('${urlM}courses/${widget.course['id']}/videos'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Decode JSON response

        if (data is Map<String, dynamic> && data.containsKey('videos')) {
          setState(() {
            _videos = data['videos']; // Extract the list of videos
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading videos: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image with Hero Animation
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Hero(
                  tag: 'course_${widget.course['id']}',
                  child: widget.course['image'] != null
                      ? Image.network(
                          '$urlImg${widget.course['image']}',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.image,
                              size: 60, color: Colors.grey[700]),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Course Title
              Text(
                widget.course['title'],
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo),
              ),
              const SizedBox(height: 10),

              // Course Description
              Text(
                widget.course['description'],
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Additional Information (if needed)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: Colors.indigo),
                    const SizedBox(width: 10),
                    Text(
                      'Created Date: ${widget.course['created_at'] ?? 'N/A'}',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              _videos.isEmpty
                  ? const Center(child: Text('No videos available'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _videos.length,
                      itemBuilder: (context, index) {
                        var video = _videos[index];

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.play_circle_fill,
                                size: 40, color: Colors.indigo),
                            title: Text(video['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle:
                                Text("Uploaded on: ${video['created_at']}"),
                            onTap: () {
                              print('$urlImg${video['video_path']}');
                              print(" code is working");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                      videoUrl:
                                          '$urlImg${video['video_path']}'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
