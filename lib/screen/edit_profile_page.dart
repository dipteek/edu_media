import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_media/setting/convert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;

  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _gender;
  File? _profileImage;
  bool isLoading = true;
  String img = '';
  String err = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final url = '${urlM}profile-fetch/${widget.userId}';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['user'];
        setState(() {
          _nameController.text = data['name'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _gender = data['gender'] ?? 'male'; // Default gender
          isLoading = false;
          img = data['profile_image'] ?? '';
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateProfile() async {
    final url = '${urlM}profile-update/${widget.userId}';
    try {
      print('Request URL: $url');

      final request = http.MultipartRequest('PUT', Uri.parse(url));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = _nameController.text;
      request.fields['username'] = _usernameController.text;
      request.fields['bio'] = _bioController.text;
      request.fields['gender'] = _gender ?? '';

      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _profileImage!.path,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context); // Go back to the previous page
        }
      } else {
        final errorData = jsonDecode(responseBody);

        if (errorData['errors'] != null &&
            errorData['errors']['username'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username is already taken')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Error: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: CachedNetworkImageProvider(
                          urlImg + img,
                        ) /* _profileImage != null
                            ? FileImage(_profileImage!)
                            : NetworkImage(
                                'http://your-laravel-backend.com/images/default_profile.png',
                              ) as ImageProvider*/
                        ,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(labelText: 'Bio'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(labelText: 'Gender'),
                      items: ['male', 'female', 'other']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(
                                  gender[0].toUpperCase() + gender.substring(1),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text(err),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
