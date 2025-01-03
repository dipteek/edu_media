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
}
