import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:edu_media/setting/convert.dart';
import 'course_detail_page.dart';

class CoursePage extends StatefulWidget {
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List courses = [];
  bool isLoading = false;
  bool isError = false;

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
      final response = await http.get(Uri.parse(urlM + 'courses'));

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
        title: Text('Courses', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchCourses,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 50),
                      SizedBox(height: 10),
                      Text(
                        'Failed to load courses. Please try again!',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchCourses,
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo),
                      ),
                    ],
                  ),
                )
              : courses.isEmpty
                  ? Center(
                      child: Text(
                        'No courses available.',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(10),
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
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                // Course Image
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Hero(
                                    tag: 'course_${course['id']}',
                                    child: course['image'] != null
                                        ? Image.network(
                                            urlImg + '${course['image']}',
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.image,
                                                size: 40,
                                                color: Colors.grey[700]),
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
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          course['description'],
                                          style: TextStyle(
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
