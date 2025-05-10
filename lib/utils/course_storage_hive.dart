import 'package:hive_flutter/hive_flutter.dart';

/// 课程存储管理类，使用Hive作为本地数据存储
class CourseStorageHive {
  static const String _boxName = 'courses';
  static const String _coursesKey = 'coursesList';
  static const String _semesterKey = 'current_semester';
  static const String _semesterStartDatePrefix = 'semester_start_date_';
  static const String _weekTemplatesKey = 'week_templates';

  static const int _minSemester = 1;
  static const int _maxSemester = 10;
  static const int _maxWeekTemplates = 6;

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
      _instance!._box = Hive.isBoxOpen(_boxName)
          ? Hive.box(_boxName)
          : await Hive.openBox(_boxName);
    }
    return _instance!;
  }

  // 检查学期是否在有效范围内
  static bool _isValidSemester(int semester) =>
      semester >= _minSemester && semester <= _maxSemester;

  // 确保学期在有效范围内
  static int _normalizeSemester(int semester) =>
      semester.clamp(_minSemester, _maxSemester);

  /// 保存任意键值对 - 通用方法
  Future<void> _put(String key, dynamic value) async =>
      await _box.put(key, value);

  /// 获取任意值 - 通用方法
  T? _get<T>(String key, {T? defaultValue}) =>
      _box.get(key, defaultValue: defaultValue) as T?;

  /// 删除任意键 - 通用方法
  Future<void> _delete(String key) async => await _box.delete(key);

  /// 保存课程列表
  Future<void> _saveCourses(List<Map<String, dynamic>> courses) async =>
      await _put(_coursesKey, courses);

  /// 获取课程列表
  List<Map> _getCourses() {
    final dynamic coursesData = _get<dynamic>(_coursesKey);
    if (coursesData == null) return [];

    return List<Map>.from(coursesData).map((course) {
      // 确保 weeks 和 color 是 List<int>
      return {
        ...course,
        'weeks': List<int>.from(course['weeks'] ?? []),
        'color': List<int>.from(course['color'] ?? []),
      };
    }).toList();
  }

  /// 删除所有课程
  Future<void> _deleteCourses() async => await _delete(_coursesKey);

  /// 保存当前学期
  Future<void> _saveSemester(int semester) async =>
      await _put(_semesterKey, _normalizeSemester(semester));

  /// 获取当前学期
  int _getSemester() =>
      _normalizeSemester(_get<int>(_semesterKey) ?? _minSemester);

  /// 生成学期开始日期的键
  String _getSemesterDateKey(int semester) =>
      '$_semesterStartDatePrefix$semester';

  /// 保存学期开始日期
  Future<void> _saveSemesterStartDate(int semester, DateTime startDate) async {
    if (!_isValidSemester(semester)) return;
    await _put(_getSemesterDateKey(semester), startDate.millisecondsSinceEpoch);
  }

  /// 获取学期开始日期
  DateTime? _getSemesterStartDate(int semester) {
    if (!_isValidSemester(semester)) return null;
    final timestamp = _get<int>(_getSemesterDateKey(semester));
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// 检查学期开始日期是否已设置
  bool _hasSemesterStartDate(int semester) {
    if (!_isValidSemester(semester)) return false;
    return _box.containsKey(_getSemesterDateKey(semester));
  }

  /// 保存周次模板
  Future<void> _saveWeekTemplate(List<int> weeks) async {
    if (weeks.isEmpty) return;

    // 获取现有模板
    List<List<int>> templates = _getWeekTemplates();

    // 检查是否已存在相同模板
    bool alreadyExists = templates.any((template) =>
        template.length == weeks.length &&
        template.every((week) => weeks.contains(week)));

    // 如果已存在，不再添加
    if (alreadyExists) return;

    // 添加新模板，保持最多6个
    templates.add(List<int>.from(weeks));
    if (templates.length > _maxWeekTemplates) {
      templates.removeAt(0); // 移除最旧的一个
    }

    await _put(_weekTemplatesKey, templates);
  }

  /// 获取周次模板列表
  List<List<int>> _getWeekTemplates() {
    final dynamic data = _get<dynamic>(_weekTemplatesKey);
    if (data == null) return [];

    try {
      return (data as List).map((item) => List<int>.from(item)).toList();
    } catch (_) {
      return [];
    }
  }

  /// 清除所有周次模板
  Future<void> _clearWeekTemplates() async => await _delete(_weekTemplatesKey);

  /// 清除无效的学期数据
  Future<void> _clearInvalidSemesterData() async {
    // 查找无效的键
    final invalidKeys = _box.keys
        .whereType<String>()
        .where((key) => key.startsWith(_semesterStartDatePrefix))
        .where((key) {
      try {
        final semesterString = key.replaceFirst(_semesterStartDatePrefix, '');
        final semester = int.parse(semesterString);
        return !_isValidSemester(semester);
      } catch (_) {
        return true; // 解析失败的键也视为无效
      }
    }).toList();

    // 批量删除
    for (final key in invalidKeys) {
      await _delete(key);
    }

    // 确保当前学期有效
    await _saveSemester(_getSemester());
  }

  // 静态方法包装器
  static Future<T> _use<T>(Future<T> Function(CourseStorageHive) action) async {
    final instance = await getInstance();
    return await action(instance);
  }

  // 暴露的公共静态API
  static Future<void> saveCourses(List<Map<String, dynamic>> courses) =>
      _use((instance) => instance._saveCourses(courses));

  static Future<List<Map>> getCourses() =>
      _use((instance) async => instance._getCourses());

  static Future<void> deleteCourses() =>
      _use((instance) => instance._deleteCourses());

  static Future<void> saveSemester(int semester) =>
      _use((instance) => instance._saveSemester(semester));

  static Future<int> getSemester() =>
      _use((instance) async => instance._getSemester());

  static Future<void> saveSemesterStartDate(int semester, DateTime startDate) =>
      _use((instance) => instance._saveSemesterStartDate(semester, startDate));

  static Future<DateTime?> getSemesterStartDate(int semester) =>
      _use((instance) async => instance._getSemesterStartDate(semester));

  static Future<bool> hasSemesterStartDate(int semester) =>
      _use((instance) async => instance._hasSemesterStartDate(semester));

  static Future<void> clearInvalidSemesterData() =>
      _use((instance) => instance._clearInvalidSemesterData());

  static Future<void> saveWeekTemplate(List<int> weeks) =>
      _use((instance) => instance._saveWeekTemplate(weeks));

  static Future<List<List<int>>> getWeekTemplates() =>
      _use((instance) async => instance._getWeekTemplates());

  static Future<void> clearWeekTemplates() =>
      _use((instance) => instance._clearWeekTemplates());
}
