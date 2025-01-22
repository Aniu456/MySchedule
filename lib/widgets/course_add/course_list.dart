import 'package:flutter/material.dart';

//已添加课程列表
class CourseList extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Color themeColor;
  final Function() onFinish;
  final Function(int) onRemoveCourse;

  const CourseList({
    super.key,
    required this.courses,
    required this.themeColor,
    required this.onFinish,
    required this.onRemoveCourse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.list_alt, size: 20, color: themeColor),
                  const SizedBox(width: 8),
                  Text(
                    '已添加 ${courses.length} 门课程',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onFinish,
                icon: Icon(Icons.check, size: 20, color: themeColor),
                label: Text(
                  '完成',
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromRGBO(
                    themeColor.r.toInt(),
                    themeColor.g.toInt(),
                    themeColor.b.toInt(),
                    0.1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(courses.length, (index) {
              final course = courses[index];
              final courseColor = Color.fromRGBO(
                course['color'][0],
                course['color'][1],
                course['color'][2],
                1,
              );
              return Chip(
                label: Text(
                  course['courseName'],
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: courseColor,
                deleteIcon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
                onDeleted: () => onRemoveCourse(index),
              );
            }),
          ),
        ],
      ),
    );
  }
}
