import 'package:lunar/lunar.dart';
import '../utils/course_storage_hive.dart';

/// 学期时间工具类
class SemesterUtils {
  /// 获取学期开始时间
  /// [semester] 学期号（1-10）
  /// 如果用户设置了自定义开始时间，则使用自定义时间
  /// 否则使用默认计算方式
  static Future<DateTime> getSemesterStartDate(int semester) async {
    // 尝试获取用户自定义的学期开始时间
    DateTime? customStartDate =
        await CourseStorageHive.getSemesterStartDate(semester);

    // 如果存在自定义时间，直接返回
    if (customStartDate != null) {
      return customStartDate;
    }

    // 没有自定义时间，使用默认计算方式
    return await _getDefaultSemesterStartDate(semester);
  }

  /// 默认的学期开始时间计算方法
  static Future<DateTime> _getDefaultSemesterStartDate(int semester) async {
    // 确保学期编号在有效范围内
    if (semester < 1 || semester > 10) {
      semester = semester.clamp(1, 10);
    }

    // 计算基准年份（2023开始）
    int baseYear = 2023;
    int yearOffset = (semester - 1) ~/ 2;
    int year = baseYear + yearOffset;
    DateTime defaultDate;

    // 判断是否是双数学期（春季学期）
    final bool isSpring = semester % 2 == 0;

    if (isSpring) {
      // 春季学期（双数学期）：使用元宵节后的第一个周一
      // 获取当年春节日期
      final springFestivalDate = _findSpringFestival(year);

      // 元宵节是正月十五，即春节后第15天
      final lanternFestivalDate =
          springFestivalDate.add(const Duration(days: 14));

      // 元宵节后的第一个周一
      defaultDate = lanternFestivalDate;
      while (defaultDate.weekday != DateTime.monday) {
        defaultDate = defaultDate.add(const Duration(days: 1));
      }
    } else {
      // 秋季学期（奇数学期）：从9月1日开始，调整到周一
      defaultDate = DateTime(year, 9, 1);

      // 如果第一天不是周一，调整到最近的周一
      int weekday = defaultDate.weekday;
      if (weekday > DateTime.monday) {
        // 如果是周二到周日，往前移动到上周一
        defaultDate = defaultDate.subtract(Duration(days: weekday - 1));
      }
    }

    return defaultDate;
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
  static Future<int> calculateCurrentWeek(int semester) async {
    final now = DateTime.now();
    final startDate = await getSemesterStartDate(semester);

    // 如果当前日期在学期开始日期之前，返回第1周
    if (now.isBefore(startDate)) {
      return 1;
    }

    // 计算周次差值
    final difference = now.difference(startDate).inDays;

    final currentWeek = (difference ~/ 7) + 1;

    // 限制最大周数为20
    final result = currentWeek > 20 ? 20 : (currentWeek > 0 ? currentWeek : 1);
    return result;
  }

  /// 获取指定周的日期范围
  static Future<List<DateTime>> getWeekDates(int semester, int week) async {
    // 获取学期开始日期
    final startDate = await getSemesterStartDate(semester);

    // 计算指定周的起始日期（周一）
    final weekStart = startDate.add(Duration(days: (week - 1) * 7));

    // 返回从周一开始的7天日期
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

  /// 自动计算当前学期
  static Future<int> getCurrentSemester() async {
    final now = DateTime.now();

    // 获取所有已配置的学期
    List<int> configuredSemesters = [];
    for (int i = 1; i <= 10; i++) {
      if (await CourseStorageHive.hasSemesterStartDate(i)) {
        configuredSemesters.add(i);
      }
    }

    if (configuredSemesters.isEmpty) {
      return 1; // 默认返回第一学期
    }

    // 按顺序处理学期
    configuredSemesters.sort();

    // 查找当前日期所在的学期
    // 将所有学期按开始日期排序，找到第一个开始日期大于当前日期的学期
    // 上一个学期就是当前所在学期
    int currentSemester = configuredSemesters.first;

    for (int i = 0; i < configuredSemesters.length; i++) {
      int sem = configuredSemesters[i];
      DateTime? startDate = await CourseStorageHive.getSemesterStartDate(sem);

      if (startDate == null) continue;

      // 如果是最后一个学期或当前日期在这个学期的开始日期之后但在下一个学期之前
      if (i == configuredSemesters.length - 1) {
        if (now.isAfter(startDate) || now.isAtSameMomentAs(startDate)) {
          currentSemester = sem;
        }
      } else {
        int nextSem = configuredSemesters[i + 1];
        DateTime? nextStartDate =
            await CourseStorageHive.getSemesterStartDate(nextSem);

        if (nextStartDate == null) continue;

        if ((now.isAfter(startDate) || now.isAtSameMomentAs(startDate)) &&
            now.isBefore(nextStartDate)) {
          currentSemester = sem;
          break;
        }
      }
    }

    return currentSemester;
  }

  /// 计算当前周次（基于实际日期）
  static Future<int> calculateActualCurrentWeek(int semester) async {
    final now = DateTime.now();
    final startDate = await getSemesterStartDate(semester);

    // 如果当前日期在学期开始日期之前，返回第1周
    if (now.isBefore(startDate)) {
      return 1;
    }

    // 计算周次差值
    final difference = now.difference(startDate).inDays;
    final currentWeek = (difference ~/ 7) + 1;

    // 限制最大周数为20
    return currentWeek > 20 ? 20 : (currentWeek > 0 ? currentWeek : 1);
  }

  /// 返回"今天"应该显示的学期和周次
  static Future<(int, int)> getTodayInfo() async {
    // 获取当前学期
    final semester = await getCurrentSemester();

    // 计算当前学期的当前周次
    final week = await calculateActualCurrentWeek(semester);

    return (semester, week);
  }

  /// 设置学期开始日期
  static Future<void> setSemesterStartDate(
      int semester, DateTime startDate) async {
    await CourseStorageHive.saveSemesterStartDate(semester, startDate);
  }

  /// 获取指定学期的名称（第x学期）
  static String getSemesterName(int semester) {
    return '第$semester学期';
  }

  /// 估计当前日期应该处于哪个学期
  /// 如果学期未设置，返回需要设置的学期号和null
  /// 如果学期已设置，返回学期号和当前周次
  static Future<(int, int?)> estimateCurrentSemesterAndWeek() async {
    final now = DateTime.now();

    // 获取第一学期开始日期（必须已设置）
    DateTime? firstSemesterDate =
        await CourseStorageHive.getSemesterStartDate(1);
    if (firstSemesterDate == null) {
      // 如果第一学期未设置，需要设置第一学期
      return (1, null);
    }

    // 计算从第一学期开始到现在过了多少学期
    // 假设每学期20周，一年2个学期（秋季和春季）

    // 计算大致的时间差（单位：天）
    int daysSinceFirstSemester = now.difference(firstSemesterDate).inDays;
    if (daysSinceFirstSemester < 0) {
      // 当前日期在第一学期开始之前，还是第一学期
      return (1, 1);
    }

    // 计算大致的学期数（假设每学期20周 = 140天）
    int semestersSinceFirst = (daysSinceFirstSemester / 140).floor();
    int estimatedSemester = 1 + semestersSinceFirst;

    // 限制学期范围（1-10）
    if (estimatedSemester > 10) {
      estimatedSemester = 10;
    } else if (estimatedSemester < 1) {
      estimatedSemester = 1;
    }

    // 检查估计的学期是否已设置开始日期
    bool hasSemesterDate =
        await CourseStorageHive.hasSemesterStartDate(estimatedSemester);

    if (hasSemesterDate) {
      // 如果学期已设置，计算当前周次
      DateTime? semesterStartDate =
          await CourseStorageHive.getSemesterStartDate(estimatedSemester);
      if (semesterStartDate != null) {
        int daysSinceStart = now.difference(semesterStartDate).inDays;
        int currentWeek = (daysSinceStart / 7).floor() + 1;

        // 限制周次范围（1-20）
        if (currentWeek < 1) currentWeek = 1;
        if (currentWeek > 20) currentWeek = 20;

        return (estimatedSemester, currentWeek);
      }
    }

    // 学期未设置，需要设置该学期
    return (estimatedSemester, null);
  }
}
