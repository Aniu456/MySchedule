import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';

/// 已添加课程列表
class CourseList extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Color themeColor;
  final Function() onFinish;
  final Function(int) onRemoveCourse;
  final bool useFixedColor;

  const CourseList({
    super.key,
    required this.courses,
    required this.themeColor,
    required this.onFinish,
    required this.onRemoveCourse,
    this.useFixedColor = false,
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
                    (themeColor.r * 255).round(),
                    (themeColor.g * 255).round(),
                    (themeColor.b * 255).round(),
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

              // 为每个课程创建一个固定的颜色
              final Color courseColor;
              if (course['color'] != null &&
                  course['color'] is List &&
                  course['color'].length >= 3) {
                // 课程有颜色数据，直接使用
                courseColor = ColorUtils.storageToColor(course['color'],
                    defaultColor:
                        Colors.primaries[index % Colors.primaries.length]);
              } else {
                // 课程没有颜色数据，使用固定主题色或索引颜色
                courseColor = useFixedColor
                    ? Colors.primaries[index % Colors.primaries.length]
                    : themeColor;
              }

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
