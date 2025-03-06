import 'dart:io';
import 'package:edu_media/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:edu_media/setting/convert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadVideoPage extends StatefulWidget {
  final int courseId;

  const UploadVideoPage({super.key, required this.courseId});

  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  File? _video;
  double _uploadProgress = 0.0;

  Future<void> _pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadVideo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (route) => false,
      );
    }
    if (_formKey.currentState!.validate() && _video != null) {
      String? token = prefs.getString('access_token');
      if (token == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false,
        );
      } else {
        var request = http.MultipartRequest('POST', Uri.parse('${urlM}videos'));
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['course_id'] = widget.courseId.toString();
        request.fields['title'] = _titleController.text;
        request.fields['user_id'] = userId.toString();
        request.files
            .add(await http.MultipartFile.fromPath('video', _video!.path));

        var streamedResponse = await request.send();

        streamedResponse.stream.listen(
          (value) {
            setState(() {
              _uploadProgress = value.length / streamedResponse.contentLength!;
            });
          },
          onDone: () async {
            if (streamedResponse.statusCode == 201) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video uploaded successfully!')),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to upload video')),
              );
            }
            setState(() {
              _uploadProgress = 0.0;
            });
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload error')),
            );
            setState(() {
              _uploadProgress = 0.0;
            });
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Video Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickVideo,
                child: _video == null
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.video_library, size: 50),
                      )
                    : Text('Video Selected: ${_video!.path.split('/').last}'),
              ),
              const SizedBox(height: 20),
              if (_uploadProgress > 0)
                Column(
                  children: [
                    LinearProgressIndicator(value: _uploadProgress),
                    Text('${(_uploadProgress * 100).toStringAsFixed(2)}%'),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadVideo,
                child: const Text('Upload Video'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
