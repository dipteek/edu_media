import 'dart:io';
import 'package:edu_media/setting/convert.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UploadFilePage extends StatefulWidget {
  final int userId;

  const UploadFilePage({super.key, required this.userId});

  @override
  _UploadFilePageState createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  File? _selectedFile;
  String? _fileType;
  double _uploadProgress = 0.0;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileType = result.files.single.extension;
      });
    }
  }

  Future<void> _uploadFile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    String? token = prefs.getString('access_token');

    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _selectedFile != null) {
      var request = http.MultipartRequest('POST', Uri.parse('${urlM}postsp'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['user_id'] = userId.toString();
      request.fields['caption'] = _captionController.text;
      request.files
          .add(await http.MultipartFile.fromPath('file', _selectedFile!.path));

      print("🔹 Sending Request: ");
      print("🔹 User ID: ${userId.toString()}");
      print("🔹 Caption: ${_captionController.text}");
      print("🔹 File: ${_selectedFile!.path}");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("🔹 Response Status Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(labelText: 'Caption'),
                validator: (value) =>
                    value!.isEmpty ? 'Caption is required' : null,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickFile,
                child: _selectedFile == null
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.attach_file, size: 50),
                      )
                    : Text(
                        'File Selected: ${_selectedFile!.path.split('/').last}'),
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
                onPressed: _uploadFile,
                child: const Text('Upload File'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
