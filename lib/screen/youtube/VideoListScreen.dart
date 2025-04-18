import 'dart:convert' show json;

import 'package:edu_media/screen/bottom_navigation.dart';
import 'package:edu_media/screen/youtube/api_service.dart';
import 'package:edu_media/screen/youtube/video_model.dart';
import 'package:edu_media/screen/youtube/youtube_video_player_screen.dart';
import 'package:flutter/material.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<Video> videos = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchVideos("education"); // Default search
  }

  Future<void> fetchVideos(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.fetchVideos(query);
      print("hello");
      print(response);
      List<Video> filteredVideos = response
          .map((json) => Video.fromJson(json))
          .where((video) =>
              !video.title.toLowerCase().contains("Madhu") ||
              video.description.toLowerCase().contains("Madhu Singh"))
          .toList();
      /*List<Video> filteredVideos = response
          .map((json) {
            final video = Video.fromJson(json);
            final snippet =
                json['snippet'] as Map<String, dynamic>?; // Ensure it's a Map
            final categoryId =
                snippet?['categoryId']?.toString(); // Get categoryId safely
            return categoryId == "27" ? video : null;
          })
          .whereType<Video>() // Remove null values
          .where((video) => !video.title.toLowerCase().contains("madhu singh"))
          .toList();*/
      setState(() {
        //videos = response.map((json) => Video.fromJson(json)).toList();
        videos = filteredVideos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  void openVideo(String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => YtVideoPlayerScreen(videoId: videoId)),
    );
  }

  void onSearch() {
    String query = searchController.text.trim();
    if (query.isNotEmpty) {
      fetchVideos(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Search educational videos...",
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) => onSearch(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : videos.isEmpty
              ? const Center(child: Text("No videos found"))
              : ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return ListTile(
                      leading: Image.network(video.thumbnailUrl, width: 100),
                      title: Text(video.title,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(video.description,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => openVideo(video.videoId),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigation(
        selectIn: 4,
      ),
    );
  }
}
