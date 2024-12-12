import 'package:flutter/material.dart';
import 'package:schedule/utils/week_index.dart'; // 导入周索引工具
import 'package:schedule/widgets/course_add_page.dart'; // 导入课程添加页面组件
import 'package:schedule/widgets/slide_table.dart'; // 导入滑动表格组件

import '../data/index.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key}); // 简化构造函数

  @override
  State<MainPage> createState() => _MainPageState(); // 简化状态声明
}

class _MainPageState extends State<MainPage> {
  int _week = 1; // 当前显示的周次，初始化为1
  int _curWeek = 1; // 当前设置的周次，初始化为1
  bool _showWeekend = false; // 控制是否显示周末
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onAddButtonPressed(BuildContext context) async {
    final newCourse =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const CourseAdd();
    }));
    if (newCourse != null) {
      if (newCourse != null) {
        setState(() {
          courses.add({
            'courseName': newCourse.courseName,
            'remarks': newCourse.remarks,
            'color': newCourse.color,
            'times': newCourse.times,
            'teacherName': newCourse.teacherName,
            'weeks': newCourse.weeks,
          });
        });
      }
    }
  }

  // 切换 _showWeekend 的状态
  void _toggleWeekend() {
    setState(() {
      _showWeekend = !_showWeekend;
    });
  }

  // 处理周次改变事件
  void handleWeekChange(int week) {
    setState(() {
      _week = week; // 更新当前显示的周次
    });
  }

  // 处理返回当前周次按钮按下事件
  void handleWeekBack() {
    setState(() {
      _week = _curWeek; // 更新当前显示的周次为当前设置的周次
    });
  }

  // 处理当前周次改变事件
  void handleCurWeekChange(int week) async {
    WeekIndex.update(week); // 更新周索引工具中的周次
    setState(() {
      _week = week; // 更新当前显示的周次
      _curWeek = week; // 更新当前设置的周次
    });
  }

  //获取当前时间
  String getFormattedDate() {
    final date = DateTime.now();
    return '${date.year}/${date.month}/${date.day}'; // 根据需求可以自定义日期格式
  }

// 计算当前周次
  int _calculateCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, 9, 2);
    final difference = now.difference(startOfWeek).inDays;
    return (difference ~/ 7) + 1;
  }

  @override
  void initState() {
    super.initState();
    _curWeek = _calculateCurrentWeek();
    _week = _curWeek;
  }

  @override
  Widget build(BuildContext context) {
    //获取当前时间
    String getFormattedDate() {
      final date = DateTime.now();
      return '${date.year}年${date.month}月${date.day}日'; // 根据需求可以自定义日期格式
    }

    return Scaffold(
      key: _scaffoldKey, // 使用全局键
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              getFormattedDate(),
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 60,
              child: Row(
                children: [
                  const Text(
                    "第",
                    style: TextStyle(fontSize: 14),
                  ), // 显示“第”文字
                  SizedBox(
                    width: 30.0,
                    child: Center(
                      child: Text(
                        _week.toString(),
                        // _calculateCurrentWeek().toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ), // 显示当前周次
                    ),
                  ),
                  const Text(
                    "周",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )
          ],
        ),
        actions: <Widget>[
          IconButton(
            // 定义AppBar的动作按钮
            icon: const Icon(Icons.add), // 使用添加图标
            onPressed: () {
              _onAddButtonPressed(context); // 调用添加按钮按下事件处理函数
            },
          ),
          IconButton(
            // 定义AppBar的动作按钮
            icon: Icon(_showWeekend
                ? Icons.weekend
                : Icons.weekend_outlined), // 使用添加图标
            onPressed: () {
              _toggleWeekend(); // 调用添加按钮按下事件处理函数
            },
          ),
        ],
      ),
      body: SlideTable(
        // 使用滑动表格组件作为body
        onWeekChange: handleWeekChange, // 设置周次改变的回调
        offset: _week, // 设置滑动表格的偏移量
        showWeekend: _showWeekend,
      ),
      floatingActionButton: FloatingActionButton(
        // 定义浮动操作按钮
        onPressed: handleWeekBack, // 设置按钮按下的回调
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.arrow_back,
          color: Colors.purple,
        ), // 使用返回图标
      ),
    );
  }
}
