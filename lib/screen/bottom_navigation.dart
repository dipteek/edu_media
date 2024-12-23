import 'package:edu_media/screen/home_screen.dart';
import 'package:edu_media/screen/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0; // To track the currently selected icon

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
              iconOFNavigation(Icons.person_outline, 1),
            ],
          )
        ],
      ),
    );
  }

  Widget iconOFNavigation(IconData icon, int index) {
    return InkWell(
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
                ));
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
            ? Color.fromARGB(255, 61, 83, 161)
            : Colors.black,
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
