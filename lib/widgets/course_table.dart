import 'package:flutter/material.dart'; // 引入Flutter的Material包

import '../data/index.dart';
import 'course_info.dart';

class CourseTable extends StatelessWidget {
  CourseTable({
    super.key,
    required this.week,
    this.showWeekend = false,
    this.showTimeSlots = false,
  });

  //当前滑动的周数
  final int week; // 周数
  final bool showWeekend; // 是否显示周末
  final bool showTimeSlots; // 是否显示时间槽

  /// 表头宽度  表头高度  格子宽度  格子高度
  late double titleWidth;
  late double titleHeight;
  late double gridWidth;
  late double gridHeight;

  late BoxDecoration titleDecoration; // 表头装饰
  late BoxDecoration outerGridDecoration; // 外部网格装饰
  late BoxDecoration innerGridDecoration; // 内部网格装饰

  final List<List<String>> _timeSlots = [
    ["8:00", "8:45"],
    ["8:55", "9:40"],
    ["10:00", "10:45"],
    ["10:55", "11:40"],
    ["14:00", "14:45"],
    ["14:55", "15:40"],
    ["16:00", "16:45"],
    ["16:55", "17:40"],
    ["19:00", "19:45"],
    ["19:55", "20:40"],
  ];

  /// 初始化尺寸和数据库
  void _initSize(BuildContext context) {
    titleWidth = showTimeSlots ? 45.0 : 30.0; // 如果显示时间，增加宽度
    titleHeight = 50.0;
    gridWidth = (MediaQuery.of(context).size.width - titleWidth) /
        (showWeekend ? 7 : 5);
    gridHeight = 120.0;

    // 表头的装饰
    titleDecoration = const BoxDecoration(
      color: Colors.white, // 设置表头的背景色
    );

    // 外部网格的装饰
    outerGridDecoration = const BoxDecoration(
      color: Colors.white, // 设置网格的背景色
    );

    // 内部网格的装饰
    innerGridDecoration = BoxDecoration(
      color: Theme.of(context).colorScheme.secondary, // 使用主题的辅助颜色
      borderRadius: const BorderRadius.all(
        Radius.circular(8.0), // 圆角边框
      ),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Colors.black, // 阴影颜色
          offset: Offset(1.0, 1.0), // 阴影的偏移量
          blurRadius: 10.0, // 阴影模糊半径
        ),
      ],
    );
  }

  // 获取周次显示字符串
  String _getWeeksString(List<int> weeks) {
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

  // 渲染网格
  Widget _renderGrid(BuildContext context, int row, int col) {
    // 使用传递的周次
    int currentWeek = week;

    // 查找符合当前周次的课程
    final course = courses.firstWhere(
        (course) =>
            course['weeks'].contains(currentWeek) &&
            course['times'].any((time) =>
                _dayToNumber(time[0]) == col &&
                _classToNumber(time[1]) <= row * 2 &&
                _classToNumber(time[2]) >= row * 2 - 1),
        orElse: () => <String, dynamic>{});

    final innerWidget = course.isEmpty
        ? Container() // 如果没有课程，返回空容器
        : Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(course['color'][0], course['color'][1],
                  course['color'][2], 1), // 使用色值生成颜色
              borderRadius: BorderRadius.circular(6.5),
            ),
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.all(4),
            child: InkWell(
                onTap: () {
                  getCourseInfo(context, course);
                },
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // 设置为 spaceBetween
                    children: [
                      Text(
                        course['courseName'], // 显示课程名称
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${course['teacherName']}', // 显示授课老师
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.white54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getWeeksString(course['weeks']), // 显示选中的周次
                            style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                )));

    return Container(
      width: gridWidth, // 设置网格的宽度
      height: gridHeight, // 设置网格的高度
      decoration: outerGridDecoration, // 使用外部网格装饰
      child: innerWidget, // 渲染内部组件
    );
  }

// 辅助函数，将日期和课程时间转为数字
  int _dayToNumber(String day) {
    switch (day) {
      case '周一':
        return 1;
      case '周二':
        return 2;
      case '周三':
        return 3;
      case '周四':
        return 4;
      case '周五':
        return 5;
      case '周六':
        return 6;
      case '周日':
        return 7;
      default:
        return 0;
    }
  }

  int _classToNumber(String classTime) {
    switch (classTime) {
      case '第一节':
        return 1;
      case '第二节':
        return 2;
      case '第三节':
        return 3;
      case '第四节':
        return 4;
      case '第五节':
        return 5;
      case '第六节':
        return 6;
      case '第七节':
        return 7;
      case '第八节':
        return 8;
      default:
        return 0;
    }
  }

  DateTime calculateStartOfWeek(int offset) {
    // 固定的日期
    DateTime septemberFirst = DateTime(DateTime.now().year, 9, 1);

    // 获取该日期所在周的星期一
    DateTime weekStart = septemberFirst.subtract(
        Duration(days: (septemberFirst.weekday - DateTime.monday + 7) % 7));

    // 如果9月1日是周末，则offset直接用于计算目标周的起始日期
    if (septemberFirst.weekday == DateTime.saturday ||
        septemberFirst.weekday == DateTime.sunday) {
      return weekStart.add(Duration(days: 7 * offset));
    }

    // 否则，根据offset - 1计算目标周的起始日期
    return weekStart.add(Duration(days: 7 * (offset - 1)));
  }

  /// 渲染表头
  /// 渲染表头
  Widget _renderTitle(BuildContext context, int offset) {
    const weekName = ["一", "二", "三", "四", "五", "六", "日"];
    final list = <Widget>[];

    // 计算当前显示的周次
    DateTime startOfWeek = calculateStartOfWeek(offset);
    int currentMonth = startOfWeek.month;
    DateTime today = DateTime.now();

    // 表头左侧内容
    list.add(
      Container(
        decoration: titleDecoration, // 使用表头装饰
        width: titleWidth, // 设置表头宽度
        height: titleHeight, // 增加高度以容纳日期和月份
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // 垂直居中排列
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "$currentMonth",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(
                '月',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );

    // 渲染周一到周日的标题，并在下面显示当前星期的日期
    for (int i = 1; i <= (showWeekend ? 7 : 5); i++) {
      DateTime day = startOfWeek.add(Duration(days: i - 1));
      // bool isToday = (day.year == today.year &&
      //     day.month == today.month &&
      //     day.day == today.day);
      bool isToday = (day.month == today.month && day.day == today.day);

      list.add(
        Container(
          alignment: Alignment.center, // 文本居中
          decoration: titleDecoration, // 使用表头装饰
          width: gridWidth, // 设置格子宽度
          height: titleHeight, // 增加高度以容纳日期和星期
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // 垂直居中排列
            children: [
              Text(
                weekName[i - 1],
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16.5,
                  color: isToday ? Colors.red : Colors.grey[600], // 当前日期红色
                ),
              ),
              Text(
                "${day.month}/${day.day}",
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                  color: isToday ? Colors.red : Colors.grey[600], // 当前日期红色
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 返回表头的Row组件
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 水平均匀分布
      children: list,
    );
  }

  /// 渲染每行
  Widget _renderRow(BuildContext context, int row) {
    final list = <Widget>[];

    list.add(Container(
      decoration: titleDecoration,
      width: titleWidth,
      height: gridHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            children: [
              Text(
                (row * 2 - 1).toString(),
                style: const TextStyle(fontSize: 12),
              ),
              if (showTimeSlots)
                Column(
                  children: [
                    Text(
                      _timeSlots[row * 2 - 2][0], // 开始时间
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _timeSlots[row * 2 - 2][1], // 结束时间
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
          Column(
            children: [
              Text(
                (row * 2).toString(),
                style: const TextStyle(fontSize: 12),
              ),
              if (showTimeSlots)
                Column(
                  children: [
                    Text(
                      _timeSlots[row * 2 - 1][0], // 开始时间
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _timeSlots[row * 2 - 1][1], // 结束时间
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ));

    // 渲染一周的每一列
    for (int col = 1; col <= (showWeekend ? 7 : 5); col++) {
      list.add(_renderGrid(context, row, col)); // 渲染每个格子
    }

    // 返回渲染行的Row组件
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // 水平均匀分布
      children: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    _initSize(context); // 初始化尺寸和数据库

    // 渲染所有行
    final rows = <Widget>[];
    rows.add(_renderTitle(context, week)); // 添加表头
    for (int row = 1; row <= 5; row++) {
      rows.add(_renderRow(context, row)); // 渲染每一行
    }

    // 返回整个表格
    return Column(
      children: rows, // 将所有行添加到Column中
    );
  }
}
