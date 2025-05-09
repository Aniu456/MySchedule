import '../../utils/semester_utils.dart';

/// 周次管理逻辑
class WeekManager {
  /// 计算当前周次
  static Future<int> calculateCurrentWeek(int semester) async {
    return SemesterUtils.calculateCurrentWeek(semester);
  }

  /// 获取当前学期
  static Future<int> getCurrentSemester() async {
    return SemesterUtils.getCurrentSemester();
  }

  /// 获取格式化的当前日期
  static String getFormattedDate() {
    final date = DateTime.now();
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 获取指定周的日期范围
  static Future<List<DateTime>> getWeekDates(int semester, int week) async {
    return SemesterUtils.getWeekDates(semester, week);
  }
}
