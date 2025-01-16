class TimeUtils {
  static const Map<String, int> dayToNumber = {
    '周一': 1,
    '周二': 2,
    '周三': 3,
    '周四': 4,
    '周五': 5,
    '周六': 6,
    '周日': 7,
  };

  static const Map<int, String> numberToDay = {
    1: '周一',
    2: '周二',
    3: '周三',
    4: '周四',
    5: '周五',
    6: '周六',
    7: '周日',
  };

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

  static int getDayValue(String day) {
    return dayToNumber[day] ?? 0;
  }

  static String getDayString(int number) {
    return numberToDay[number] ?? '';
  }

  static int getClassValue(String classTime) {
    if (int.tryParse(classTime) != null) {
      return int.parse(classTime);
    }
    return classToNumber[classTime] ?? 0;
  }

  static String getClassString(int number) {
    return numberToClass[number] ?? '';
  }

  static bool isValidTimeRange(int start, int end) {
    return start > 0 && end > 0 && start <= end && end <= 10;
  }

  static bool hasTimeConflict(
    List<List<dynamic>> existingTimes,
    List<int> existingWeeks,
    List<List<dynamic>> newTimes,
    List<int> newWeeks,
  ) {
    // 检查周次是否有重叠
    bool hasWeekOverlap = existingWeeks.any((week) => newWeeks.contains(week));
    if (!hasWeekOverlap) return false;

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
        int existingStart = getClassValue(existingTime[1].toString());
        int existingEnd = getClassValue(existingTime[2].toString());
        int newStart = getClassValue(newTime[1].toString());
        int newEnd = getClassValue(newTime[2].toString());

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

  static String formatTimeRange(List<dynamic> time) {
    if (time.length < 3) return '';

    final start = getClassValue(time[1].toString());
    final end = getClassValue(time[2].toString());

    if (!isValidTimeRange(start, end)) return '';

    return '${time[0]} $start-$end节';
  }
}
