import 'package:flutter/material.dart';
import 'course_table.dart';

/// SlideTable 小部件，用于显示可滑动的课程表视图
/// [onWeekChange] 当前周改变时的回调函数，影响顶部导航栏显示
/// [offset] 为显示的起始周数，默认为1
class SlideTable extends StatefulWidget {
  final int initialWeek;
  final int currentSemester;
  final bool showWeekend;
  final bool showTimeSlots;
  final bool showGrid;
  final Color themeColor;
  final List<Map<String, dynamic>> courses;
  final Function(Map<String, dynamic>) onCourseUpdated;
  final Function(Map<String, dynamic>) onCourseDeleted;
  final Function(int) onWeekChange;

  const SlideTable({
    super.key,
    required this.initialWeek,
    required this.currentSemester,
    this.showWeekend = false,
    this.showTimeSlots = false,
    this.showGrid = true,
    this.themeColor = Colors.teal,
    required this.courses,
    required this.onCourseUpdated,
    required this.onCourseDeleted,
    required this.onWeekChange,
  });

  @override
  State<SlideTable> createState() => _SlideTableState();
}

class _SlideTableState extends State<SlideTable> {
  late PageController _pageController;
  late int _currentWeek;

  @override
  void initState() {
    super.initState();
    _currentWeek = widget.initialWeek;
    _pageController = PageController(
      initialPage: _currentWeek - 1,
      viewportFraction: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentWeek = index + 1;
        });
        widget.onWeekChange(_currentWeek);
      },
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 20,
      itemBuilder: (context, index) {
        return CourseTable(
          key: ValueKey('week_$index'),
          week: index + 1,
          currentSemester: widget.currentSemester,
          showWeekend: widget.showWeekend,
          showTimeSlots: widget.showTimeSlots,
          showGrid: widget.showGrid,
          themeColor: widget.themeColor,
          courses: widget.courses,
          onCourseUpdated: widget.onCourseUpdated,
          onCourseDeleted: widget.onCourseDeleted,
        );
      },
    );
  }
}
