import 'package:hive_flutter/hive_flutter.dart';

class CourseStorageHive {
  static const String _boxName = 'courses';
  static const String _coursesKey = 'coursesList';
  static const String _semesterKey = 'current_semester';

  // 确保Hive盒子已打开
  static Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  // 保存课程
  static Future<void> saveCourses(List<Map<String, dynamic>> courses) async {
    final box = await _getBox();
    await box.put(_coursesKey, courses);
  }

  // 获取课程
  static Future<List<Map>> getCourses() async {
    final box = await _getBox();
    final dynamic coursesData = box.get(_coursesKey);
    if (coursesData == null) return [];

    return List<Map>.from(coursesData).map((course) {
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
    final box = await _getBox();
    await box.delete(_coursesKey);
  }

  // 保存当前学期
  static Future<void> saveSemester(int semester) async {
    final box = await _getBox();
    await box.put(_semesterKey, semester);
  }

  // 获取当前学期
  static Future<int> getSemester() async {
    final box = await _getBox();
    final int semester = box.get(_semesterKey, defaultValue: 1);
    // 确保返回的学期值在有效范围内
    return semester.clamp(1, 10);
  }

  /// 保存学期开始日期
  static Future<void> saveSemesterStartDate(
      int semester, DateTime startDate) async {
    final box = await _getBox();
    await box.put(
        'semester_start_date_$semester', startDate.millisecondsSinceEpoch);
  }

  /// 获取学期开始日期
  static Future<DateTime?> getSemesterStartDate(int semester) async {
    final box = await _getBox();
    final timestamp = box.get('semester_start_date_$semester');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// 检查学期开始日期是否已设置
  static Future<bool> hasSemesterStartDate(int semester) async {
    final box = await _getBox();
    return box.containsKey('semester_start_date_$semester');
  }

  /// 清除无效的学期数据（超出1-10范围的数据）
  static Future<void> clearInvalidSemesterData() async {
    final box = await _getBox();

    // 获取所有键
    final keys = box.keys.toList();

    // 查找和删除所有无效的学期数据
    for (final key in keys) {
      if (key is String && key.startsWith('semester_start_date_')) {
        try {
          // 提取学期编号
          final semesterString = key.replaceFirst('semester_start_date_', '');
          final semester = int.parse(semesterString);

          // 如果学期编号超出范围，删除对应数据
          if (semester < 1 || semester > 10) {
            await box.delete(key);
          }
        } catch (e) {
          // 忽略解析错误
        }
      }
    }

    // 确保当前学期设置也在有效范围内
    final currentSemester = await getSemester();
    if (currentSemester < 1 || currentSemester > 10) {
      await saveSemester(currentSemester.clamp(1, 10));
    }
  }
}
