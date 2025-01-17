import 'package:flutter/material.dart';
import 'course_table.dart';

/// 可滑动的课程表组件
class SlideTable extends StatefulWidget {
  /// 初始周次
  final int initialWeek;

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

  /// 周次变化回调
  final Function(int) onWeekChange;

  const SlideTable({
    super.key,
    required this.initialWeek,
    required this.currentSemester,
    required this.showWeekend,
    required this.showTimeSlots,
    required this.showGrid,
    required this.themeColor,
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialWeek - 1,
      keepPage: true,
    );
  }

  @override
  void didUpdateWidget(SlideTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当周次变化时，更新页面位置
    if (oldWidget.initialWeek != widget.initialWeek) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && mounted) {
          _pageController.jumpToPage(widget.initialWeek - 1);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: kFloatingActionButtonMargin + 64, // 为浮动按钮预留空间
      ),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          if (mounted) {
            widget.onWeekChange(page + 1);
          }
        },
        itemCount: 20,
        itemBuilder: (context, index) {
          final week = index + 1;
          return CourseTable(
            week: week,
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
      ),
    );
  }
}
