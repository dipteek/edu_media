class Video {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  //final String categoryId;

  Video({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    // required this.categoryId,
  });

  // factory Video.fromJson(Map<String, dynamic> json) {
  //   return Video(
  //     videoId: json['id']['videoId'],
  //     title: json['snippet']['title'],
  //     description: json['snippet']['description'],
  //     thumbnailUrl: json['snippet']['thumbnails']['medium']
  //         ['url'], /*categoryId: json['snippet']['categoryId']*/
  //   );
  // }
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json['id'] is Map ? json['id']['videoId'] : json['id'],
      title: json['snippet']['title'],
      description: json['snippet']['description'],
      thumbnailUrl: json['snippet']['thumbnails']['medium']['url'],
    );
  }
}
