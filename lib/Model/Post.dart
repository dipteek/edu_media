class Post {
  final int id;
  final int userId;
  final String caption;
  final String imagePath;

  Post({
    required this.id,
    required this.userId,
    required this.caption,
    required this.imagePath,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      caption: json['caption'] ?? '',
      imagePath: json['image_path'],
    );
  }
}
