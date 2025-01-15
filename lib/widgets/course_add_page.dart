import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';

/// 课程数据模型
class Course {
  final String courseName;
  final String remarks;
  final List<int> color;
  final List<dynamic> times;
  final String teacherName;
  final List<int> weeks;

  const Course({
    required this.courseName,
    required this.remarks,
    required this.color,
    required this.times,
    required this.teacherName,
    required this.weeks,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        courseName: json['courseName'] as String,
        remarks: json['remarks'] as String,
        color: List<int>.from(json['color']),
        times: json['times'] as List<dynamic>,
        teacherName: json['teacherName'] as String,
        weeks: List<int>.from(json['weeks']),
      );

  Map<String, dynamic> toJson() => {
        'courseName': courseName,
        'remarks': remarks,
        'color': color,
        'times': times,
        'teacherName': teacherName,
        'weeks': weeks,
      };
}

class CourseAdd extends StatefulWidget {
  const CourseAdd({super.key});

  @override
  State<CourseAdd> createState() => _CourseAddState();
}

class _CourseAddState extends State<CourseAdd> {
  final _formKey = GlobalKey<FormState>();

  // 表单数据
  String _courseName = '';
  String _remarks = '';
  String _teacherName = '';
  Color _currentColor = Colors.blue;
  final List<List<dynamic>> _times = [[]];
  List<int> _weeks = List.generate(20, (index) => index + 1);

  bool _showValidationErrors = false;

  // 常量定义
  static const double _iconSize = 24.0;
  static const double _spacing = 10.0;
  static const List<String> _weekdays = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日'
  ];
  static const List<String> _periods = [
    '第一节',
    '第二节',
    '第三节',
    '第四节',
    '第五节',
    '第六节',
    '第七节',
    '第八节'
  ];

  void _saveForm() {
    setState(() => _showValidationErrors = true);

    if (_formKey.currentState!.validate() &&
        _validateTimes() &&
        _validateWeeks()) {
      _formKey.currentState!.save();

      final newCourse = Course(
        courseName: _courseName,
        remarks: _remarks,
        color: [_currentColor.red, _currentColor.green, _currentColor.blue],
        times: _times,
        teacherName: _teacherName,
        weeks: _weeks,
      );

      Navigator.of(context).pop(newCourse);
    }
  }

  bool _validateWeeks() => _weeks.isNotEmpty;

  bool _validateTimes() => _times.every((time) => time.length == 3);

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: AlertDialog(
            insetPadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.all(14.0),
            content: BlockPicker(
              pickerColor: _currentColor,
              onColorChanged: (Color color) {
                setState(() => _currentColor = color);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showTimePicker(int index) {
    Pickers.showMultiPicker(
      context,
      data: [_weekdays, _periods, _periods],
      pickerStyle: PickerStyle(
        textColor: Colors.black,
        textSize: 20,
      ),
      onConfirm: (values, indexes) => setState(() => _times[index] = values),
      onChanged: (values, indexes) => setState(() => _times[index] = values),
    );
  }

  Widget _buildTimePicker(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _spacing),
      child: InkWell(
        onTap: () => _showTimePicker(index),
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              const Icon(Icons.schedule, color: Colors.pink, size: _iconSize),
              const SizedBox(width: _spacing),
              Expanded(
                child: Row(
                  children: [
                    const Text('上课时间:'),
                    const SizedBox(width: _spacing),
                    Text(_times[index].isEmpty
                        ? '尚未选择时间'
                        : '${_times[index][0]} - ${_times[index][1]} - ${_times[index][2]}'),
                  ],
                ),
              ),
              if (_times.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _times.removeAt(index)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekPicker() {
    return StatefulBuilder(
      builder: (context, setStateOuter) => Padding(
        padding: const EdgeInsets.symmetric(vertical: _spacing),
        child: InkWell(
          onTap: () => _showWeekPickerDialog(setStateOuter),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.purple, size: _iconSize),
                const SizedBox(width: _spacing),
                Text('选择上课周次 ${_formatWeeks(_weeks)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekPickerDialog(
      List<int> tempWeeks, StateSetter setStateOuter) {
    return AlertDialog(
      title: const Text(
        '选择周次',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(19, (index) {
              final weekNumber = index + 1;
              return GestureDetector(
                onTap: () {
                  tempWeeks.contains(weekNumber)
                      ? tempWeeks.remove(weekNumber)
                      : tempWeeks.add(weekNumber);
                  (context as Element).markNeedsBuild();
                },
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: tempWeeks.contains(weekNumber)
                      ? Colors.blue
                      : Colors.transparent,
                  child: Text(
                    '$weekNumber',
                    style: TextStyle(
                      color: tempWeeks.contains(weekNumber)
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '取消',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () {
            if (tempWeeks.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: const Text(
                    '请至少选择一个周次！',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '确定',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              setStateOuter(() => _weeks = List.from(tempWeeks));
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            '确定',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return InkWell(
      onTap: _showColorPicker, // 点击时弹出颜色选择器
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            const Icon(
              Icons.color_lens_outlined,
              color: Colors.deepOrangeAccent,
              size: _iconSize,
            ),
            const SizedBox(width: _spacing),
            const Text('点击选择颜色:'),
            const SizedBox(width: _spacing),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _currentColor, // 显示当前选中的颜色
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Icon icon,
    required Function(String?) onSaved,
    Function(String)? onChanged,
    bool showError = false,
    String? errorText,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        icon: icon,
        border: InputBorder.none,
        errorText: showError ? errorText : null, // 显示错误提示
      ),
      onChanged: onChanged, // 输入内容变化时触发
      onSaved: onSaved, // 保存表单时触发
      validator: (value) {
        if (showError && (value == null || value.isEmpty)) {
          return errorText; // 验证失败时返回错误信息
        }
        return null; // 验证通过
      },
    );
  }

  void _showWeekPickerDialog(StateSetter setStateOuter) {
    List<int> tempWeeks = List.from(_weeks);
    showDialog(
      context: context,
      builder: (context) => _buildWeekPickerDialog(tempWeeks, setStateOuter),
    );
  }

  String _formatWeeks(List<int> weeks) {
    if (weeks.isEmpty) return '';

    weeks.sort();
    List<String> ranges = [];
    int start = weeks.first;
    int end = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        end = weeks[i];
      } else {
        ranges.add(start == end ? '$start' : '$start-$end');
        start = end = weeks[i];
      }
    }
    ranges.add(start == end ? '$start' : '$start-$end');

    return ranges.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  // AppBar构建方法
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: _currentColor,
      title: const Text('添加课程', style: TextStyle(color: Colors.white)),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: InkWell(
            onTap: _saveForm,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text("保存",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  // 主体内容构建方法
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildTextField(
              label: "课程名称",
              icon: const Icon(Icons.book, color: Colors.teal),
              onSaved: (value) => _courseName = value ?? "",
              showError: _showValidationErrors && _courseName.isEmpty,
              errorText: "请输入课程名称",
              onChanged: (value) => setState(() {
                _courseName = value;
                _showValidationErrors = false;
              }),
            ),
            const SizedBox(height: 20),
            _buildColorPicker(),
            const SizedBox(height: 20),
            ..._times.map((time) => _buildTimePicker(_times.indexOf(time))),
            if (_showValidationErrors && !_validateTimes())
              const Text('时间格式不正确', style: TextStyle(color: Colors.red)),
            _buildWeekPicker(),
            _buildTextField(
              label: "备注(可不填)",
              icon: const Icon(Icons.note, color: Colors.amber),
              onSaved: (value) => _remarks = value ?? "",
            ),
            const SizedBox(height: 10),
            _buildTextField(
              label: "授课老师(可不填)",
              icon: const Icon(Icons.person, color: Colors.lightBlue),
              onSaved: (value) => _teacherName = value ?? "",
            ),
          ],
        ),
      ),
    );
  }

  // 浮动按钮构建方法
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => setState(() => _times.add([])),
      tooltip: '添加上课时间',
      backgroundColor: Colors.white,
      child: const Icon(Icons.add, color: Colors.purple),
    );
  }
}
