class Video {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;

  Video({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json['id']['videoId'],
      title: json['snippet']['title'],
      description: json['snippet']['description'],
      thumbnailUrl: json['snippet']['thumbnails']['medium']['url'],
    );
  }
}
