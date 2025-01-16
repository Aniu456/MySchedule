import 'package:flutter/material.dart';

//学期选择器
class SemesterPickerWidget extends StatelessWidget {
  final int currentSemester;
  final Function() onSemesterPick;

  const SemesterPickerWidget({
    super.key,
    required this.currentSemester,
    required this.onSemesterPick,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('第$currentSemester学期'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onSemesterPick,
    );
  }
}

class SemesterPickerDialog extends StatelessWidget {
  final int currentSemester;
  final Function(int) onSemesterSelected;

  const SemesterPickerDialog({
    super.key,
    required this.currentSemester,
    required this.onSemesterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择学期'),
      content: SizedBox(
        width: double.maxFinite,
        height: 200,
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            final semester = index + 1;
            return ListTile(
              title: Text('第$semester学期'),
              selected: currentSemester == semester,
              onTap: () {
                onSemesterSelected(semester);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
