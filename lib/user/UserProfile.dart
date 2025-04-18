class UserProfile {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? bio;
  final String? gender;
  final int? age;
  final String? education;
  final String? image;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.bio,
    this.gender,
    this.age,
    this.education,
    this.image,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      gender: json['gender'],
      age: json['age'],
      education: json['education'],
      image: json['image'],
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      isFollowing: json['is_following'] ?? false,
    );
  }
}
