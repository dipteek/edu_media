import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:edu_media/setting/convert.dart';

class CreateCoursePage extends StatefulWidget {
  @override
  _CreateCoursePageState createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var uri = Uri.parse(urlM + 'courses');
      var request = http.MultipartRequest('POST', uri);

      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;

      if (_image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Course created successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to create course. Try again!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Course',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: _image == null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.camera_alt,
                                  size: 40, color: Colors.grey[700]),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(_image!,
                                  height: 100, width: 100, fit: BoxFit.cover),
                            ),
                    ),
                    SizedBox(height: 20),

                    // Course Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Course Title',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.book, color: Colors.indigo),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Title is required' : null,
                    ),
                    SizedBox(height: 15),

                    // Course Description Field
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Course Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon:
                            Icon(Icons.description, color: Colors.indigo),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Description is required' : null,
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _submitCourse,
                            icon: Icon(Icons.check_circle, color: Colors.white),
                            label: Text('Submit Course',
                                style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
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
