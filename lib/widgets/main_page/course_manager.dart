import '../../utils/course_storage_hive.dart';

/// 课程管理器
/// 负责处理课程数据的加载、保存和更新
class CourseManager {
  final Function(String, {bool isError}) showMessage;
  final Function(void Function()) setState;

  CourseManager({
    required this.showMessage,
    required this.setState,
  });

  /// 加载课程数据
  Future<List<Map<String, dynamic>>> loadCourses() async {
    try {
      final loadedCourses = await CourseStorageHive.getCourses();
      final courses = loadedCourses.map((course) {
        return {
          'courseName': course['courseName'] ?? '',
          'teacherName': course['teacherName'] ?? '',
          'remarks': course['remarks'] ?? '',
          'color': List<int>.from(course['color'] ?? [0, 0, 0]),
          'times': (course['times'] as List?)?.map((time) {
                if (time is List) {
                  return time.map((item) => item.toString()).toList();
                }
                return [];
              }).toList() ??
              [],
          'weeks': List<int>.from(course['weeks'] ?? []),
          'semester': course['semester'] ?? 1,
        };
      }).toList();

      return courses;
    } catch (e) {
      showMessage('加载课程数据失败');
      return [];
    }
  }

  /// 保存课程数据
  Future<bool> saveCourses(List<Map<String, dynamic>> courses) async {
    try {
      await CourseStorageHive.saveCourses(courses);
      return true;
    } catch (e) {
      showMessage('保存课程数据失败');
      return false;
    }
  }

  /// 删除所有课程
  Future<bool> deleteAllCourses() async {
    try {
      await CourseStorageHive.deleteCourses();
      return true;
    } catch (e) {
      showMessage('删除课程数据失败');
      return false;
    }
  }

  /// 添加新课程
  Future<bool> addCourses(List<Map<String, dynamic>> currentCourses,
      List<Map<String, dynamic>> newCourses) async {
    try {
      // 添加新课程到当前课程列表
      currentCourses.addAll(newCourses);

      // 保存到存储
      await CourseStorageHive.saveCourses(currentCourses);

      // 调用setState强制更新UI
      setState(() {
        // 课程已添加到列表，这里只需触发UI刷新
      });

      showMessage('成功添加 ${newCourses.length} 门课程', isError: false);
      return true;
    } catch (e) {
      showMessage('添加课程失败，请重试');
      return false;
    }
  }

  /// 更新课程
  Future<bool> updateCourse(List<Map<String, dynamic>> courses,
      Map<String, dynamic> updatedCourse) async {
    try {
      final index = courses.indexWhere((c) =>
          c['courseName'] == updatedCourse['originalCourseName'] &&
          c['semester'] == updatedCourse['semester']);

      if (index != -1) {
        // 创建更新后的课程数据（不包含 originalCourseName）
        final courseToUpdate = Map<String, dynamic>.from(updatedCourse)
          ..remove('originalCourseName');

        // 更新课程列表中的数据
        courses[index] = courseToUpdate;

        // 保存到存储
        await CourseStorageHive.saveCourses(courses);

        // 调用setState强制更新UI，确保颜色等变化立即显示
        setState(() {
          // 状态已在列表中更新，这里只需触发UI刷新
        });

        showMessage('课程更新成功', isError: false);
        return true;
      } else {
        showMessage('找不到要更新的课程');
        return false;
      }
    } catch (e) {
      showMessage('更新课程失败');
      return false;
    }
  }

  /// 删除课程
  Future<bool> deleteCourse(
      List<Map<String, dynamic>> courses, Map<String, dynamic> course) async {
    try {
      courses.removeWhere((c) =>
          c['courseName'] == course['courseName'] &&
          c['semester'] == course['semester']);

      await CourseStorageHive.saveCourses(courses);

      // 也在这里添加setState调用，确保删除后UI立即更新
      setState(() {});

      showMessage('课程删除成功', isError: false);
      return true;
    } catch (e) {
      showMessage('删除课程失败');
      return false;
    }
  }
}
