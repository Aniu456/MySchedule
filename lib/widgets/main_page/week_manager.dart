//周次管理逻辑
class WeekManager {
  /// 计算当前周次
  /// 基于学期开始日期（9月1日）计算
  static int calculateCurrentWeek() {
    final now = DateTime.now();
    final currentYear = now.year;

    // 学期开始日期（假设每年9月1日开始）
    DateTime startOfWeek;
    if (now.month >= 9) {
      // 如果当前月份是9月或之后，学期开始日期是今年的9月1日
      startOfWeek = DateTime(currentYear, 9, 1);
    } else {
      // 如果当前月份是1月到8月，学期开始日期是上一年的9月1日
      startOfWeek = DateTime(currentYear - 1, 9, 1);
    }

    // 计算日期差值
    final difference = now.difference(startOfWeek).inDays;

    // 计算当前周次
    final currentWeek = (difference ~/ 7) + 1;

    // 确保周次不为负数
    return currentWeek > 0 ? currentWeek : 1;
  }

  /// 获取格式化的当前日期
  static String getFormattedDate() {
    final date = DateTime.now();
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 获取指定周的日期范围
  static List<DateTime> getWeekDates(int week) {
    final now = DateTime.now();
    final year = now.month >= 9 ? now.year : now.year - 1;
    var semesterStart = DateTime(year, 9, 1);

    // 如果学期开始日期是周六或周日，则从下周一开始
    while (semesterStart.weekday >= 6) {
      semesterStart = semesterStart.add(const Duration(days: 1));
    }

    // 计算当前显示周的第一天
    final weekStart = semesterStart.add(Duration(days: (week - 1) * 7));

    // 返回这一周的所有日期
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  /// 检查是否应该显示返回按钮
  static bool shouldShowGoBack(int currentWeek) {
    DateTime now = DateTime.now();
    DateTime semesterStart = DateTime(now.year, 9, 1); // 假设学期从9月1日开始
    return now.isAfter(semesterStart) && currentWeek > 1;
  }
}
