import 'package:edu_media/screen/course/course_page.dart';
import 'package:edu_media/screen/course/create_course_page.dart';
import 'package:edu_media/screen/create_post_page.dart';
import 'package:edu_media/screen/home_screen.dart';
import 'package:edu_media/screen/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigation extends StatefulWidget {
  final int selectIn;
  const BottomNavigation({super.key, required this.selectIn});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  Widget _currentScreen = HomeScreen();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _selectedIndex = widget.selectIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 50, // Adjusted height for better visibility
      width: size.width,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              iconOFNavigation(Icons.home_outlined, 0),
              iconOFNavigation(Icons.add_box_outlined, 2),
              iconOFNavigation(Icons.person_outline, 1),
              iconOFNavigation(Icons.article_rounded, 3),
            ],
          )
        ],
      ),
    );
  }

  /*Widget iconOFNavigation(IconData icon, int index) {
    return GestureDetector(
      onTap: () async {
        if (index == 1) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          int? userId = prefs.getInt('user_id');
          if (userId == null) {
            print("User not logged in");
            return;
          }
          setState(() {
            _selectedIndex = index;
            _currentScreen = ProfilePage(userId: userId);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => _currentScreen,
              ),
              (route) => false,
            );
          });
        } else {
          setState(() {
            _selectedIndex = index;
            _currentScreen = HomeScreen();
          });
        }
      },
      child: Icon(
        icon,
        color: _selectedIndex == index
            ? Color.fromARGB(255, 61, 83, 161)
            : Colors.black,
        size: 30,
      ),
    );
  }*/
  Widget iconOFNavigation(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index; // Update the selected index
        });
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
            break;
          case 1:
            profilePage();
            break;
          case 2:
            showBottomSheet(context);
            break;
          case 3:
            coursePage();
          default:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
              (route) => false,
            );
        }
      },
      child: Icon(
        icon,
        color: _selectedIndex == index
            ? Color.fromARGB(255, 61, 83, 161) // Blue for selected
            : Colors.black, // Black for others
        size: 30,
      ),
    );
  }

  void profilePage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: userId),
        ),
        (route) => false,
      );
    } else {
      // Handle the case where userId is not available
      print("User not logged in");
    }
  }

  void createPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePostPage(userId: userId),
        ),
      );
    } else {
      // Handle the case where userId is not available
      print("User not logged in");
    }
  }

  void coursePage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoursePage(),
      ),
    );
  }

  Future<void> showBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensure the bottom sheet adjusts to content
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the start
            children: [
              InkWell(
                onTap: () {
                  createPage();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Create Post",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateCoursePage(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Create Course",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
