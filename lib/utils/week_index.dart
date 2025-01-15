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
    week -= 1; // 计算当前周前的周数
    var date = DateTime.now();
    // 将当前日期向前移动指定周数
    date = date.subtract(Duration(days: week * 7));

    // 获取该周周一零点的时间
    date = date.subtract(Duration(
      days: date.weekday - 1, // 获取周一
      hours: date.hour, // 将小时归零
      minutes: date.minute, // 将分钟归零
      seconds: date.second, // 将秒归零
    ));
  }
}
