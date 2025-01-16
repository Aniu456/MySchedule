import 'package:flutter/material.dart';
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
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Container(
            width: showTimeSlots ? 45.0 : 30.0,
            alignment: Alignment.center,
            child: Text(
              '${now.month}月',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
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

    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.all(2),
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
      ),
      child: InkWell(
        onTap: () => getCourseInfo(context, course, themeColor: themeColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course['courseName'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (course['teacherName']?.isNotEmpty ?? false)
              Text(
                '@${course['teacherName']}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const Spacer(),
            Text(
              '周${_getWeeksString(List<int>.from(course['weeks'] ?? []))}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getWeeksString(List<int> weeks) {
    if (weeks.isEmpty) return '';
    weeks.sort();
    final ranges = <String>[];
    int start = weeks[0], end = weeks[0];

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        end = weeks[i];
      } else {
        ranges.add(start == end ? '$start' : '$start-$end');
        start = end = weeks[i];
      }
    }
    ranges.add(start == end ? '$start' : '$start-$end');
    return ranges.join(', ');
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
                      return SizedBox(
                        width: gridWidth,
                        child: Column(
                          children: List.generate(10, (row) {
                            final coursesInCell = courses.where((course) {
                              if (course['semester'] != currentSemester)
                                return false;
                              if (!course['weeks'].contains(week)) return false;

                              return course['times'].any((time) {
                                if (time is! List || time.length < 3)
                                  return false;

                                final dayNum = _dayToNumber(time[0].toString());
                                final startClass =
                                    _classToNumber(time[1].toString());
                                final endClass =
                                    _classToNumber(time[2].toString());

                                return dayNum == col + 1 &&
                                    startClass <= endClass &&
                                    row + 1 >= startClass &&
                                    row + 1 <= endClass;
                              });
                            }).toList();

                            return Container(
                              height: 60.0,
                              decoration: BoxDecoration(
                                border: showGrid
                                    ? Border.all(color: Colors.grey[200]!)
                                    : Border.all(color: Colors.transparent),
                              ),
                              child: _buildCourseCell(
                                coursesInCell.isNotEmpty
                                    ? coursesInCell.first
                                    : null,
                                context,
                              ),
                            );
                          }),
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

  int _dayToNumber(String day) {
    const days = {
      '周一': 1,
      '周二': 2,
      '周三': 3,
      '周四': 4,
      '周五': 5,
      '周六': 6,
      '周日': 7
    };
    return days[day] ?? 0;
  }

  int _classToNumber(String classTime) {
    if (int.tryParse(classTime) != null) {
      return int.parse(classTime);
    }
    const classes = {
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
    return classes[classTime] ?? 0;
  }
}
