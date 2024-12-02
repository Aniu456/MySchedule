import 'package:flutter/material.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../data/index.dart';

class CourseAdd extends StatefulWidget {
  const CourseAdd({super.key});

  @override
  _CourseAddState createState() => _CourseAddState();
}

class Course {
  final String courseName;
  final String remarks;
  final List<int> color; // 修改为List<int>存储RGB形式
  final List<dynamic> times;
  final String teacherName;
  final List<int> weeks;

  Course({
    required this.courseName,
    required this.remarks,
    required this.color,
    required this.times,
    required this.teacherName,
    required this.weeks,
  });

  Map<String, dynamic> toJson() => {
        'courseName': courseName,
        'remarks': remarks,
        'color': color,
        'times': times,
        'teacherName': teacherName,
        'weeks': weeks,
      };
}

class _CourseAddState extends State<CourseAdd> {
  final _formKey = GlobalKey<FormState>();
  String _courseName = '';
  String _remarks = '';
  String _teacherName = '';
  Color _currentColor = Colors.blue;
  bool _showValidationErrors = false;
  final List<List<dynamic>> _times = [[]];

  void _saveForm() {
    setState(() {
      _showValidationErrors = true; // 触发错误提示
    });

    if (_formKey.currentState!.validate() &&
        _validateTimes() &&
        _validateWeeks()) {
      _formKey.currentState!.save(); // 确保保存表单数据
      // setState(() {
      //   courses.add({
      //     'courseName': _courseName,
      //     'remarks': _remarks,
      //     'color': [_currentColor.red, _currentColor.green, _currentColor.blue],
      //     'times': _times,
      //     'teacherName': _teacherName.isEmpty ? null : _teacherName,
      //     'weeks': _weeks, // 传递正确的周次值
      //   });
      // });
      // print("课程已保存: ${courses.last}"); // 打印保存的数据
      // Navigator.of(context).pop(); // 保存后返回
      Course newCourse = Course(
        courseName: _courseName,
        remarks: _remarks,
        color: [_currentColor.red, _currentColor.green, _currentColor.blue],
        times: _times,
        teacherName: _teacherName,
        weeks: _weeks,
      );
      Navigator.of(context).pop(newCourse);
    } else {
      // 如果验证不通过，打印错误信息
      print('表单验证失败');
    }
  }

  bool _validateWeeks() {
    // 确保weeks不为空，并且必须选中至少一个周次
    if (_weeks.isEmpty) {
      print("周次未选择"); // 调试输出
      return false;
    }
    return true;
  }

  bool _validateTimes() {
    for (var time in _times) {
      if (time.isEmpty || time.length != 3) {
        print("时间验证失败：$time");
        return false;
      }
    }
    return true;
  }

  void SelectColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3, // 设置高度为屏幕高度的30%
            child: AlertDialog(
              insetPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.all(14.0),
              content: BlockPicker(
                pickerColor: _currentColor,
                onColorChanged: (Color color) {
                  setState(() {
                    _currentColor = color;
                  });
                  Navigator.of(context).pop(); // 选择颜色后关闭对话框
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void SelectTime(BuildContext context, int index) {
    Pickers.showMultiPicker(
      context,
      data: [
        ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
        ['第一节', '第二节', '第三节', '第四节', '第五节', '第六节', '第七节', '第八节'],
        ['第一节', '第二节', '第三节', '第四节', '第五节', '第六节', '第七节', '第八节'],
      ],
      pickerStyle: PickerStyle(
        textColor: Colors.black,
        textSize: 20,
      ),
      onConfirm: (List<dynamic> values, List<int> indexes) {
        setState(() {
          _times[index] = values;
        });
      },
      onChanged: (List<dynamic> values, List<int> indexes) {
        setState(() {
          _times[index] = values;
        });
      },
    );
  }

  Widget _buildTimePicker(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          SelectTime(context, index);
        },
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              const Icon(
                Icons.schedule,
                color: Colors.pink,
              ),
              const SizedBox(width: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text('上课时间:'),
                  _times[index].isEmpty
                      ? const Text('尚未选择时间')
                      : Text(
                          ' ${_times[index][0]} - ${_times[index][1]} - ${_times[index][2]}')
                ],
              ),
              const SizedBox(width: 10.0),
              if (_times.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _times.removeAt(index);
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<int> _weeks = List.generate(20, (index) => index + 1); // 默认选中1到20周

  Widget _buildWeekPicker() {
    return StatefulBuilder(
      builder: (context, setStateOuter) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: InkWell(
            onTap: () {
              List<int> tempWeeks = List.from(_weeks); // 传递当前选中的周次

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
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
                              children: List.generate(20, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (tempWeeks.contains(index + 1)) {
                                        tempWeeks.remove(index + 1);
                                      } else {
                                        tempWeeks.add(index + 1);
                                      }
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor:
                                        tempWeeks.contains(index + 1)
                                            ? Colors.blue
                                            : Colors.transparent,
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: tempWeeks.contains(index + 1)
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
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '取消',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (tempWeeks.isEmpty) {
                                // 如果没有选中任何周次，显示警告对话框
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: const Text(
                                        '请至少选择一个周次！',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            '确定',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                setStateOuter(() {
                                  _weeks = List.from(tempWeeks); // 更新真正的周次值
                                });
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
                    },
                  );
                },
              );
            },
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    '选择上课周次 ${_getWeeksString(_weeks)}', // 使用更新后的 _weeks 列表
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getWeeksString(List<int> weeks) {
    if (weeks.isEmpty) return '';

    weeks.sort();
    List<String> weekRanges = [];
    int start = weeks.first;
    int end = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        end = weeks[i];
      } else {
        if (start == end) {
          weekRanges.add('$start');
        } else {
          weekRanges.add('$start-$end');
        }
        start = weeks[i];
        end = weeks[i];
      }
    }
    if (start == end) {
      weekRanges.add('$start');
    } else {
      weekRanges.add('$start-$end');
    }

    return weekRanges.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          toolbarTextStyle: const TextStyle(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white),
          backgroundColor: _currentColor,
          title: const Text('添加课程'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: InkWell(
                onTap: _saveForm,
                borderRadius: BorderRadius.circular(20), // 圆角区域
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: const Text(
                    "保存",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "课程名称",
                    labelStyle:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                    icon: const Icon(Icons.book, color: Colors.teal),
                    border: InputBorder.none,
                    errorText: _showValidationErrors && _courseName.isEmpty
                        ? "请输入课程名称"
                        : null, // 使用 errorText 来显示错误提示
                  ),
                  onChanged: (value) {
                    setState(() {
                      _courseName = value;
                      _showValidationErrors = false; // 输入时隐藏错误提示
                    });
                  },
                  onSaved: (value) {
                    _courseName = value ?? "";
                  },
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    SelectColor();
                  },
                  child: const SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        Icon(
                          Icons.color_lens_outlined,
                          color: Colors.deepOrangeAccent,
                        ),
                        SizedBox(width: 10.0),
                        Text('点击选择颜色:'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ..._times.map((time) => _buildTimePicker(_times.indexOf(time))),
                if (_showValidationErrors && !_validateTimes())
                  const Text('格式不对', style: TextStyle(color: Colors.red)),
                _buildWeekPicker(),
                TextFormField(
                    decoration: const InputDecoration(
                        labelText: "备注(可不填)",
                        labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        icon: Icon(
                          Icons.book,
                          color: Colors.amber,
                        ),
                        border: InputBorder.none),
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {
                      _remarks = value ?? "";
                    }),
                const SizedBox(height: 10),
                TextFormField(
                    decoration: const InputDecoration(
                        labelText: "授课老师(可不填)",
                        labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        icon: Icon(
                          Icons.book,
                          color: Colors.lightBlue,
                        ),
                        border: InputBorder.none),
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {
                      _teacherName = value ?? "";
                    }),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _times.add([]);
            });
          },
          tooltip: '添加上课时间',
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.add,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }
}
