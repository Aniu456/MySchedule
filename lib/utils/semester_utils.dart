import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';

/// 学期时间工具类
class SemesterUtils {
  /// 获取学期开始时间
  /// [semester] 学期号（1-10）
  /// 奇数学期（秋季）从9月1日开始
  /// 偶数学期（春季）从元宵节后的下一个周一开始
  static DateTime getSemesterStartDate(int semester) {
    final now = DateTime.now();
    final currentYear = now.year;

    // 如果是奇数学期（秋季学期）
    if (semester % 2 == 1) {
      // 计算学期对应的年份
      final yearOffset = (semester - 1) ~/ 2;
      final year = now.month >= 9
          ? currentYear + yearOffset
          : currentYear + yearOffset - 1;
      debugPrint('秋季学期 $semester: $year 年');

      // 获取9月1日
      var sept1 = DateTime(year, 9, 1);
      var weekday = sept1.weekday;

      // 如果9月1日是周末，开学日期设为下周一
      if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
        var daysUntilMonday = (8 - weekday) % 7;
        sept1 = sept1.add(Duration(days: daysUntilMonday));
      }
      // 如果9月1日是周二到周五，开学日期设为本周一
      else if (weekday > DateTime.monday) {
        sept1 = sept1.subtract(Duration(days: weekday - 1));
      }
      // 如果9月1日是周一，保持不变

      debugPrint(
          '开学日期: ${sept1.year}年${sept1.month}月${sept1.day}日 周${sept1.weekday}');
      return sept1;
    }
    // 偶数学期（春季学期）
    else {
      // 计算学期对应的年份
      final yearOffset = (semester - 2) ~/ 2;
      final year = now.month < 9
          ? currentYear + yearOffset
          : currentYear + yearOffset + 1;
      debugPrint('春季学期 $semester: $year 年');

      // 计算元宵节日期（农历正月十五）
      var springFestival = _findSpringFestival(year);
      var lanternFestival = springFestival.add(const Duration(days: 14));

      // 获取元宵节后的下一个周一
      var startDate = lanternFestival;
      while (startDate.weekday != DateTime.monday) {
        startDate = startDate.add(const Duration(days: 1));
      }
      return startDate;
    }
  }

  /// 查找指定年份的春节日期
  static DateTime _findSpringFestival(int year) {
    // 春节一般在1月21日到2月20日之间
    // 我们从1月21日开始查找
    var date = DateTime(year, 1, 21);
    final solar = Solar.fromYmd(date.year, date.month, date.day);
    var lunar = Lunar.fromSolar(solar);

    // 如果不是正月初一，继续查找
    while (!(lunar.getMonth() == 1 && lunar.getDay() == 1)) {
      date = date.add(const Duration(days: 1));
      final nextSolar = Solar.fromYmd(date.year, date.month, date.day);
      lunar = Lunar.fromSolar(nextSolar);
    }

    return date;
  }

  /// 计算当前周次
  static int calculateCurrentWeek(int semester) {
    final now = DateTime.now();
    final startDate = getSemesterStartDate(semester);

    // 如果当前日期在学期开始日期之前，返回第1周
    if (now.isBefore(startDate)) {
      return 1;
    }

    // 计算周次差值
    final difference = now.difference(startDate).inDays;
    final currentWeek = (difference ~/ 7) + 1;

    return currentWeek > 0 ? currentWeek : 1;
  }

  /// 获取指定周的日期范围
  static List<DateTime> getWeekDates(int semester, int week) {
    final startDate = getSemesterStartDate(semester);
    final weekStart = startDate.add(Duration(days: (week - 1) * 7));
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  /// 获取农历日期字符串
  static String getLunarDateString(DateTime date) {
    final solar = Solar.fromYmd(date.year, date.month, date.day);
    final lunar = Lunar.fromSolar(solar);
    return '农历${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}';
  }

  /// 获取元宵节日期
  static DateTime getLanternFestival(int year) {
    var springFestival = _findSpringFestival(year);
    return springFestival.add(const Duration(days: 14));
  }
}
