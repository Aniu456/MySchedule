import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../utils/time_utils.dart';
import 'course_add/time_picker.dart';
import 'course_add/week_picker.dart';

/// 课程信息对话框
/// 用于显示和编辑课程详细信息
class CourseInfoDialog extends StatefulWidget {
  /// 课程数据
  final Map<String, dynamic> course;

  /// 主题颜色
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
  /// 表单 key
  final _formKey = GlobalKey<FormState>();

  /// 课程基本信息
  late String _courseName;
  late String _teacherName;
  late String _remarks;
  late Color _currentColor;
  late List<List<dynamic>> _times;
  late List<int> _weeks;

  // 添加原始课程名称记录
  late final String _originalCourseName;

  /// 是否处于编辑状态
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _originalCourseName = widget.course['courseName'];
    _initializeData();
  }

  /// 初始化课程数据
  void _initializeData() {
    _courseName = widget.course['courseName'];
    _teacherName = widget.course['teacherName'];
    _remarks = widget.course['remarks'] ?? '';
    _currentColor = Color.fromRGBO(
      widget.course['color'][0],
      widget.course['color'][1],
      widget.course['color'][2],
      1,
    );
    _times = List<List<dynamic>>.from(widget.course['times']);
    _weeks = List<int>.from(widget.course['weeks']);
  }

  /// 切换编辑状态
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _initializeData(); // 取消编辑时恢复原始数据
      }
    });
  }

  /// 显示周次选择对话框
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

  /// 显示颜色选择器
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

  /// 添加课程时间
  void _addTime(String day, int start, int end) {
    if (!TimeUtils.isValidTimeRange(start, end)) {
      _showMessage('无效的时间范围');
      return;
    }

    // 移除空的时间段
    _times = _times.where((time) => time.isNotEmpty).toList();

    // 检查时间冲突
    if (TimeUtils.hasTimeConflict(
      _times,
      _weeks,
      [
        [day, start.toString(), end.toString()]
      ],
      _weeks,
    )) {
      _showMessage('该时间段与已选时间重叠');
      return;
    }

    setState(() {
      List<List<dynamic>> newTimes = List.from(_times)
        ..add([day, start.toString(), end.toString()]);

      // 按星期和时间排序
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

  /// 移除课程时间
  void _removeTime(List<dynamic> time) {
    setState(() {
      _times.remove(time);
      if (_times.isEmpty) {
        _times.add([]);
      }
    });
  }

  /// 显示时间选择对话框
  void _showTimePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => CourseTimePickerDialog(
        onTimeAdded: _addTime,
      ),
    );
  }

  /// 显示提示消息
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

  /// 保存课程修改
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

    final validTimes = _times.where((t) => t.isNotEmpty).toList();
    if (validTimes.isEmpty) {
      _showMessage('请添加上课时间');
      return;
    }

    if (_weeks.isEmpty) {
      _showMessage('请选择上课周次');
      return;
    }

    final updatedCourse = {
      'originalCourseName': _originalCourseName,
      'courseName': _courseName,
      'teacherName': _teacherName,
      'remarks': _remarks,
      'color': [_currentColor.r, _currentColor.g, _currentColor.b],
      'times': validTimes,
      'weeks': _weeks,
      'semester': widget.course['semester'],
    };

    Navigator.pop(context, updatedCourse);
  }

  /// 构建表单字段
  Widget _buildTextField({
    required String label,
    required String initialValue,
    required void Function(String?) onSaved,
    bool isRequired = true,
    int? maxLength,
    int maxLines = 1,
  }) {
    return TextFormField(
      enabled: _isEditing,
      initialValue: initialValue,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: TextStyle(
        color: _isEditing ? null : Colors.grey[700],
      ),
      validator: isRequired
          ? (value) => value?.isEmpty ?? true ? '请填写$label' : null
          : null,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                  if (_isEditing) ...[
                    TextButton(
                      onPressed: _toggleEdit,
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: _saveChanges,
                      child: const Text('保存'),
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _toggleEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('删除课程'),
                          content: const Text('确定要删除这门课程吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context, {'delete': true});
                              },
                              child: const Text('删除',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        '上课时间',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_isEditing)
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _showTimePickerDialog,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TimePickerWidget(
                    times: _times,
                    currentColor: _currentColor,
                    onAddTime: _showTimePickerDialog,
                    onRemoveTime: _isEditing ? _removeTime : (_) {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        '上课周次',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_isEditing)
                        TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('选择'),
                          onPressed: _showWeekPickerDialog,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  WeekPickerWidget(
                    weeks: _weeks,
                    currentColor: _currentColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 显示课程信息对话框
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
