import 'package:flutter/material.dart';
import 'package:schedule/widgets/course_table.dart';

/// SlideTable 小部件，用于显示可滑动的课程表视图
/// [onWeekChange] 当前周改变时的回调函数，影响顶部导航栏显示
/// [offset] 为显示的起始周数，默认为1
class SlideTable extends StatefulWidget {
  SlideTable({
    super.key,
    required this.onWeekChange,
    this.offset = 1,
    required this.showWeekend,
    required this.showTimeSlots,
  }) : pageController = PageController(initialPage: offset - 1);
  final ValueChanged<int> onWeekChange; // 当前周改变时的回调函数
  final int offset; // 显示的起始周数
  bool showWeekend; // 是否显示周末
  bool showTimeSlots;
  final PageController pageController; // 页面控制器，用于控制PageView的滑动

  @override
  _SlideTableState createState() => _SlideTableState();
}

class _SlideTableState extends State<SlideTable> {
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

  void _handlePageChange(int index) {
    // 当PageView页面改变时调用
    // 等待滑动动画完成后，调用onWeekChange回调更新周次
    widget.pageController
        .animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    )
        .then((_) {
      widget.onWeekChange(index + 1); // 将索引+1后传递给回调函数
    });
  }

  void _checkDateAndShowDialog(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime semesterEnd =
        calculateStartOfWeek(20).add(const Duration(days: 6));

    if (now.isAfter(semesterEnd)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('学期即将结束'),
            content: const Text('是否添加下一学期课程？'),
            actions: [
              TextButton(
                child: const Text('否'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('是'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/add_course'); // 跳转到添加课程页面
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // 初始化时，如果需要，可以设置PageController的初始页面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDateAndShowDialog(context);
    });
  }

  @override
  void dispose() {
    // 释放PageController资源
    widget.pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 打印重建信息，有助于调试
    final List<Widget> list = []; // 创建一个Widget列表，用于存储课程表页面
    for (int i = 1; i < 21; i++) {
      list.add(CourseTable(
        // 为每个周次添加一个课程表页面
        week: i,
        showWeekend: widget.showWeekend, // 使用widget.showWeekend
        showTimeSlots: widget.showTimeSlots,
      ));
    }

    return PageView(
      key: Key(widget.offset.toString()), // 为PageView设置Key，以便Flutter能够检测到状态变化
      controller: widget.pageController, // 使用PageController控制滑动
      onPageChanged: _handlePageChange, // 设置页面改变时的回调
      children: list, // 设置PageView的子页面列表
    );
  }
}
