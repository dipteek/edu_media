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
      setState(() {
        videos = response.map((json) => Video.fromJson(json)).toList();
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
    );
  }
}
