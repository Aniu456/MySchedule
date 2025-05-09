import 'package:flutter/material.dart';
import '../../utils/course_storage_hive.dart';

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

class SemesterPickerDialog extends StatefulWidget {
  final int currentSemester;
  final Function(int) onSemesterSelected;

  const SemesterPickerDialog({
    super.key,
    required this.currentSemester,
    required this.onSemesterSelected,
  });

  @override
  State<SemesterPickerDialog> createState() => _SemesterPickerDialogState();
}

class _SemesterPickerDialogState extends State<SemesterPickerDialog> {
  List<int> _configuredSemesters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfiguredSemesters();
  }

  Future<void> _loadConfiguredSemesters() async {
    List<int> semesters = [];

    // 获取所有已设置日期的学期
    for (int i = 1; i <= 10; i++) {
      if (await CourseStorageHive.hasSemesterStartDate(i)) {
        semesters.add(i);
      }
    }

    if (mounted) {
      setState(() {
        _configuredSemesters = semesters;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择学期'),
      content: SizedBox(
        width: double.maxFinite,
        height: 200,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _configuredSemesters.isEmpty
                ? const Center(child: Text('请先在设置中添加学期'))
                : ListView.builder(
                    itemCount: _configuredSemesters.length,
                    itemBuilder: (context, index) {
                      final semester = _configuredSemesters[index];
                      return ListTile(
                        title: Text('第$semester学期'),
                        selected: widget.currentSemester == semester,
                        onTap: () {
                          widget.onSemesterSelected(semester);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
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
