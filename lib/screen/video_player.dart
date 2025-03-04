import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    // Set up BetterPlayer configuration
    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: false,
      fullScreenByDefault: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableFullscreen: true,
        enablePlayPause: true,
        enableSkips: true,
        enablePlaybackSpeed: true,
      ),
    );

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration)
      ..setupDataSource(dataSource);
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: _betterPlayerController),
        ),
      ),
    );
  }
}
