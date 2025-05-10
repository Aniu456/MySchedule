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
      child: LayoutBuilder(builder: (context, constraints) {
        final cellHeight = constraints.maxHeight / 10;

        return Column(
          children: List.generate(10, (index) {
            return Container(
              height: cellHeight,
              decoration: BoxDecoration(
                border: showGrid
                    ? Border.all(color: Colors.grey[200]!)
                    : Border.all(color: Colors.transparent),
                color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
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
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _timeSlots[index][1],
                                style: TextStyle(
                                  fontSize: 11.sp,
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
            );
          }),
        );
      }),
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
          color: Colors.grey[50],
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: (showTimeSlots ? 45 : 30).w,
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
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: (showTimeSlots ? 45 : 30).w,
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

  /// 获取课程颜色，添加验证以避免黑色
  Color _getCourseColor(Map<String, dynamic> course) {
    try {
      // 如果课程颜色数据不存在或不是列表，使用默认主题色
      if (course['color'] == null) {
        return themeColor;
      }

      return ColorUtils.storageToColor(course['color'],
          defaultColor: themeColor);
    } catch (e) {
      // 出现任何错误，返回默认主题色
      return themeColor;
    }
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

  @override
  Widget build(BuildContext context) {
    try {
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

                        List<int> weeks = [];
                        if (course['weeks'] != null &&
                            course['weeks'] is List) {
                          try {
                            weeks = List<int>.from(course['weeks']);
                          } catch (e) {
                            return false;
                          }
                        }

                        if (!weeks.contains(week)) return false;

                        if (course['times'] == null ||
                            course['times'] is! List) {
                          return false;
                        }

                        return course['times'].any((time) {
                          if (time is! List || time.length < 3) return false;
                          final dayNum =
                              TimeUtils.getDayValue(time[0].toString());
                          return dayNum == col + 1;
                        });
                      }).toList();

                      // 使用LayoutBuilder获取精确高度
                      return Expanded(
                        child: LayoutBuilder(builder: (context, constraints) {
                          final cellHeight = constraints.maxHeight / 10;
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              // 首先绘制网格线
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: List.generate(10, (row) {
                                  return Container(
                                    height: cellHeight,
                                    decoration: BoxDecoration(
                                      color: row % 2 == 0
                                          ? Colors.grey[50]
                                          : Colors.white,
                                      border: showGrid
                                          ? Border.all(color: Colors.grey[200]!)
                                          : Border.all(
                                              color: Colors.transparent),
                                    ),
                                  );
                                }),
                              ),
                              // 课程定位 - 修复类型错误
                              for (final course in columnCourses)
                                if (course['times'] is List)
                                  for (final time in course['times'])
                                    if (time is List &&
                                        time.length >= 3 &&
                                        TimeUtils.getDayValue(
                                                time[0].toString()) ==
                                            col + 1)
                                      Builder(builder: (context) {
                                        final startClass =
                                            TimeUtils.getClassValue(
                                                time[1].toString());
                                        final endClass =
                                            TimeUtils.getClassValue(
                                                time[2].toString());

                                        if (!TimeUtils.isValidTimeRange(
                                            startClass, endClass)) {
                                          return const SizedBox.shrink();
                                        }

                                        // 计算位置和高度
                                        final top =
                                            (startClass - 1) * cellHeight;
                                        final height =
                                            (endClass - startClass + 1) *
                                                cellHeight;

                                        // 检查单前时间段的时长
                                        final currentDuration =
                                            endClass - startClass + 1;

                                        return Positioned(
                                          top: top + 1,
                                          height: height - 2,
                                          left: 2,
                                          right: 2,
                                          child: _buildCourseCardForTime(
                                              context,
                                              course,
                                              currentDuration,
                                              time),
                                        );
                                      }),
                            ],
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      // 发生错误时显示错误信息
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
            const SizedBox(height: 16),
            Text(
              '课程表加载错误',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '请检查课程数据格式是否正确',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// 为特定时间段构建课程卡片
  Widget _buildCourseCardForTime(BuildContext context,
      Map<String, dynamic> course, int duration, List<dynamic> time) {
    try {
      // 判断是否为小卡片（一节课）
      bool isSmallCard = duration == 1;

      // 获取课程名称，确保有默认值
      String courseName = '未输入课程名';
      if (course['courseName'] != null && course['courseName'] is String) {
        courseName = course['courseName'];
      }

      // 获取教师名称
      String? teacherName;
      if (course['teacherName'] != null && course['teacherName'] is String) {
        teacherName = course['teacherName'];
      }

      // 获取周次
      List<int> weeks = [];
      if (course['weeks'] != null && course['weeks'] is List) {
        weeks = List<int>.from(course['weeks']);
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
          margin: EdgeInsets.all(2.r),
          padding: EdgeInsets.symmetric(horizontal: 4.r, vertical: 6.r),
          decoration: BoxDecoration(
            color: _getCourseColor(course),
            borderRadius: BorderRadius.circular(4.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 课程名称
              Text(
                courseName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (showWeekend ? 12 : 13).sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: isSmallCard ? 1 : 3,
                overflow: TextOverflow.ellipsis,
              ),

              // 底部信息区域 - 总是在底部显示
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 教师姓名（如果有）- 只在不是小卡片时显示
                    if (teacherName != null &&
                        teacherName.isNotEmpty &&
                        !isSmallCard)
                      Text(
                        '@$teacherName',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: (showWeekend ? 9 : 10).sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // 周次信息
                    Text(
                      _formatWeeks(weeks),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (showWeekend ? 9 : 10).sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      // 发生错误时显示错误占位符
      return Container(
        margin: EdgeInsets.all(2.r),
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: Colors.red[800],
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Center(
          child: Text(
            '数据错误',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
            ),
          ),
        ),
      );
    }
  }
}
