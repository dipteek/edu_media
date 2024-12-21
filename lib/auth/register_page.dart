import 'dart:io';
import 'dart:typed_data';

import 'package:edu_media/auth/login.dart';
import 'package:edu_media/loading.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:image_picker_web/image_picker_web.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // final ImagePickerService _imagePicker = ImagePickerService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  String _educationType = 'Student';
  bool isLoading = false;

  File? _imageFile; // For Android/iOS
  Uint8List? _imageBytes; // For Web

  //
  //
  //
  //
  //
  //

  //final picker = ImagePicker();

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  /* Future<void> _pickImage() async {
    if (kIsWeb) {
      final pickedBytes = await ImagePickerWeb.getImageAsBytes();
      setState(() {
        if (pickedBytes != null) {
          _imageBytes = pickedBytes;
        }
      });
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }*/

  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.0.106:8000/api/register'),
      );
      request.fields['name'] = _nameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['age'] = _ageController.text;
      request.fields['education_type'] = _educationType;

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _imageFile!.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 61, 83, 161),
        body: isLoading == true
            ? ScreenLoading()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        color: Color.fromARGB(255, 61, 83, 161),
                        width: double.infinity,
                        height: size.height * 0.3,
                        child: Image.asset('assets/images/friendship.png')),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 30.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: _imageFile == null
                                          ? const Icon(Icons.camera_alt,
                                              size: 40)
                                          : ClipOval(
                                              child: Image.file(
                                                _imageFile!,
                                                fit: BoxFit.cover,
                                                width: 140,
                                                height: 140,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              customField("Name", "Please enter your name",
                                  null, _nameController),
                              const SizedBox(height: 20),
                              customField("Email", "Please enter your email",
                                  TextInputType.emailAddress, _emailController),
                              const SizedBox(height: 20),
                              customField(
                                  "Password",
                                  "Please enter your password",
                                  null,
                                  _passwordController,
                                  obscureText: true),
                              const SizedBox(height: 20),
                              customField("Age", "Please enter your age",
                                  TextInputType.number, _ageController),
                              const SizedBox(height: 20),
                              DropdownButtonFormField(
                                value: _educationType,
                                items: ['Student', 'Teacher']
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _educationType = value.toString();
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Profession',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(screenWidth * 0.8, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  backgroundColor:
                                      Color.fromARGB(255, 61, 83, 161),
                                ),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget customField(String label, String validatorMessage,
      TextInputType? keyboardType, TextEditingController controller,
      {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        hintText: 'Enter your $label',
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) => value!.isEmpty ? validatorMessage : null,
    );
  }
}
