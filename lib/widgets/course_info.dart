import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../utils/time_utils.dart';
import 'course_add/time_picker.dart';
import 'course_add/week_picker.dart';

class CourseInfoDialog extends StatefulWidget {
  final Map<String, dynamic> course;
  final Color themeColor;

  const CourseInfoDialog({
    super.key,
    required this.course,
    this.themeColor = Colors.teal,
  });

  @override
  State<CourseInfoDialog> createState() => _CourseInfoDialogState();
}

class _CourseInfoDialogState extends State<CourseInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _courseName;
  late String _teacherName;
  late String _remarks;
  late Color _currentColor;
  late List<List<dynamic>> _times;
  late List<int> _weeks;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _courseName = widget.course['courseName'];
    _teacherName = widget.course['teacherName'];
    _remarks = widget.course['remarks'] ?? '';
    final List<int> colorValues = List<int>.from(widget.course['color']);
    _currentColor =
        Color.fromRGBO(colorValues[0], colorValues[1], colorValues[2], 1);
    _times = List<List<dynamic>>.from(widget.course['times']);
    _weeks = List<int>.from(widget.course['weeks']);
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _initializeData(); // 取消编辑时恢复原始数据
      }
    });
  }

  void _showWeekPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => WeekPickerDialog(
        initialWeeks: _weeks,
        themeColor: _currentColor,
        onWeeksSelected: (weeks) => setState(() => _weeks = weeks),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择课程颜色'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) => setState(() => _currentColor = color),
            availableColors: Colors.primaries,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _addTime(String day, int start, int end) {
    if (!TimeUtils.isValidTimeRange(start, end)) {
      _showMessage('无效的时间范围');
      return;
    }

    // 移除空的时间段
    _times = _times.where((time) => time.isNotEmpty).toList();

    // 检查新时间段是否与已有时间段重叠
    for (var existingTime in _times) {
      if (existingTime[0] == day) {
        int existingStart = TimeUtils.getClassValue(existingTime[1].toString());
        int existingEnd = TimeUtils.getClassValue(existingTime[2].toString());

        if (!(end < existingStart || start > existingEnd)) {
          _showMessage('该时间段与已选时间重叠');
          return;
        }
      }
    }

    setState(() {
      List<List<dynamic>> newTimes = List.from(_times)
        ..add([day, start.toString(), end.toString()]);

      newTimes.sort((a, b) {
        if (a.isEmpty || b.isEmpty) return 0;
        int dayCompare = TimeUtils.getDayValue(a[0].toString())
            .compareTo(TimeUtils.getDayValue(b[0].toString()));
        if (dayCompare != 0) return dayCompare;
        return TimeUtils.getClassValue(a[1].toString())
            .compareTo(TimeUtils.getClassValue(b[1].toString()));
      });

      _times = newTimes;
    });
  }

  void _removeTime(List<dynamic> time) {
    setState(() {
      _times.remove(time);
      if (_times.isEmpty) {
        _times.add([]);
      }
    });
  }

  void _showTimePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => CourseTimePickerDialog(
        onTimeAdded: _addTime,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: _currentColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
        margin: const EdgeInsets.only(
          bottom: kFloatingActionButtonMargin + 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      _showMessage('请填写必要信息');
      return;
    }

    _formKey.currentState!.save();

    if (_courseName.isEmpty || _teacherName.isEmpty) {
      _showMessage('请填写课程名称和教师姓名');
      return;
    }

    List<List<dynamic>> validTimes = _times.where((t) => t.isNotEmpty).toList();
    if (validTimes.isEmpty) {
      _showMessage('请添加上课时间');
      return;
    }

    if (_weeks.isEmpty) {
      _showMessage('请选择上课周次');
      return;
    }

    final updatedCourse = {
      'courseName': _courseName,
      'teacherName': _teacherName,
      'remarks': _remarks,
      'color': [_currentColor.red, _currentColor.green, _currentColor.blue],
      'times': validTimes,
      'weeks': _weeks,
      'semester': widget.course['semester'],
    };

    Navigator.pop(context, updatedCourse);
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: _currentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
            if (child != const SizedBox()) const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required void Function(String?) onSaved,
    bool isRequired = true,
    int? maxLength,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        counterText: '',
      ),
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: _isEditing,
      onSaved: onSaved,
      validator: isRequired
          ? (value) => value?.isEmpty ?? true ? '此项不能为空' : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? '编辑课程' : '课程详情',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _isEditing
                          ? [
                              TextButton(
                                onPressed: _toggleEdit,
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: _saveChanges,
                                child: const Text('保存'),
                              ),
                            ]
                          : [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: _toggleEdit,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('删除课程'),
                                      content: const Text('确定要删除这门课程吗？'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context); // 关闭确认对话框
                                            Navigator.pop(context,
                                                {'delete': true}); // 返回删除标记
                                          },
                                          child: const Text('删除',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: '课程名称',
                  initialValue: _courseName,
                  onSaved: (value) => _courseName = value ?? '',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: '授课教师',
                  initialValue: _teacherName,
                  onSaved: (value) => _teacherName = value ?? '',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: '备注',
                  initialValue: _remarks,
                  onSaved: (value) => _remarks = value ?? '',
                  isRequired: false,
                  maxLength: 20,
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.color_lens),
                    label: const Text('更改颜色'),
                    onPressed: _showColorPicker,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _currentColor,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildCard(
                  title: '上课时间',
                  icon: Icons.access_time,
                  trailing: _isEditing
                      ? IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _showTimePickerDialog,
                        )
                      : null,
                  child: TimePickerWidget(
                    times: _times,
                    currentColor: _currentColor,
                    onAddTime: _showTimePickerDialog,
                    onRemoveTime: _isEditing ? _removeTime : (_) {},
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: '上课周次',
                  icon: Icons.date_range,
                  trailing: _isEditing
                      ? TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('选择'),
                          onPressed: _showWeekPickerDialog,
                        )
                      : null,
                  child: WeekPickerWidget(
                    weeks: _weeks,
                    currentColor: _currentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showCourseInfo(
  BuildContext context,
  Map<String, dynamic> course, {
  Color themeColor = Colors.teal,
  required Function(Map<String, dynamic>) onCourseUpdated,
  required Function(Map<String, dynamic>) onCourseDeleted,
}) {
  showDialog(
    context: context,
    builder: (context) => CourseInfoDialog(
      course: course,
      themeColor: themeColor,
    ),
  ).then((result) {
    if (result != null) {
      if (result is Map<String, dynamic> && result['delete'] == true) {
        onCourseDeleted(course);
      } else {
        onCourseUpdated(result as Map<String, dynamic>);
      }
    }
  });
}
