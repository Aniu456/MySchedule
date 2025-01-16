import 'package:flutter/material.dart';
import 'course_table.dart';

/// 可滑动的课程表视图
/// 支持左右滑动切换周次，并在切换时更新顶部导航栏
class SlideTable extends StatefulWidget {
  /// 初始显示的周次
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

  /// 课程数据列表
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
  /// 页面控制器
  late final PageController _pageController;

  /// 当前周次
  late int _currentWeek;

  @override
  void initState() {
    super.initState();
    _currentWeek = widget.initialWeek;
    // 初始化页面控制器，设置初始页面
    _pageController = PageController(
      initialPage: _currentWeek - 1,
      viewportFraction: 1.0,
    );
  }

  @override
  void dispose() {
    // 释放页面控制器
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      // 页面切换时更新周次并触发回调
      onPageChanged: (index) {
        setState(() => _currentWeek = index + 1);
        widget.onWeekChange(_currentWeek);
      },
      // 使用简单的滚动物理效果
      physics: const PageScrollPhysics(),
      // 限制最大周次为20周
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
