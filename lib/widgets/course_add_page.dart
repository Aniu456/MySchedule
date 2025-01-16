import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';

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
  final List<Map<String, dynamic>> _courses = [];

  // 当前编辑的课程数据
  String _courseName = '';
  String _teacherName = '';
  String _remarks = '';
  Color _currentColor = Colors.blue;
  List<List<dynamic>> _times = [[]];
  List<int> _weeks = [];
  late int _semester;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.themeColor;
    _semester = widget.currentSemester;
  }

  static const _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const _periods = [
    '第一节',
    '第二节',
    '第三节',
    '第四节',
    '第五节',
    '第六节',
    '第七节',
    '第八节'
  ];

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择课程颜色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) {
              setState(() => _currentColor = color);
            },
            pickerAreaHeightPercent: 0.8,
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

  void _addTimeSlot() {
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
              // 选择星期
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDay,
                    hint: const Text('选择星期'),
                    isExpanded: true,
                    items: _weekdays.map((day) {
                      return DropdownMenuItem(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedDay = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 选择节数
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: startPeriod,
                          hint: const Text('开始节数'),
                          isExpanded: true,
                          items: List.generate(10, (i) {
                            return DropdownMenuItem(
                              value: i + 1,
                              child: Text('第${i + 1}节'),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              startPeriod = value;
                              if (endPeriod != null && endPeriod! < value!) {
                                endPeriod = value;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('到'),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: endPeriod,
                          hint: const Text('结束节数'),
                          isExpanded: true,
                          items: startPeriod != null
                              ? List.generate(10 - startPeriod! + 1, (i) {
                                  return DropdownMenuItem(
                                    value: i + startPeriod!,
                                    child: Text('第${i + startPeriod!}节'),
                                  );
                                })
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

  void _addTime(String day, int start, int end) {
    // 检查时间冲突
    bool hasOverlap = _times.any((existingTime) {
      if (existingTime.isEmpty) return false;
      if (existingTime[0] != day) return false;

      int existingStart = _periodToNumber(existingTime[1].toString());
      int existingEnd = _periodToNumber(existingTime[2].toString());

      return !(end < existingStart || start > existingEnd);
    });

    if (hasOverlap) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            '该时间段与已选时间重叠',
            textAlign: TextAlign.center,
          ),
          backgroundColor: _currentColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: '知道了',
            textColor: Colors.white,
            onPressed: () => messenger.hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    setState(() {
      // 移除空列表
      _times.removeWhere((time) => time.isEmpty);
      // 添加新时间
      _times.add([
        day,
        start.toString(),
        end.toString(),
      ]);
    });
  }

  // 移除时间段
  void _removeTimeSlot(List<dynamic> time) {
    setState(() {
      _times.remove(time);
    });
  }

  // 清空所有时间段
  void _clearTimeSlots() {
    setState(() {
      _times = [[]];
    });
  }

  int _periodToNumber(String period) {
    if (period.contains('第')) {
      return int.parse(period.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    return int.parse(period);
  }

  void _showWeekPicker() {
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
              return InkWell(
                onTap: () {
                  setState(() {
                    if (tempWeeks.contains(weekNum)) {
                      tempWeeks.remove(weekNum);
                    } else {
                      tempWeeks.add(weekNum);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: tempWeeks.contains(weekNum)
                        ? _currentColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$weekNum',
                      style: TextStyle(
                        color: tempWeeks.contains(weekNum)
                            ? Colors.white
                            : Colors.black,
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

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      _showError('请填写必要信息');
      return;
    }

    _formKey.currentState!.save();

    // 检查必填项
    if (_courseName.isEmpty) {
      _showError('请输入课程名称');
      return;
    }
    if (_teacherName.isEmpty) {
      _showError('请输入授课教师');
      return;
    }
    if (_times.isEmpty || _times.every((t) => t.isEmpty)) {
      _showError('请添加上课时间');
      return;
    }
    if (_weeks.isEmpty) {
      _showError('请选择上课周次');
      return;
    }

    // 检查是否与已添加的课程时间冲突
    for (var existingCourse in _courses) {
      bool hasConflict = _checkTimeConflict(
        List<List<dynamic>>.from(existingCourse['times']),
        List<int>.from(existingCourse['weeks']),
        _times,
        _weeks,
      );

      if (hasConflict) {
        _showError('与已添加的 ${existingCourse['courseName']} 课程时间冲突');
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
      // 重置表单
      _formKey.currentState!.reset();
      _courseName = '';
      _teacherName = '';
      _remarks = '';
      _currentColor =
          Colors.primaries[_courses.length % Colors.primaries.length];
      _times = [[]];
      _weeks = [];
    });

    // 显示成功提示
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${courseData['courseName']} 添加成功',
          textAlign: TextAlign.center,
        ),
        backgroundColor: _currentColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        margin: const EdgeInsets.only(
          bottom: kFloatingActionButtonMargin + 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: '好的',
          textColor: Colors.white,
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  bool _checkTimeConflict(
    List<List<dynamic>> existingTimes,
    List<int> existingWeeks,
    List<List<dynamic>> newTimes,
    List<int> newWeeks,
  ) {
    // 检查周次是否有重叠
    bool hasWeekOverlap = existingWeeks.any((week) => newWeeks.contains(week));
    if (!hasWeekOverlap) return false;

    // 检查时间是否有重叠
    return existingTimes.any((existingTime) {
      return newTimes.any((newTime) {
        if (existingTime.isEmpty || newTime.isEmpty) return false;
        if (existingTime[0] != newTime[0]) return false; // 不同星期

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

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index);
    });
  }

  void _showError(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: _currentColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
        margin: const EdgeInsets.only(
          bottom: kFloatingActionButtonMargin + 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: '知道了',
          textColor: Colors.white,
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
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
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _currentColor,
          contentTextStyle: const TextStyle(color: Colors.white),
          actionTextColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('添加课程'),
          backgroundColor: _currentColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
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
            // 已添加课程列表
            if (_courses.isNotEmpty)
              Container(
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
                            Icon(Icons.list_alt,
                                size: 20, color: _currentColor),
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
                          icon:
                              Icon(Icons.check, size: 20, color: _currentColor),
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
              ),

            // 课程表单
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 学期选择卡片
                    _buildCard(
                      title: '选择学期',
                      icon: Icons.school,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('第$_semester学期'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _showSemesterPicker,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 基本信息卡片
                    _buildCard(
                      title: '课程信息',
                      icon: Icons.book,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: '课程名称',
                              prefixIcon: Icon(Icons.book),
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? '请输入课程名称' : null,
                            onSaved: (value) => _courseName = value ?? '',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: '授课教师',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? '请输入授课教师' : null,
                                  onSaved: (value) =>
                                      _teacherName = value ?? '',
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
                                    border:
                                        Border.all(color: Colors.grey[300]!),
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
                    ),
                    const SizedBox(height: 16),

                    // 时间选择卡片
                    _buildCard(
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
                                      backgroundColor:
                                          _currentColor.withOpacity(0.1),
                                      label: Text(
                                        '${time[0]} 第${time[1]}-${time[2]}节',
                                        style: TextStyle(color: _currentColor),
                                      ),
                                      deleteIcon: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: _currentColor,
                                      ),
                                      onDeleted: () {
                                        setState(() => _times.remove(time));
                                      },
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
                    ),
                    const SizedBox(height: 16),

                    // 周次选择卡片
                    _buildCard(
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
                                        backgroundColor:
                                            _currentColor.withOpacity(0.1),
                                        label: Text(
                                          '第$week周',
                                          style:
                                              TextStyle(color: _currentColor),
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
