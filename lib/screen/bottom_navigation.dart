import 'package:flutter/material.dart';

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
}
