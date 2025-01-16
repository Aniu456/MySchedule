import 'package:flutter/material.dart';
import 'package:schedule/utils/time_utils.dart';
import 'course_info.dart';

class CourseTable extends StatelessWidget {
  const CourseTable({
    super.key,
    required this.week,
    required this.currentSemester,
    this.showWeekend = false,
    this.showTimeSlots = false,
    this.showGrid = true,
    this.themeColor = Colors.teal,
    required this.courses,
  });

  final int week;
  final int currentSemester;
  final bool showWeekend;
  final bool showTimeSlots;
  final bool showGrid;
  final Color themeColor;
  final List<Map<String, dynamic>> courses;

  static const List<List<String>> _timeSlots = [
    ["8:20", "9:05"],
    ["9:15", "10:00"],
    ["10:20", "11:05"],
    ["11:15", "12:00"],
    ["14:00", "14:45"],
    ["14:55", "15:40"],
    ["15:50", "16:35"],
    ["16:45", "17:30"],
    ["19:30", "20:15"],
    ["20:25", "21:10"],
  ];

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
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _timeSlots[index][1],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    const weekdays = ["一", "二", "三", "四", "五", "六", "日"];
    final visibleDays = showWeekend ? weekdays : weekdays.sublist(0, 5);

    // 计算本学期开始日期
    final now = DateTime.now();
    final year = now.month >= 9 ? now.year : now.year - 1;
    var semesterStart = DateTime(year, 9, 1);

    // 如果学期开始日期是周六或周日，则从下周一开始
    while (semesterStart.weekday >= 6) {
      semesterStart = semesterStart.add(const Duration(days: 1));
    }

    // 计算当前显示周的第一天
    final weekStart = semesterStart.add(Duration(days: (week - 1) * 7));

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
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...List.generate(visibleDays.length, (index) {
            final date = weekStart.add(Duration(days: index));
            final isToday = date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;

            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '周${visibleDays[index]}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.month}/${date.day}',
                    style: TextStyle(
                      fontSize: 12,
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

  Widget _buildCourseCell(Map<String, dynamic>? course, BuildContext context) {
    if (course == null) return Container();

    // 检查课程是否在当前周显示
    if (!List<int>.from(course['weeks'] ?? []).contains(week)) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          course['color'][0],
          course['color'][1],
          course['color'][2],
          1,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => getCourseInfo(context, course, themeColor: themeColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['courseName'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (course['teacherName']?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '@${course['teacherName']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                getWeeks(course['weeks']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getWeeks(List<int> weeks) {
    if (weeks.isEmpty) return '';

    weeks.sort();
    List<String> weekRanges = [];
    int start = weeks.first;
    int end = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        end = weeks[i];
      } else {
        if (start == end) {
          weekRanges.add('$start');
        } else {
          weekRanges.add('$start-$end周');
        }
        start = weeks[i];
        end = weeks[i];
      }
    }
    if (start == end) {
      weekRanges.add('$start');
    } else {
      weekRanges.add('$start-$end周');
    }

    return weekRanges.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final gridWidth =
        (MediaQuery.of(context).size.width - (showTimeSlots ? 45.0 : 30.0)) /
            (showWeekend ? 7 : 5);

    return Column(
      children: [
        _buildHeader(),
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
                        width: gridWidth,
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

        cells.add(
          Container(
            height: 60.0 * duration,
            decoration: BoxDecoration(
              border: showGrid
                  ? Border.all(color: Colors.grey[200]!)
                  : Border.all(color: Colors.transparent),
            ),
            child: _buildCourseCell(courseForThisSlot, context),
          ),
        );
      } else if (!occupiedSlots.contains(row)) {
        cells.add(
          Container(
            height: 60.0,
            decoration: BoxDecoration(
              border: showGrid
                  ? Border.all(color: Colors.grey[200]!)
                  : Border.all(color: Colors.transparent),
            ),
          ),
        );
      }
    }

    return cells;
  }

  int _getStartTime(List<dynamic> times, int col) {
    var time = times.firstWhere(
      (time) => TimeUtils.getDayValue(time[0].toString()) == col + 1,
      orElse: () => List<dynamic>.empty(),
    );
    if (time is! List || time.isEmpty) return 999;
    return TimeUtils.getClassValue(time[1].toString());
  }
}
