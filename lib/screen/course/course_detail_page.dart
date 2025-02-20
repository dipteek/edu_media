import 'package:edu_media/setting/convert.dart';
import 'package:flutter/material.dart';

class CourseDetailPage extends StatelessWidget {
  final Map course;

  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (course['image'] != null)
              Image.network(
                urlImg + '${course['image']}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 10),
            Text(
              course['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              course['description'],
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
