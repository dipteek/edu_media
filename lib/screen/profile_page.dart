import 'package:edu_media/setting/convert.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final int userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  List<dynamic>? userPosts;
  bool isLoading = true;

  Future<void> fetchProfile() async {
    final url = '${urlM}profile/${widget.userId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userData = data['user'];
        userPosts = data['posts'];
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userData?['name'] ?? 'Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: CachedNetworkImageProvider(
                            userData?['profile_picture'] ??
                                'https://via.placeholder.com/150',
                          ),
                        ),
                        SizedBox(width: 16),
                        // Stats
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatColumn(
                                      'Posts', userData?['posts_count'] ?? 0),
                                  _buildStatColumn('Followers',
                                      userData?['followers_count'] ?? 0),
                                  _buildStatColumn('Following',
                                      userData?['following_count'] ?? 0),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(userData?['bio'] ?? ''),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(),

                  // Posts Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: userPosts?.length ?? 0,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: userPosts?[index]['image'] ??
                            'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
