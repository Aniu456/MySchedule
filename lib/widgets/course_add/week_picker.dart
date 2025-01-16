import 'package:flutter/material.dart';
import 'dart:math';

//周次管理逻辑
class WeekPickerWidget extends StatelessWidget {
  final List<int> weeks;
  final Color currentColor;

  const WeekPickerWidget({
    super.key,
    required this.weeks,
    required this.currentColor,
  });

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

    weeks.sort();
    List<String> weekRanges = [];
    int start = weeks.first;
    int end = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        end = weeks[i];
      } else {
        if (start == end) {
          weekRanges.add('第$start周');
        } else {
          weekRanges.add('第$start-$end周');
        }
        start = weeks[i];
        end = weeks[i];
      }
    }

    if (start == end) {
      weekRanges.add('第$start周');
    } else {
      weekRanges.add('第$start-$end周');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: weekRanges.map((range) {
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

class WeekPickerDialog extends StatefulWidget {
  final List<int> initialWeeks;
  final Color themeColor;
  final Function(List<int>) onWeeksSelected;

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
  late List<int> selectedWeeks;
  int? dragStartWeek;
  bool? isSelecting;

  @override
  void initState() {
    super.initState();
    selectedWeeks = List.from(widget.initialWeeks);
  }

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择上课周次'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
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
        ),
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
