import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:edu_media/setting/convert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  _CreateCoursePageState createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitCourse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (_formKey.currentState!.validate() && userId != null) {
      setState(() {
        _isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      try {
        var request =
            http.MultipartRequest('POST', Uri.parse('${urlM}courses'));
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['title'] = _titleController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['user_id'] = userId.toString();

        if (_image != null) {
          request.files
              .add(await http.MultipartFile.fromPath('image', _image!.path));
        }

        var response = await request.send();
        var responseBody =
            await response.stream.bytesToString(); // Get response body

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course created successfully!')),
          );
          Navigator.pop(context);
        } else {
          print("Error: ${response.statusCode}");
          print("Response: $responseBody");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create course: $responseBody')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Exception: $e");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Course',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Course Title',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 15),

                    // Description Input
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Course Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 4,
                      validator: (value) =>
                          value!.isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 15),

                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.grey[100],
                        ),
                        child: _image == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 50, color: Colors.grey),
                                  SizedBox(height: 5),
                                  Text('Tap to select an image',
                                      style: TextStyle(color: Colors.grey))
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _image!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitCourse,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Submit Course',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
