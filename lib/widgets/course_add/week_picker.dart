import 'package:flutter/material.dart';
import 'dart:math';

/// 周次选择器组件
/// 用于显示已选择的周次，以连续区间的形式展示
class WeekPickerWidget extends StatelessWidget {
  /// 已选择的周次列表
  final List<int> weeks;

  /// 当前主题颜色
  final Color currentColor;

  const WeekPickerWidget({
    super.key,
    required this.weeks,
    required this.currentColor,
  });

  /// 将周次列表转换为连续区间的字符串表示
  List<String> _getWeekRanges() {
    if (weeks.isEmpty) return [];

    List<String> weekRanges = [];
    weeks.sort();
    int start = weeks.first;
    int end = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        end = weeks[i];
      } else {
        weekRanges.add(start == end ? '第$start周' : '第$start-$end周');
        start = weeks[i];
        end = weeks[i];
      }
    }

    weekRanges.add(start == end ? '第$start周' : '第$start-$end周');
    return weekRanges;
  }

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) {
      return Center(
        child: Text(
          '点击选择上课周次',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _getWeekRanges().map((range) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: currentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            range,
            style: TextStyle(
              color: currentColor,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 周次选择对话框
/// 用于选择上课周次，支持单选和滑动多选
class WeekPickerDialog extends StatefulWidget {
  /// 初始选中的周次列表
  final List<int> initialWeeks;

  /// 主题颜色
  final Color themeColor;

  /// 周次选择回调
  final ValueChanged<List<int>> onWeeksSelected;

  const WeekPickerDialog({
    super.key,
    required this.initialWeeks,
    required this.themeColor,
    required this.onWeeksSelected,
  });

  @override
  State<WeekPickerDialog> createState() => _WeekPickerDialogState();
}

class _WeekPickerDialogState extends State<WeekPickerDialog> {
  /// 当前选中的周次列表
  late List<int> selectedWeeks;

  /// 滑动选择的起始周次
  int? dragStartWeek;

  /// 是否为选中操作（true为选中，false为取消选中）
  bool? isSelecting;

  @override
  void initState() {
    super.initState();
    selectedWeeks = List.from(widget.initialWeeks);
  }

  /// 切换周次选择状态
  void _toggleWeek(int week) {
    setState(() {
      if (selectedWeeks.contains(week)) {
        selectedWeeks.remove(week);
      } else {
        selectedWeeks.add(week);
      }
      selectedWeeks.sort();
    });
  }

  /// 构建周次选择网格
  Widget _buildWeekGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        final week = index + 1;
        final isSelected = selectedWeeks.contains(week);
        return InkWell(
          onTap: () => _toggleWeek(week),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? widget.themeColor : Colors.transparent,
              border: Border.all(
                color: widget.themeColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$week',
                style: TextStyle(
                  color: isSelected ? Colors.white : widget.themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择上课周次'),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildWeekGrid(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            widget.onWeeksSelected(selectedWeeks);
            Navigator.pop(context);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
