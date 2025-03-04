import 'package:edu_media/auth/login.dart';
import 'package:edu_media/screen/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Home Screens"),
      bottomNavigationBar: BottomNavigation(
        selectIn: 0,
      ),
    );
  }

  void checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (route) => false,
      );
    }
  }
}
