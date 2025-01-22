import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../utils/time_utils.dart';
import 'course_add/course_add_form.dart';
import 'course_add/time_picker.dart';
import 'course_add/week_picker.dart';
import 'course_add/semester_picker.dart';
import 'course_add/course_list.dart';

/// 课程添加页面
/// 用于添加新的课程，包含课程基本信息、上课时间、上课周次等设置
class CourseAdd extends StatefulWidget {
  /// 当前学期
  final int currentSemester;

  /// 主题颜色
  final Color themeColor;

  const CourseAdd({
    super.key,
    required this.currentSemester,
    required this.themeColor,
  });

  @override
  State<CourseAdd> createState() => _CourseAddState();
}

class _CourseAddState extends State<CourseAdd> {
  /// 表单相关控制器
  final _formKey = GlobalKey<FormState>();
  final _courseFocusNode = FocusNode();
  final _teacherFocusNode = FocusNode();
  final _remarksFocusNode = FocusNode();

  /// 已添加的课程列表
  final List<Map<String, dynamic>> _courses = [];

  /// 课程基本信息
  late String _courseName = '';
  late String _teacherName = '';
  late String _remarks = '';
  late Color _currentColor;
  late int _semester;

  /// 课程时间和周次
  late List<List<dynamic>> _times = [[]];
  late List<int> _weeks = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// 初始化数据
  void _initializeData() {
    _currentColor = widget.themeColor;
    _semester = widget.currentSemester;
  }

  @override
  void dispose() {
    _courseFocusNode.dispose();
    _teacherFocusNode.dispose();
    _remarksFocusNode.dispose();
    super.dispose();
  }

  /// 取消所有输入框焦点
  void _unfocusAll() {
    _courseFocusNode.unfocus();
    _teacherFocusNode.unfocus();
    _remarksFocusNode.unfocus();
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

  /// 显示时间选择对话框
  void _showTimePickerDialog() {
    _unfocusAll();
    showDialog(
      context: context,
      builder: (context) => CourseTimePickerDialog(
        onTimeAdded: _addTime,
      ),
    );
  }

  /// 显示周次选择对话框
  void _showWeekPickerDialog() {
    _unfocusAll();
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
    _unfocusAll();
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

  /// 显示学期选择对话框
  void _showSemesterPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => SemesterPickerDialog(
        currentSemester: _semester,
        onSemesterSelected: (semester) => setState(() => _semester = semester),
      ),
    );
  }

  /// 保存课程表单
  void _saveForm() {
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

    // 检查与已有课程的时间冲突
    for (var existingCourse in _courses) {
      if (TimeUtils.hasTimeConflict(
        List<List<dynamic>>.from(existingCourse['times']),
        List<int>.from(existingCourse['weeks']),
        validTimes,
        _weeks,
      )) {
        _showMessage('与已添加的 ${existingCourse['courseName']} 课程时间冲突');
        return;
      }
    }

    final courseData = {
      'courseName': _courseName,
      'teacherName': _teacherName,
      'remarks': _remarks,
      'color': [_currentColor.r, _currentColor.g, _currentColor.b],
      'times': validTimes,
      'weeks': _weeks,
      'semester': _semester,
    };

    setState(() {
      _courses.add(courseData);
      _resetForm();
    });

    _showMessage('${courseData['courseName']} 添加成功', isError: false);
  }

  /// 重置表单
  void _resetForm() {
    _formKey.currentState!.reset();
    _courseName = '';
    _teacherName = '';
    _remarks = '';
    _currentColor = Colors.primaries[_courses.length % Colors.primaries.length];
    _times = [[]];
    _weeks = [];
  }

  /// 完成添加并返回
  void _finishAndReturn() {
    if (_courses.isEmpty) {
      Navigator.pop(context);
    } else {
      Navigator.pop(context, List<Map<String, dynamic>>.from(_courses));
    }
  }

  /// 显示提示消息
  void _showMessage(String message, {bool isError = true}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: _currentColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: isError ? 2000 : 1500),
        margin: const EdgeInsets.only(
          bottom: kFloatingActionButtonMargin + 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: isError ? '知道了' : '好的',
          textColor: Colors.white,
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// 构建卡片组件
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusAll,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: _currentColor,
                secondary: _currentColor,
              ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _currentColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              '添加课程',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: _currentColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _finishAndReturn,
            ),
            actions: [
              TextButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  '添加',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              if (_courses.isNotEmpty)
                CourseList(
                  courses: _courses,
                  themeColor: _currentColor,
                  onFinish: _finishAndReturn,
                  onRemoveCourse: (index) =>
                      setState(() => _courses.removeAt(index)),
                ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildCard(
                        title: '选择学期',
                        icon: Icons.school,
                        child: SemesterPickerWidget(
                          currentSemester: _semester,
                          onSemesterPick: _showSemesterPickerDialog,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCard(
                        title: '课程信息',
                        icon: Icons.book,
                        child: CourseAddForm(
                          courseFocusNode: _courseFocusNode,
                          teacherFocusNode: _teacherFocusNode,
                          remarksFocusNode: _remarksFocusNode,
                          currentColor: _currentColor,
                          onColorPick: _showColorPicker,
                          onCourseSaved: (value) => _courseName = value ?? '',
                          onTeacherSaved: (value) => _teacherName = value ?? '',
                          onRemarksSaved: (value) => _remarks = value ?? '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCard(
                        title: '上课时间',
                        icon: Icons.access_time,
                        trailing: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('添加'),
                          onPressed: _showTimePickerDialog,
                        ),
                        child: TimePickerWidget(
                          times: _times,
                          currentColor: _currentColor,
                          onAddTime: _showTimePickerDialog,
                          onRemoveTime: (time) =>
                              setState(() => _times.remove(time)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCard(
                        title: '上课周次',
                        icon: Icons.date_range,
                        trailing: TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('选择'),
                          onPressed: _showWeekPickerDialog,
                        ),
                        child: WeekPickerWidget(
                          weeks: _weeks,
                          currentColor: _currentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
