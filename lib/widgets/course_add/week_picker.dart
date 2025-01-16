import 'package:flutter/material.dart';

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
    return weeks.isNotEmpty
        ? Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weeks
                .map((week) => Chip(
                      backgroundColor: currentColor.withOpacity(0.1),
                      label: Text(
                        '第$week周',
                        style: TextStyle(color: currentColor),
                      ),
                    ))
                .toList(),
          )
        : Center(
            child: Text(
              '点击右上角选择按钮选择上课周次',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
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

  @override
  void initState() {
    super.initState();
    selectedWeeks = List.from(widget.initialWeeks);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择上课周次'),
      content: SizedBox(
        width: double.maxFinite,
        height: 200,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 20,
          itemBuilder: (context, index) {
            final weekNum = index + 1;
            final selected = selectedWeeks.contains(weekNum);
            return InkWell(
              onTap: () => setState(() {
                if (selected) {
                  selectedWeeks.remove(weekNum);
                } else {
                  selectedWeeks.add(weekNum);
                }
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? widget.themeColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$weekNum',
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
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
