/// 该类维护当前是第几周
class WeekIndex {
  // static late int curWeek;
  static int curWeek = 1;

  /// 初始化周索引
  static Future<void> init() async {
    await _setWeekIndex(1);
  }

  /// 更新当前周索引
  static Future<void> update(int week) async {
    await _setWeekIndex(week); // 设置新的周索引
    // curWeek = await _getWeekIndex(); // 更新 curWeek
  }

  /// 设置周数的锚点，锚点为第一周的周一零点
  static Future<void> _setWeekIndex(int week) async {
    assert(week >= 1); // 确保周数大于等于1

    // 获取当前日期
    final now = DateTime.now();
    // 设置当前周数
    curWeek = week;

    // 记录当前日期（用于后续日期差计算）
    final today = DateTime(now.year, now.month, now.day);
  }
}
