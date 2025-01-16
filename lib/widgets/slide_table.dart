import 'package:flutter/material.dart';
import 'course_table.dart';

/// SlideTable 小部件，用于显示可滑动的课程表视图
/// [onWeekChange] 当前周改变时的回调函数，影响顶部导航栏显示
/// [offset] 为显示的起始周数，默认为1
class SlideTable extends StatelessWidget {
  final Function(int) onWeekChange;
  final Function(int) onSemesterChange;
  final int currentSemester;
  final int offset;
  final bool showWeekend;
  final bool showTimeSlots;
  final bool showGrid;
  final Color themeColor;
  final List<Map<String, dynamic>> courses;

  const SlideTable({
    super.key,
    required this.onWeekChange,
    required this.onSemesterChange,
    required this.currentSemester,
    required this.offset,
    required this.showWeekend,
    required this.showTimeSlots,
    required this.showGrid,
    required this.themeColor,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: PageController(initialPage: offset - 1),
      onPageChanged: (index) => onWeekChange(index + 1),
      itemCount: 20,
      itemBuilder: (context, index) {
        return CourseTable(
          week: index + 1,
          currentSemester: currentSemester,
          showWeekend: showWeekend,
          showTimeSlots: showTimeSlots,
          showGrid: showGrid,
          themeColor: themeColor,
          courses: courses,
        );
      },
    );
  }
}
