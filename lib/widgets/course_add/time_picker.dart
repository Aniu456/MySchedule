import 'package:flutter/material.dart';
import '../../utils/time_utils.dart';
import '../../utils/color_utils.dart';

/// 时间选择器组件
/// 用于显示已选择的时间段，支持添加和删除时间
class TimePickerWidget extends StatelessWidget {
  /// 已选择的时间列表
  final List<List<dynamic>> times;

  /// 当前主题颜色
  final Color currentColor;

  /// 添加时间回调
  final VoidCallback onAddTime;

  /// 删除时间回调
  final Function(List<dynamic>) onRemoveTime;

  const TimePickerWidget({
    super.key,
    required this.times,
    required this.currentColor,
    required this.onAddTime,
    required this.onRemoveTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (times.any((time) => time.isNotEmpty))
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: times
                .where((time) => time.isNotEmpty)
                .map(_buildTimeChip)
                .toList(),
          )
        else
          Center(
            child: Text(
              '点击右上角添加按钮添加上课时间',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建时间显示芯片
  Widget _buildTimeChip(List<dynamic> time) {
    return Chip(
      backgroundColor: currentColor.toRGBO(0.1),
      label: Text(
        TimeUtils.formatTimeRange(time),
        style: TextStyle(color: currentColor),
      ),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: currentColor,
      ),
      onDeleted: () => onRemoveTime(time),
    );
  }
}

/// 时间选择对话框
/// 用于选择上课时间，包括星期和节次
class CourseTimePickerDialog extends StatefulWidget {
  /// 时间添加回调
  final void Function(String, int, int) onTimeAdded;

  const CourseTimePickerDialog({
    super.key,
    required this.onTimeAdded,
  });

  @override
  State<CourseTimePickerDialog> createState() => _CourseTimePickerDialogState();
}

class _CourseTimePickerDialogState extends State<CourseTimePickerDialog> {
  /// 选中的星期
  String? selectedDay;

  /// 开始节次
  int? startPeriod;

  /// 结束节次
  int? endPeriod;

  /// 星期选项
  static const List<String> weekdays = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日'
  ];

  /// 检查时间段是否有效
  bool _isValidTimeRange(int start, int end) {
    // 确保开始时间小于结束时间
    if (start > end) return false;
    // 确保时间段不会太长（不允许跨越超过4节课）
    if (end - start >= 4) return false;
    return true;
  }

  /// 处理时间选择
  void _handleTimeSelection(dynamic value) {
    final int? selectedValue = value as int?;
    if (selectedValue == null || startPeriod == null) return;

    // 如果选择的结束时间小于开始时间，不允许选择
    if (selectedValue < startPeriod!) return;

    // 如果时间跨度过大，不允许选择
    if (!_isValidTimeRange(startPeriod!, selectedValue)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('上课时间跨度不能超过4节课'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onTimeAdded(selectedDay!, startPeriod!, selectedValue);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择上课时间'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDropdown(
            value: selectedDay,
            hint: '选择星期',
            items: weekdays
                .map((day) => DropdownMenuItem(
                      value: day,
                      child: Text(
                        day,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ))
                .toList(),
            onChanged: (value) => setState(() {
              selectedDay = value;
              startPeriod = null;
              endPeriod = null;
            }),
          ),
          const SizedBox(height: 16),
          _buildTimePicker(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ],
    );
  }

  /// 构建时间选择部分
  Widget _buildTimePicker() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: startPeriod,
            hint: '开始节数',
            items: List.generate(
              10,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(
                  '第${i + 1}节',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            onChanged: (value) => setState(() {
              startPeriod = value;
              endPeriod = null;
            }),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('到'),
        ),
        Expanded(
          child: _buildDropdown(
            value: endPeriod,
            hint: '结束节数',
            items: startPeriod != null
                ? List.generate(
                    10 - startPeriod! + 1,
                    (i) => DropdownMenuItem(
                      value: i + startPeriod!,
                      child: Text(
                        '第${i + startPeriod!}节',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                : [],
            onChanged: _handleTimeSelection,
          ),
        ),
      ],
    );
  }

  /// 构建下拉选择框
  Widget _buildDropdown({
    required dynamic value,
    required String hint,
    required List<DropdownMenuItem> items,
    required ValueChanged<dynamic> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 12),
          ),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
