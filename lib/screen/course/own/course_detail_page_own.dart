import 'dart:convert';
import 'dart:io';
import 'package:edu_media/screen/course/upload_video_page.dart';
import 'package:edu_media/screen/player/video_player.dart';
import 'package:edu_media/screen/player/video_player_mobile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:edu_media/setting/convert.dart';

class CourseDetailPageOwn extends StatefulWidget {
  final Map course;

  const CourseDetailPageOwn({super.key, required this.course});

  @override
  _CourseDetailPageOwnState createState() => _CourseDetailPageOwnState();
}

class _CourseDetailPageOwnState extends State<CourseDetailPageOwn> {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UploadVideoPage(courseId: widget.course['id']),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                              child: const Icon(Icons.image,
                                  size: 60, color: Colors.grey),
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

                  // Videos List
                  const Text(
                    'Course Videos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

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
                                  if (!Platform.isAndroid) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoPlayerScreen(
                                            videoUrl:
                                                '$urlImg${video['video_path']}'),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VideoPlayerMobileScreen(
                                                videoUrl:
                                                    '$urlImg${video['video_path']}'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}

// Video Player Screen
