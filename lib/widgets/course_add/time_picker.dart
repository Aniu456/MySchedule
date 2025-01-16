import 'package:flutter/material.dart';

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
                      '${time[0]} 第${time[1]}-${time[2]}节',
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
          hint: Text(hint),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
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
                      child: Text(day),
                    ))
                .toList(),
            onChanged: (value) => setState(() => selectedDay = value),
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
                            child: Text('第${i + 1}节'),
                          )),
                  onChanged: (value) => setState(() {
                    startPeriod = value;
                    if (endPeriod != null && endPeriod! < value!) {
                      endPeriod = value;
                    }
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
                                child: Text('第${i + startPeriod!}节'),
                              ))
                      : [],
                  onChanged: (value) {
                    if (selectedDay != null &&
                        startPeriod != null &&
                        value != null) {
                      widget.onTimeAdded(selectedDay!, startPeriod!, value);
                      Navigator.pop(context);
                    }
                  },
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
