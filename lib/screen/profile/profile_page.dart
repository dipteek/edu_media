import 'package:edu_media/auth/auth_screen.dart';
import 'package:edu_media/auth/login.dart';
import 'package:edu_media/main.dart';
import 'package:edu_media/screen/bottom_navigation.dart';
import 'package:edu_media/screen/course/create_course_page.dart';
import 'package:edu_media/screen/course/own/course_page.dart';
import 'package:edu_media/screen/edit_profile_page.dart';
import 'package:edu_media/screen/profile/PDFViewerScreen.dart';
import 'package:edu_media/setting/convert.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({super.key, required this.userId});

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
        actions: [
          IconButton(
              onPressed: () {
                logout();
              },
              icon: const Icon(Icons.logout_rounded))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          /*backgroundImage: CachedNetworkImageProvider(
                            urlImg + userData?['profile_picture'] ??
                                'https://via.placeholder.com/150',
                          ),*/
                        ),
                        const SizedBox(width: 16),
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
                              const SizedBox(height: 8),
                              Text(userData?['bio'] ?? ''),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(),
                  ElevatedButton(
                      onPressed: () {
                        editProfile();
                      },
                      child: const Text("Edit Profile")),
                  ElevatedButton(
                      onPressed: () {
                        editCourse();
                      },
                      child: const Text("My Courses")),

                  // Posts Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userPosts?.length ?? 0,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      String fileUrl =
                          urlImg + (userPosts?[index]['file_path'] ?? '');

                      // Check file extension
                      if (fileUrl.endsWith('.jpg') ||
                          fileUrl.endsWith('.jpeg') ||
                          fileUrl.endsWith('.png')) {
                        // If it's an image, show CachedNetworkImage
                        return CachedNetworkImage(
                          imageUrl: fileUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        );
                      } else if (fileUrl.endsWith('.pdf')) {
                        // If it's a PDF, show a preview button
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PDFViewerScreen(pdfUrl: fileUrl),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.picture_as_pdf,
                                size: 50, color: Colors.red),
                          ),
                        );
                      } else {
                        // Default case (unknown file type)
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.insert_drive_file,
                              size: 50, color: Colors.blue),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavigation(
        selectIn: 1,
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }

  void editProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("user_id");
    if (userId != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfilePage(userId: userId),
          ));
      print("work");
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ));
      print("null");
    }
  }

  void editCourse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("user_id");
    if (userId != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoursePage(),
          ));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ));
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    //prefs.setString('access_token', data['data']['access_token']);
    prefs.remove('user_id');
    print("logout done");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
      (route) => false,
    );
  }
}
