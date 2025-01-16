import 'package:flutter/material.dart';
import '../../utils/time_utils.dart';

//时间选择器
class TimePickerWidget extends StatelessWidget {
  final List<List<dynamic>> times;
  final Color currentColor;
  final Function() onAddTime;
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
                .map(
                  (time) => Chip(
                    backgroundColor: currentColor.withOpacity(0.1),
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
                  ),
                )
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
}

class CourseTimePickerDialog extends StatefulWidget {
  final Function(String, int, int) onTimeAdded;

  const CourseTimePickerDialog({
    super.key,
    required this.onTimeAdded,
  });

  @override
  State<CourseTimePickerDialog> createState() => _CourseTimePickerDialogState();
}

class _CourseTimePickerDialogState extends State<CourseTimePickerDialog> {
  String? selectedDay;
  int? startPeriod;
  int? endPeriod;

  static const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  // 检查时间段是否有效
  bool _isValidTimeRange(int start, int end) {
    // 确保开始时间小于结束时间
    if (start > end) return false;
    // 确保时间段不会太长（比如不允许跨越超过4节课）
    if (end - start >= 4) return false;
    return true;
  }

  Widget _buildDropdown({
    required dynamic value,
    required String hint,
    required List<DropdownMenuItem> items,
    required Function(dynamic) onChanged,
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

  void _handleTimeSelection(dynamic value) {
    final int? selectedValue = value as int?;
    if (selectedValue == null || startPeriod == null) return;

    // 如果选择的结束时间小于开始时间，不允许选择
    if (selectedValue < startPeriod!) return;

    // 如果时间跨度过大，不允许选择
    if (!_isValidTimeRange(startPeriod!, selectedValue)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('上课时间跨度不能超过4节课')),
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
          Row(
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
                          )),
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
                              ))
                      : [],
                  onChanged: _handleTimeSelection,
                ),
              ),
            ],
          ),
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
}
