import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CourseStorage {
  static const String _key = 'courses';
  static const String _semesterKey = 'current_semester';

  // 保存课程
  static Future<void> saveCourses(List<Map<String, dynamic>> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final String coursesJson = jsonEncode(courses);
    await prefs.setString(_key, coursesJson);
  }

  // 获取课程
  static Future<List<Map>> getCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesJson = prefs.getString(_key);
    if (coursesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(coursesJson);
    return decoded.map((course) {
      // 确保 weeks 和 color 是 List<int>
      return {
        ...course,
        'weeks': (course['weeks'] as List).map((e) => e as int).toList(),
        'color': (course['color'] as List).map((e) => e as int).toList(),
      };
    }).toList();
  }

  // 删除课程
  static Future<void> deleteCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // 保存当前学期
  static Future<void> saveSemester(int semester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_semesterKey, semester);
  }

  // 获取当前学期
  static Future<int> getSemester() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_semesterKey) ?? 1;
  }
}
