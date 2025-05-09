import 'package:hive_flutter/hive_flutter.dart';

/// 课程存储管理类，使用Hive作为本地数据存储
class CourseStorageHive {
  static const String _boxName = 'courses';
  static const String _coursesKey = 'coursesList';
  static const String _semesterKey = 'current_semester';

  // 单例实例
  static CourseStorageHive? _instance;
  // 缓存已打开的Box
  late Box _box;

  // 私有构造函数
  CourseStorageHive._();

  // 获取单例实例
  static Future<CourseStorageHive> getInstance() async {
    if (_instance == null) {
      _instance = CourseStorageHive._();
      await _instance!._init();
    }
    return _instance!;
  }

  // 初始化方法
  Future<void> _init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  // 保存课程 - 实例方法
  Future<void> _saveCourses(List<Map<String, dynamic>> courses) async {
    await _box.put(_coursesKey, courses);
  }

  // 获取课程 - 实例方法
  List<Map> _getCourses() {
    final dynamic coursesData = _box.get(_coursesKey);
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

  // 删除课程 - 实例方法
  Future<void> _deleteCourses() async {
    await _box.delete(_coursesKey);
  }

  // 保存当前学期 - 实例方法
  Future<void> _saveSemester(int semester) async {
    await _box.put(_semesterKey, semester);
  }

  // 获取当前学期 - 实例方法
  int _getSemester() {
    final int semester = _box.get(_semesterKey, defaultValue: 1);
    // 确保返回的学期值在有效范围内
    return semester.clamp(1, 10);
  }

  /// 保存学期开始日期 - 实例方法
  Future<void> _saveSemesterStartDate(int semester, DateTime startDate) async {
    await _box.put(
        'semester_start_date_$semester', startDate.millisecondsSinceEpoch);
  }

  /// 获取学期开始日期 - 实例方法
  DateTime? _getSemesterStartDate(int semester) {
    final timestamp = _box.get('semester_start_date_$semester');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// 检查学期开始日期是否已设置 - 实例方法
  bool _hasSemesterStartDate(int semester) {
    return _box.containsKey('semester_start_date_$semester');
  }

  /// 清除无效的学期数据 - 实例方法
  Future<void> _clearInvalidSemesterData() async {
    // 获取所有键
    final keys = _box.keys.toList();

    // 查找和删除所有无效的学期数据
    for (final key in keys) {
      if (key is String && key.startsWith('semester_start_date_')) {
        try {
          // 提取学期编号
          final semesterString = key.replaceFirst('semester_start_date_', '');
          final semester = int.parse(semesterString);

          // 如果学期编号超出范围，删除对应数据
          if (semester < 1 || semester > 10) {
            await _box.delete(key);
          }
        } catch (e) {
          // 忽略解析错误
        }
      }
    }

    // 确保当前学期设置也在有效范围内
    final currentSemester = _getSemester();
    if (currentSemester < 1 || currentSemester > 10) {
      await _saveSemester(currentSemester.clamp(1, 10));
    }
  }

  // 静态方法包装器，保持API兼容性
  static Future<void> saveCourses(List<Map<String, dynamic>> courses) async {
    final instance = await getInstance();
    await instance._saveCourses(courses);
  }

  static Future<List<Map>> getCourses() async {
    final instance = await getInstance();
    return instance._getCourses();
  }

  static Future<void> deleteCourses() async {
    final instance = await getInstance();
    await instance._deleteCourses();
  }

  static Future<void> saveSemester(int semester) async {
    final instance = await getInstance();
    await instance._saveSemester(semester);
  }

  static Future<int> getSemester() async {
    final instance = await getInstance();
    return instance._getSemester();
  }

  static Future<void> saveSemesterStartDate(
      int semester, DateTime startDate) async {
    final instance = await getInstance();
    await instance._saveSemesterStartDate(semester, startDate);
  }

  static Future<DateTime?> getSemesterStartDate(int semester) async {
    final instance = await getInstance();
    return instance._getSemesterStartDate(semester);
  }

  static Future<bool> hasSemesterStartDate(int semester) async {
    final instance = await getInstance();
    return instance._hasSemesterStartDate(semester);
  }

  static Future<void> clearInvalidSemesterData() async {
    final instance = await getInstance();
    await instance._clearInvalidSemesterData();
  }
}
