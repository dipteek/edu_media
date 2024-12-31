import 'dart:async';
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
  bool _isLoading = false;

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

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['user'];
        //final data = jsonDecode(response.body);
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
    //final url = '${urlM}profile-update/${widget.userId}';
    final url = Uri.parse('${urlM}profile-update/${widget.userId}');
    try {
      //print('Request URL: $url');

      //final request = http.MultipartRequest('PUT', Uri.parse(url));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      print(token);

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      //request.headers['Authorization'] = 'Bearer $token';
      //request.fields['name'] = _nameController.text;
      //request.fields['username'] = _usernameController.text;

      String name = _nameController.text;
      String username = _usernameController.text;

      final body = jsonEncode({
        'name': _nameController.text,
        'username': _usernameController.text,
        'bio': _bioController.text,
        'gender': _gender ?? '',
      });

      /*final request = http.MultipartRequest('PUT', url)
        ..headers.addAll(headers)
        ..fields['name'] = 'John Doe'
        ..fields['username'] = _usernameController.text;*/

      /* 
        ..fields['bio'] = _bioController.text
        ..fields['gender'] = _gender ?? '' */

      //request.fields['bio'] = _bioController.text;
      //request.fields['gender'] = _gender ?? '';

      /*if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _profileImage!.path,
        ));
      }*/

      /* if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _profileImage!.path,
        ));
      }*/

      // print('Request Fields: ${request.fields}');

      //final streamedResponse = await request.send();

      // Convert the streamed response into a standard HTTP response
      // final response = await http.Response.fromStream(streamedResponse);
      final response = await http.put(url, headers: headers, body: body);
      //final response = await request.send();
      //final responseBody = await response.stream.bytesToString();
      // print(request);
      print('Response Status Code: ${response}');
      //print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context); // Go back to the previous page
        }
      } else {
        print(response.body.toString());
        final errorData = jsonDecode(response.body);

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

  /* Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }*/

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000, // Optimize image size
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> makeRequest() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Construct URL
      final url = Uri.parse('${urlM}profile-update/${widget.userId}');

      // Get token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Prepare headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      // Create multipart request
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(headers)
        ..fields['name'] = _nameController.text
        ..fields['username'] = _usernameController.text
        ..fields['bio'] = _bioController.text
        ..fields['gender'] = _gender ?? '';

      // Add image if selected
      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _profileImage!.path,
        ));
      }

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      // Get response
      final response = await http.Response.fromStream(streamedResponse);
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _showSuccess('Profile updated successfully');
          Navigator.pop(context, true); // Optionally navigate back
        } else {
          throw Exception(data['message'] ?? 'Failed to update profile');
        }
      } else {
        final errorMessage = _parseErrorMessage(response);
        _showError(errorMessage);
      }
    } catch (e) {
      _showError('Error updating profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? body['error'] ?? 'Unknown error occurred';
    } catch (e) {
      return 'Error ${response.statusCode}: ${response.reasonPhrase}';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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
                      onPressed: /*_updateProfile*/ makeRequest,
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
