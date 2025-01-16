import 'package:flutter/material.dart';
import '../utils/time_utils.dart';
import 'course_info.dart';
import 'main_page/week_manager.dart';

/// 课程表组件
/// 显示一周的课程安排，支持显示/隐藏周末、时间槽和网格
class CourseTable extends StatelessWidget {
  /// 固定的时间槽
  static const List<List<String>> _timeSlots = [
    ["8:20", "9:05"], // 第1节
    ["9:15", "10:00"], // 第2节
    ["10:20", "11:05"], // 第3节
    ["11:15", "12:00"], // 第4节
    ["14:00", "14:45"], // 第5节
    ["14:55", "15:40"], // 第6节
    ["15:50", "16:35"], // 第7节
    ["16:45", "17:30"], // 第8节
    ["19:30", "20:15"], // 第9节
    ["20:25", "21:10"], // 第10节
  ];

  /// 当前周次
  final int week;

  /// 当前学期
  final int currentSemester;

  /// 是否显示周末
  final bool showWeekend;

  /// 是否显示时间槽
  final bool showTimeSlots;

  /// 是否显示网格
  final bool showGrid;

  /// 主题色
  final Color themeColor;

  /// 课程数据
  final List<Map<String, dynamic>> courses;

  /// 课程更新回调
  final Function(Map<String, dynamic>) onCourseUpdated;

  /// 课程删除回调
  final Function(Map<String, dynamic>) onCourseDeleted;

  const CourseTable({
    super.key,
    required this.week,
    required this.currentSemester,
    this.showWeekend = false,
    this.showTimeSlots = false,
    this.showGrid = true,
    this.themeColor = Colors.teal,
    required this.courses,
    required this.onCourseUpdated,
    required this.onCourseDeleted,
  });

  /// 构建时间列
  Widget _buildTimeColumn() {
    return SizedBox(
      width: showTimeSlots ? 45.0 : 30.0,
      child: Column(
        children: List.generate(10, (index) {
          return SizedBox(
            height: 60.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showTimeSlots) ...[
                  Text(
                    _timeSlots[index][0],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    _timeSlots[index][1],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 构建表头
  Widget _buildHeader(List<DateTime> dates) {
    const weekdays = ["一", "二", "三", "四", "五", "六", "日"];
    final visibleDays = showWeekend ? weekdays : weekdays.sublist(0, 5);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Container(
            width: showTimeSlots ? 45.0 : 30.0,
            alignment: Alignment.center,
            child: const Text(
              '日期',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          ...List.generate(visibleDays.length, (index) {
            final date = dates[index];
            final isToday = _isToday(date);

            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '周${visibleDays[index]}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.month}/${date.day}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isToday ? Colors.red : Colors.grey,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 构建课程单元格
  Widget _buildCourseCell(Map<String, dynamic>? course, BuildContext context) {
    if (course == null) return Container();

    // 检查课程是否在当前周显示
    if (!List<int>.from(course['weeks'] ?? []).contains(week)) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          course['color'][0],
          course['color'][1],
          course['color'][2],
          1,
        ),
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(
            color: Colors.white24,
            // blurRadius: 2,
            // offset: Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => showCourseInfo(
          context,
          course,
          themeColor: themeColor,
          onCourseUpdated: onCourseUpdated,
          onCourseDeleted: onCourseDeleted,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['courseName'] ?? '未输入课程名',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: showWeekend ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (course['teacherName']?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '@${course['teacherName']}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: showWeekend ? 11 : 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Text(
              _formatWeeks(List<int>.from(course['weeks'] ?? [])),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: showWeekend ? 10 : 13,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化周次显示
  String _formatWeeks(List<int> weeks) {
    if (weeks.isEmpty) return '';

    weeks.sort();
    List<String> ranges = [];
    int start = weeks.first;
    int end = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        end = weeks[i];
      } else {
        ranges.add(start == end ? '$start' : '$start-$end周');
        start = weeks[i];
        end = weeks[i];
      }
    }
    ranges.add(start == end ? '$start' : '$start-$end周');

    return ranges.join(', ');
  }

  /// 检查是否是今天
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 获取课程开始时间
  int _getStartTime(List<dynamic> times, int col) {
    var time = times.firstWhere(
      (time) => TimeUtils.getDayValue(time[0].toString()) == col + 1,
      orElse: () => List<dynamic>.empty(),
    );
    if (time is! List || time.isEmpty) return 999;
    return TimeUtils.getClassValue(time[1].toString());
  }

  /// 构建课程格子列表
  List<Widget> _buildCourseCells(
    List<Map<String, dynamic>> columnCourses,
    int col,
    BuildContext context,
  ) {
    List<Widget> cells = [];
    Set<int> occupiedSlots = {};

    // 按开始时间排序课程
    columnCourses.sort((a, b) {
      int aStart = _getStartTime(a['times'], col);
      int bStart = _getStartTime(b['times'], col);
      return aStart.compareTo(bStart);
    });

    for (int row = 0; row < 10; row++) {
      if (occupiedSlots.contains(row)) continue;

      Map<String, dynamic>? courseForThisSlot;
      List<dynamic>? courseTime;

      // 查找当前时间段的课程
      for (var course in columnCourses) {
        var time = course['times'].firstWhere((time) {
          if (time is! List || time.length < 3) return false;
          if (TimeUtils.getDayValue(time[0].toString()) != col + 1)
            return false;

          int startClass = TimeUtils.getClassValue(time[1].toString());
          int endClass = TimeUtils.getClassValue(time[2].toString());

          if (!TimeUtils.isValidTimeRange(startClass, endClass)) return false;

          return row + 1 >= startClass && row + 1 <= endClass;
        }, orElse: () => List<dynamic>.empty());

        if (time is List && time.isNotEmpty) {
          courseForThisSlot = course;
          courseTime = time;
          break;
        }
      }

      if (courseForThisSlot != null && courseTime != null) {
        int startClass = TimeUtils.getClassValue(courseTime[1].toString());
        int endClass = TimeUtils.getClassValue(courseTime[2].toString());
        int duration = endClass - startClass + 1;

        // 标记被占用的时间段
        for (int i = startClass - 1; i < endClass; i++) {
          occupiedSlots.add(i);
        }

        cells.add(Container(
          height: 60.0 * duration,
          decoration: BoxDecoration(
            border: showGrid
                ? Border.all(color: Colors.grey[200]!)
                : Border.all(color: Colors.transparent),
          ),
          child: _buildCourseCell(courseForThisSlot, context),
        ));
      } else {
        cells.add(Container(
          height: 60.0,
          decoration: BoxDecoration(
            border: showGrid
                ? Border.all(color: Colors.grey[200]!)
                : Border.all(color: Colors.transparent),
          ),
        ));
      }
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final dates = WeekManager.getWeekDates(currentSemester, week);
    debugPrint(
        '周次: $week, 日期: ${dates.map((d) => '${d.month}/${d.day}').join(', ')}');

    return Column(
      children: [
        _buildHeader(dates),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumn(),
                Expanded(
                  child: Row(
                    children: List.generate(showWeekend ? 7 : 5, (col) {
                      // 获取这一列的所有课程
                      final columnCourses = courses.where((course) {
                        if (course['semester'] != currentSemester) return false;
                        if (!course['weeks'].contains(week)) return false;

                        return course['times'].any((time) {
                          if (time is! List || time.length < 3) return false;
                          final dayNum =
                              TimeUtils.getDayValue(time[0].toString());
                          return dayNum == col + 1;
                        });
                      }).toList();

                      return SizedBox(
                        width: (MediaQuery.of(context).size.width -
                                (showTimeSlots ? 45.0 : 30.0)) /
                            (showWeekend ? 7 : 5),
                        child: Column(
                          children:
                              _buildCourseCells(columnCourses, col, context),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
