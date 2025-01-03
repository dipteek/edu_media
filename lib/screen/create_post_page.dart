import 'dart:async';
import 'dart:io';
import 'package:edu_media/loading.dart';
import 'package:edu_media/setting/convert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostPage extends StatefulWidget {
  final int userId;
  const CreatePostPage({Key? key, required this.userId}) : super(key: key);
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  TextEditingController _captionController = TextEditingController();
  File? _image;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    setState(() {
      isLoading = true;
    });
    if (_image == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select an image')));
      return;
    }

    final url = Uri.parse('${urlM}postsp');
    //print(url);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Authentication required')));
        return;
      }

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({'Authorization': 'Bearer $token'})
        ..fields['user_id'] = widget.userId.toString()
        ..fields['caption'] = _captionController.text;

      // Add image if selected
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ));
      }

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 40),
        onTimeout: () {
          throw TimeoutException('Request timed out try after 2 min');
        },
      );

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      /*final request = http.MultipartRequest('POST', url)
      ..headers.addAll({'Authorization': 'Bearer $token'})
      ..fields['user_id'] = widget.userId.toString()
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path))
      ..fields['caption'] = _captionController.text;

    final response = await request.send();*/

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Post Uploaded'),
                backgroundColor: Colors.greenAccent,
              ),
            );
          });
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create post'),
              backgroundColor: Colors.redAccent,
            ),
          );
        });
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(title: Text('Create Post')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _captionController,
                    decoration: InputDecoration(labelText: 'Caption'),
                  ),
                  SizedBox(height: 16),
                  _image != null
                      ? Image.file(_image!)
                      : Text('No image selected'),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _createPost,
                    child: Text('Create Post'),
                  ),
                ],
              ),
            ),
          );
  }
}
