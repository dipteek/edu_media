import 'dart:convert';
import 'package:edu_media/setting/convert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'course_detail_page.dart'; // Ensure this import is correct

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List courses = [];
  bool isLoading = false;
  bool isError = false;
  // final String urlM =
  //     'http://192.168.0.10:8000/api/'; // Replace with your base URL
  // final String urlImg =
  //     'http://192.168.0.10:8000/storage/'; // Replace with your image base URL

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.get(Uri.parse('${urlM}courses'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          courses = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCourses,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 50),
                      const SizedBox(height: 10),
                      const Text(
                        'Failed to load courses. Please try again!',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchCourses,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : courses.isEmpty
                  ? const Center(
                      child: Text(
                        'No courses available.',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CourseDetailPage(course: course),
                            ),
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                // Course Image
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Hero(
                                    tag: 'course_${course['id']}',
                                    child: course['image'] != null
                                        ? Image.network(
                                            '$urlImg${course['image']}',
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                    Icons.broken_image,
                                                    size: 40,
                                                    color: Colors.grey),
                                              );
                                            },
                                          )
                                        : Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image,
                                                size: 40, color: Colors.grey),
                                          ),
                                  ),
                                ),

                                // Course Details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course['title'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          course['description'],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
