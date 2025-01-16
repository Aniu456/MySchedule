/// 时间工具类
/// 提供课程时间相关的转换、验证和格式化功能
class TimeUtils {
  /// 星期转换映射（中文 -> 数字）
  static const Map<String, int> dayToNumber = {
    '周一': 1,
    '周二': 2,
    '周三': 3,
    '周四': 4,
    '周五': 5,
    '周六': 6,
    '周日': 7,
  };

  /// 星期转换映射（数字 -> 中文）
  static const Map<int, String> numberToDay = {
    1: '周一',
    2: '周二',
    3: '周三',
    4: '周四',
    5: '周五',
    6: '周六',
    7: '周日',
  };

  /// 节次转换映射（中文 -> 数字）
  static const Map<String, int> classToNumber = {
    '第一节': 1,
    '第二节': 2,
    '第三节': 3,
    '第四节': 4,
    '第五节': 5,
    '第六节': 6,
    '第七节': 7,
    '第八节': 8,
    '第九节': 9,
    '第十节': 10,
  };

  /// 节次转换映射（数字 -> 中文）
  static const Map<int, String> numberToClass = {
    1: '第一节',
    2: '第二节',
    3: '第三节',
    4: '第四节',
    5: '第五节',
    6: '第六节',
    7: '第七节',
    8: '第八节',
    9: '第九节',
    10: '第十节',
  };

  /// 将星期字符串转换为数字
  /// 例如：'周一' -> 1
  static int getDayValue(String day) => dayToNumber[day] ?? 0;

  /// 将数字转换为星期字符串
  /// 例如：1 -> '周一'
  static String getDayString(int number) => numberToDay[number] ?? '';

  /// 将节次字符串转换为数字
  /// 支持直接数字字符串和中文格式
  /// 例如：'第一节' -> 1, '1' -> 1
  static int getClassValue(String classTime) {
    final number = int.tryParse(classTime);
    if (number != null) return number;
    return classToNumber[classTime] ?? 0;
  }

  /// 将数字转换为节次字符串
  /// 例如：1 -> '第一节'
  static String getClassString(int number) => numberToClass[number] ?? '';

  /// 检查时间范围是否有效
  /// [start]: 开始节次（1-10）
  /// [end]: 结束节次（1-10）
  /// 返回：时间范围是否有效
  static bool isValidTimeRange(int start, int end) =>
      start > 0 && end > 0 && start <= end && end <= 10;

  /// 检查两个时间段是否存在冲突
  /// [existingTimes]: 已有的时间段列表
  /// [existingWeeks]: 已有的周次列表
  /// [newTimes]: 新的时间段列表
  /// [newWeeks]: 新的周次列表
  /// 返回：是否存在时间冲突
  static bool hasTimeConflict(
    List<List<dynamic>> existingTimes,
    List<int> existingWeeks,
    List<List<dynamic>> newTimes,
    List<int> newWeeks,
  ) {
    // 检查周次是否有重叠
    if (!existingWeeks.any((week) => newWeeks.contains(week))) return false;

    // 检查时间是否有重叠
    for (var existingTime in existingTimes) {
      if (existingTime.length < 3) continue;

      for (var newTime in newTimes) {
        if (newTime.length < 3) continue;

        // 如果不是同一天，继续检查下一个时间
        if (getDayValue(existingTime[0].toString()) !=
            getDayValue(newTime[0].toString())) {
          continue;
        }

        // 转换时间为整数进行比较
        final existingStart = getClassValue(existingTime[1].toString());
        final existingEnd = getClassValue(existingTime[2].toString());
        final newStart = getClassValue(newTime[1].toString());
        final newEnd = getClassValue(newTime[2].toString());

        // 检查时间是否有效
        if (!isValidTimeRange(existingStart, existingEnd) ||
            !isValidTimeRange(newStart, newEnd)) {
          continue;
        }

        // 检查时间是否重叠
        if (!(newEnd < existingStart || newStart > existingEnd)) {
          return true;
        }
      }
    }

    return false;
  }

  /// 格式化时间范围显示
  /// 输入格式：['周一', '1', '2'] 或 ['周一', '第一节', '第二节']
  /// 输出格式：'周一 1-2节'
  static String formatTimeRange(List<dynamic> time) {
    if (time.length < 3) return '';

    final start = getClassValue(time[1].toString());
    final end = getClassValue(time[2].toString());

    if (!isValidTimeRange(start, end)) return '';

    return '${time[0]} $start-$end节';
  }
}
