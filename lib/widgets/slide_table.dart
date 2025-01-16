import 'package:flutter/material.dart';
import 'course_table.dart';

/// SlideTable 小部件，用于显示可滑动的课程表视图
/// [onWeekChange] 当前周改变时的回调函数，影响顶部导航栏显示
/// [offset] 为显示的起始周数，默认为1
class SlideTable extends StatefulWidget {
  final Function(int) onWeekChange;
  final Function(int) onSemesterChange;
  final int currentSemester;
  final int offset;
  final bool showWeekend;
  final bool showTimeSlots;
  final bool showGrid;
  final Color themeColor;
  final List<Map<String, dynamic>> courses;
  final PageController? controller;

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
    this.controller,
  });

  @override
  State<SlideTable> createState() => _SlideTableState();
}

class _SlideTableState extends State<SlideTable> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = widget.controller ??
        PageController(
          initialPage: widget.offset - 1,
          viewportFraction: 1.0,
          keepPage: true,
        );
  }

  @override
  void didUpdateWidget(SlideTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller &&
        widget.controller != null) {
      _pageController = widget.controller!;
    }
    if (oldWidget.offset != widget.offset) {
      _pageController.jumpToPage(widget.offset - 1);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void jumpToWeek(int week) {
    _pageController.jumpToPage(week - 1);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => widget.onWeekChange(index + 1),
      itemCount: 20,
      itemBuilder: (context, index) {
        return CourseTable(
          week: index + 1,
          currentSemester: widget.currentSemester,
          showWeekend: widget.showWeekend,
          showTimeSlots: widget.showTimeSlots,
          showGrid: widget.showGrid,
          themeColor: widget.themeColor,
          courses: widget.courses,
        );
      },
    );
  }
}
