import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CourseAdd extends StatefulWidget {
  final int currentSemester;
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
  final _formKey = GlobalKey<FormState>();
  final _courseFocusNode = FocusNode();
  final _teacherFocusNode = FocusNode();
  final _remarksFocusNode = FocusNode();
  final List<Map<String, dynamic>> _courses = [];

  String _courseName = '';
  String _teacherName = '';
  String _remarks = '';
  Color _currentColor = Colors.blue;
  List<List<dynamic>> _times = [[]];
  List<int> _weeks = [];
  late int _semester;

  static const _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  void initState() {
    super.initState();
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

  void _unfocusAll() {
    _courseFocusNode.unfocus();
    _teacherFocusNode.unfocus();
    _remarksFocusNode.unfocus();
  }

  // 显示颜色选择器
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

  // 添加时间段
  void _addTimeSlot() {
    _unfocusAll();
    String? selectedDay;
    int? startPeriod;
    int? endPeriod;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('选择上课时间'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown(
                value: selectedDay,
                hint: '选择星期',
                items: _weekdays
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
                          _addTime(selectedDay!, startPeriod!, value);
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
        ),
      ),
    );
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
          hint: Text(hint),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // 添加时间
  void _addTime(String day, int start, int end) {
    bool hasOverlap = _times.any((existingTime) {
      if (existingTime.isEmpty || existingTime[0] != day) return false;
      int existingStart = _periodToNumber(existingTime[1].toString());
      int existingEnd = _periodToNumber(existingTime[2].toString());
      return !(end < existingStart || start > existingEnd);
    });

    if (hasOverlap) {
      _showMessage('该时间段与已选时间重叠');
      return;
    }

    setState(() {
      _times.removeWhere((time) => time.isEmpty);
      _times.add([day, start.toString(), end.toString()]);
    });
  }

  // 移除时间段
  void _removeTimeSlot(List<dynamic> time) =>
      setState(() => _times.remove(time));

  // 清空所有时间段
  void _clearTimeSlots() => setState(() => _times = [[]]);

  int _periodToNumber(String period) {
    if (period.contains('第')) {
      return int.parse(period.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    return int.parse(period);
  }

  // 显示周次选择器
  void _showWeekPicker() {
    _unfocusAll();
    List<int> tempWeeks = List.from(_weeks);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              final selected = tempWeeks.contains(weekNum);
              return InkWell(
                onTap: () => setState(() {
                  if (selected) {
                    tempWeeks.remove(weekNum);
                  } else {
                    tempWeeks.add(weekNum);
                  }
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? _currentColor : Colors.grey[200],
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
              setState(() => _weeks = tempWeeks);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 显示学期选择器
  void _showSemesterPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                selected: _semester == semester,
                onTap: () {
                  setState(() => _semester = semester);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // 保存表单
  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      _showMessage('请填写必要信息');
      return;
    }

    _formKey.currentState!.save();

    // 检查必填项
    if (_courseName.isEmpty) {
      _showMessage('请输入课程名称');
      return;
    }
    if (_teacherName.isEmpty) {
      _showMessage('请输入授课教师');
      return;
    }
    if (_times.isEmpty || _times.every((t) => t.isEmpty)) {
      _showMessage('请添加上课时间');
      return;
    }
    if (_weeks.isEmpty) {
      _showMessage('请选择上课周次');
      return;
    }

    // 检查时间冲突
    for (var existingCourse in _courses) {
      if (_checkTimeConflict(
        List<List<dynamic>>.from(existingCourse['times']),
        List<int>.from(existingCourse['weeks']),
        _times,
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
      'color': [_currentColor.red, _currentColor.green, _currentColor.blue],
      'times': _times.where((t) => t.isNotEmpty).toList(),
      'weeks': _weeks,
      'semester': _semester,
    };

    setState(() {
      _courses.add(courseData);
      _resetForm();
    });

    _showMessage('${courseData['courseName']} 添加成功', isError: false);
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _courseName = '';
    _teacherName = '';
    _remarks = '';
    _currentColor = Colors.primaries[_courses.length % Colors.primaries.length];
    _times = [[]];
    _weeks = [];
  }

  bool _checkTimeConflict(
    List<List<dynamic>> existingTimes,
    List<int> existingWeeks,
    List<List<dynamic>> newTimes,
    List<int> newWeeks,
  ) {
    if (!existingWeeks.any((week) => newWeeks.contains(week))) return false;

    return existingTimes.any((existingTime) {
      return newTimes.any((newTime) {
        if (existingTime.isEmpty || newTime.isEmpty) return false;
        if (existingTime[0] != newTime[0]) return false;

        int existingStart = int.parse(existingTime[1].toString());
        int existingEnd = int.parse(existingTime[2].toString());
        int newStart = int.parse(newTime[1].toString());
        int newEnd = int.parse(newTime[2].toString());

        return !(newEnd < existingStart || newStart > existingEnd);
      });
    });
  }

  void _finishAndReturn() {
    if (_courses.isEmpty) {
      Navigator.pop(context);
    } else {
      Navigator.pop(context, _courses);
    }
  }

  void _removeCourse(int index) => setState(() => _courses.removeAt(index));

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusAll,
      child: Theme(
        data: _buildThemeData(context),
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              if (_courses.isNotEmpty) _buildCoursesList(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSemesterCard(),
                      const SizedBox(height: 16),
                      _buildBasicInfoCard(),
                      const SizedBox(height: 16),
                      _buildTimeCard(),
                      const SizedBox(height: 16),
                      _buildWeeksCard(),
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

  ThemeData _buildThemeData(BuildContext context) {
    return Theme.of(context).copyWith(
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
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _currentColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
          label: const Text(
            '添加',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesList() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.list_alt, size: 20, color: _currentColor),
                  const SizedBox(width: 8),
                  Text(
                    '已添加 ${_courses.length} 门课程',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _finishAndReturn,
                icon: Icon(Icons.check, size: 20, color: _currentColor),
                label: Text(
                  '完成',
                  style: TextStyle(
                    color: _currentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: _currentColor.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_courses.length, (index) {
              final course = _courses[index];
              final courseColor = Color.fromRGBO(
                course['color'][0],
                course['color'][1],
                course['color'][2],
                1,
              );
              return Chip(
                label: Text(
                  course['courseName'],
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: courseColor,
                deleteIcon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
                onDeleted: () => _removeCourse(index),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard() {
    return _buildCard(
      title: '选择学期',
      icon: Icons.school,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('第$_semester学期'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _showSemesterPicker,
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard(
      title: '课程信息',
      icon: Icons.book,
      child: Column(
        children: [
          TextFormField(
            focusNode: _courseFocusNode,
            decoration: const InputDecoration(
              labelText: '课程名称',
              prefixIcon: Icon(Icons.book),
            ),
            validator: (value) => value?.isEmpty ?? true ? '请输入课程名称' : null,
            onSaved: (value) => _courseName = value ?? '',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  focusNode: _teacherFocusNode,
                  decoration: const InputDecoration(
                    labelText: '授课教师',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? '请输入授课教师' : null,
                  onSaved: (value) => _teacherName = value ?? '',
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: _showColorPicker,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.color_lens,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            focusNode: _remarksFocusNode,
            decoration: const InputDecoration(
              labelText: '备注（选填，最多20字）',
              prefixIcon: Icon(Icons.note),
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 1,
            maxLength: 20,
            onSaved: (value) => _remarks = value ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    return _buildCard(
      title: '上课时间',
      icon: Icons.access_time,
      trailing: TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('添加'),
        onPressed: _addTimeSlot,
      ),
      child: Column(
        children: [
          if (_times.any((time) => time.isNotEmpty))
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _times
                  .where((time) => time.isNotEmpty)
                  .map(
                    (time) => Chip(
                      backgroundColor: _currentColor.withOpacity(0.1),
                      label: Text(
                        '${time[0]} 第${time[1]}-${time[2]}节',
                        style: TextStyle(color: _currentColor),
                      ),
                      deleteIcon: Icon(
                        Icons.close,
                        size: 18,
                        color: _currentColor,
                      ),
                      onDeleted: () => _removeTimeSlot(time),
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
      ),
    );
  }

  Widget _buildWeeksCard() {
    return _buildCard(
      title: '上课周次',
      icon: Icons.date_range,
      trailing: TextButton.icon(
        icon: const Icon(Icons.edit),
        label: const Text('选择'),
        onPressed: _showWeekPicker,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_weeks.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _weeks
                  .map((week) => Chip(
                        backgroundColor: _currentColor.withOpacity(0.1),
                        label: Text(
                          '第$week周',
                          style: TextStyle(color: _currentColor),
                        ),
                      ))
                  .toList(),
            )
          else
            Center(
              child: Text(
                '点击右上角选择按钮选择上课周次',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
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
}
