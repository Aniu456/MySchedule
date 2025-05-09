import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/time_utils.dart';
import 'course_info.dart';
import '../utils/color_utils.dart';

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

  /// 周的日期范围
  final List<DateTime> weekDates;

  /// 是否正在加载日期
  final bool isLoading;

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
    this.weekDates = const [],
    this.isLoading = false,
  });

  /// 构建时间列
  Widget _buildTimeColumn() {
    return SizedBox(
      width: (showTimeSlots ? 45 : 30).w,
      child: Column(
        children: List.generate(10, (index) {
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: showGrid
                    ? Border.all(color: Colors.grey[200]!)
                    : Border.all(color: Colors.transparent),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (showTimeSlots) ...[
                      Flexible(
                        flex: 3,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            children: [
                              Text(
                                _timeSlots[index][0],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _timeSlots[index][1],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 构建表头
  Widget _buildHeader() {
    const weekdays = ["一", "二", "三", "四", "五", "六", "日"];
    final visibleDays = showWeekend ? weekdays : weekdays.sublist(0, 5);

    // 如果日期正在加载或为空，显示占位符
    if (isLoading || weekDates.isEmpty) {
      return Container(
        height: 55,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: (showTimeSlots ? 45 : 30),
              child: const Center(
                child: Text(
                  '日期',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            ...List.generate(visibleDays.length, (index) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          '周${visibleDays[index]}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          '加载中...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
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

    return Container(
      height: 55,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: (showTimeSlots ? 45 : 30),
            child: const Center(
              child: Text(
                '日期',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          ...List.generate(visibleDays.length, (index) {
            final date =
                weekDates.length > index ? weekDates[index] : DateTime.now();
            final isToday = _isToday(date);

            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '周${visibleDays[index]}',
                        style: TextStyle(
                          fontSize: showWeekend ? 13 : 15,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.w500,
                          color: isToday ? Colors.red : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '${date.month}/${date.day}',
                        style: TextStyle(
                          fontSize: showWeekend ? 12 : 13,
                          color: isToday ? Colors.red : Colors.grey,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
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
  Widget _buildCourseCell(BuildContext context, Map<String, dynamic> course) {
    // 检查课程是否在当前周显示
    if (!List<int>.from(course['weeks'] ?? []).contains(week)) {
      return Container();
    }

    return GestureDetector(
      onTap: () => showCourseInfo(
        context,
        course,
        themeColor: themeColor,
        onCourseUpdated: onCourseUpdated,
        onCourseDeleted: onCourseDeleted,
      ),
      child: Container(
        margin: EdgeInsets.all(1.r),
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: _getCourseColor(course),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                course['courseName'] ?? '未输入课程名',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: showWeekend ? 13.sp : 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: showWeekend ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 12.h),
            if (course['teacherName']?.isNotEmpty ?? false)
              Flexible(
                child: Text(
                  '@${course['teacherName']}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: showWeekend ? 10.sp : 11.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Text(
              _formatWeeks(List<int>.from(course['weeks'] ?? [])),
              style: TextStyle(
                color: Colors.white,
                fontSize: showWeekend ? 10.sp : 12.5.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
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

      final courseInfo = _findCourseForSlot(columnCourses, col, row);
      if (courseInfo != null) {
        final (course, startClass, endClass) = courseInfo;
        final duration = endClass - startClass + 1;

        // 标记被占用的时间段
        for (int i = startClass - 1; i < endClass; i++) {
          occupiedSlots.add(i);
        }

        cells.add(Expanded(
          flex: duration,
          child: Container(
            decoration: BoxDecoration(
              border: showGrid
                  ? Border.all(color: Colors.grey[200]!)
                  : Border.all(color: Colors.transparent),
            ),
            child: _buildCourseCell(context, course),
          ),
        ));
      } else {
        cells.add(Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: showGrid
                  ? Border.all(color: Colors.grey[200]!)
                  : Border.all(color: Colors.transparent),
            ),
          ),
        ));
      }
    }

    return cells;
  }

  /// 查找指定时间段的课程
  (Map<String, dynamic>, int, int)? _findCourseForSlot(
    List<Map<String, dynamic>> courses,
    int col,
    int row,
  ) {
    for (var course in courses) {
      var time = course['times'].firstWhere((time) {
        if (time is! List || time.length < 3) return false;
        if (TimeUtils.getDayValue(time[0].toString()) != col + 1) return false;

        int startClass = TimeUtils.getClassValue(time[1].toString());
        int endClass = TimeUtils.getClassValue(time[2].toString());

        if (!TimeUtils.isValidTimeRange(startClass, endClass)) return false;

        return row + 1 >= startClass && row + 1 <= endClass;
      }, orElse: () => List<dynamic>.empty());

      if (time is List && time.isNotEmpty) {
        int startClass = TimeUtils.getClassValue(time[1].toString());
        int endClass = TimeUtils.getClassValue(time[2].toString());
        return (course, startClass, endClass);
      }
    }
    return null;
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

  /// 检查是否是今天
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 格式化周次显示
  String _formatWeeks(List<int> weeks) {
    if (weeks.isEmpty) return '';

    weeks.sort();
    List<String> ranges = [];
    List<int> continuous = [];
    int? lastNum;

    for (int week in weeks) {
      if (lastNum != null && week != lastNum + 1) {
        if (continuous.length >= 2) {
          ranges.add('${continuous.first}-${continuous.last}');
        } else {
          ranges.addAll(continuous.map((n) => '$n'));
        }
        continuous = [];
      }
      continuous.add(week);
      lastNum = week;
    }

    if (continuous.isNotEmpty) {
      if (continuous.length >= 2) {
        ranges.add('${continuous.first}-${continuous.last}');
      } else {
        ranges.addAll(continuous.map((n) => '$n'));
      }
    }

    return '${ranges.join(',')}周';
  }

  /// 获取课程颜色，添加验证以避免黑色
  Color _getCourseColor(Map<String, dynamic> course) {
    return ColorUtils.storageToColor(course['color'], defaultColor: themeColor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimeColumn(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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

                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
      ],
    );
  }
}
