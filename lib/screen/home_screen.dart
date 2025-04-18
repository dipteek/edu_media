import 'package:edu_media/auth/login.dart';
import 'package:edu_media/screen/bottom_navigation.dart';
import 'package:edu_media/screen/profile/PDFViewerScreen.dart';
import 'package:edu_media/service/like_service.dart';
import 'package:edu_media/setting/convert.dart';
import 'package:edu_media/user/UserProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;
  final String apiUrl = "posts";
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    fetchPosts();

    _scrollController.addListener(_scrollListener);
    //checkLogin();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more posts when scrolled to bottom
      // Implementation for pagination can be added here
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _isRefreshing = true;
    });
    await fetchPosts();
    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> fetchPosts() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get your authentication token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // Set up authentication headers if token exists
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(urlM + apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          posts = data['posts'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackbar("Failed to load posts. Please try again later.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackbar(
          "Connection error. Please check your internet connection.");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Educational Media",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : posts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      String filePath = post['file_path'];
                      String fileUrl = urlImg + filePath;
                      String caption = post['caption'] ?? "No Caption";

                      // Format date if available
                      DateTime? postDate;
                      if (post['created_at'] != null) {
                        try {
                          postDate = DateTime.parse(post['created_at']);
                        } catch (e) {
                          // Handle invalid date format
                        }
                      }

                      return _buildPostCard(post, fileUrl, caption, postDate);
                    },
                  ),
      ),
      bottomNavigationBar: BottomNavigation(
        selectIn: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create post screen
        },
        child: const Icon(Icons.add),
        tooltip: "Create Post",
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No posts available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _refreshPosts,
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
      dynamic post, String fileUrl, String caption, DateTime? postDate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header with User Info
          _buildPostHeader(post, postDate),

          // Post Media Content
          _buildMediaContent(fileUrl),

          // Interaction Buttons
          _buildInteractionButtons(post),

          // Post Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (caption.isNotEmpty)
                  Text(
                    caption,
                    style: const TextStyle(fontSize: 15),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(dynamic post, DateTime? postDate) {
    print(post);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserProfileScreen(userId: post['user_id']),
                  ));
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  post['user'] != null && post['user']['profile_image'] != null
                      ? CachedNetworkImageProvider(
                          urlImg + post['user']['profile_image'])
                      : null,
              child:
                  post['user'] == null || post['user']['profile_image'] == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['user'] != null
                      ? post['user']['name'] ?? 'Unknown'
                      : 'Anonymous',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (postDate != null)
                  Text(
                    timeago.format(postDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show post options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(String fileUrl) {
    if (fileUrl.endsWith('.jpg') ||
        fileUrl.endsWith('.jpeg') ||
        fileUrl.endsWith('.png')) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        child: CachedNetworkImage(
          imageUrl: fileUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
          placeholder: (context, url) => Container(
            height: 300,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 300,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
            ),
          ),
        ),
      );
    } else if (fileUrl.endsWith('.pdf')) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerScreen(pdfUrl: fileUrl),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, size: 70, color: Colors.red),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerScreen(pdfUrl: fileUrl),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text("View PDF"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file, size: 50, color: Colors.blue),
              SizedBox(height: 8),
              Text(
                "File Attachment",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      );
    }
  }

  /*Widget _buildInteractionButtons(dynamic post) {
    bool isLiked = post['is_liked'] ?? false;
    int likesCount = post['likes_count'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.thumb_up_alt_outlined,
              color: isLiked ? Colors.blue : Colors.grey[700],
            ),
            onPressed: () {
              // Implement like functionality
              _handleLikePress(post);
            },
          ),
          if (likesCount > 0)
            Text(
              '$likesCount',
              style: TextStyle(
                color: isLiked ? Colors.blue : Colors.grey[700],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // Navigate to comments
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Implement share functionality
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Implement bookmark functionality
            },
          ),
        ],
      ),
    );
  }*/
  Widget _buildInteractionButtons(dynamic post) {
    // Make sure these values default to false and 0 if they're null
    bool isLiked = post['is_liked'] ?? false;
    int likesCount = post['likes_count'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
              color: isLiked ? Colors.blue : Colors.grey[700],
            ),
            onPressed: () {
              _handleLikePress(post);
            },
          ),
          if (likesCount > 0)
            Text(
              '$likesCount',
              style: TextStyle(
                color: isLiked ? Colors.blue : Colors.grey[700],
              ),
            ),
          // Rest of your buttons
        ],
      ),
    );
  }

  Future<void> _handleLikePress(dynamic post) async {
    if (post['id'] == null) return;

    try {
      // Check if user is authenticated
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (route) => false,
        );
        return;
      }

      // Show optimistic UI update
      setState(() {
        bool currentLiked = post['is_liked'] ?? false;
        post['is_liked'] = !currentLiked;

        if (currentLiked) {
          post['likes_count'] = (post['likes_count'] ?? 1) - 1;
        } else {
          post['likes_count'] = (post['likes_count'] ?? 0) + 1;
        }
      });

      // Call API to update like status
      final result = await LikeService.toggleLike(post['id']);

      // Update UI with server response
      setState(() {
        post['is_liked'] = result['liked'];
        post['likes_count'] = result['likes_count'];
      });
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        bool currentLiked = post['is_liked'] ?? false;
        post['is_liked'] = !currentLiked;

        if (currentLiked) {
          post['likes_count'] = (post['likes_count'] ?? 0) - 1;
        } else {
          post['likes_count'] = (post['likes_count'] ?? 1) + 1;
        }
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update like status. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (route) => false,
        );
      }
    }
  }
}
