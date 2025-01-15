import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schedule/utils/week_index.dart';
import 'package:schedule/widgets/course_add_page.dart';
import 'package:schedule/widgets/slide_table.dart';
import '../data/index.dart';

/// 主页面组件
/// 负责显示课程表和处理用户交互
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // 状态变量
  late int _week; // 当前显示的周次
  late int _curWeek; // 当前实际周次
  bool _showWeekend = false; // 是否显示周末
  bool _showTimeSlots = false;
  bool _isMenuOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 文本样式常量

  // 添加动画控制器和动画
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 添加主题色变量，默认使用 Colors.teal
  Color _themeColor = Colors.teal;

  @override
  void initState() {
    super.initState();
    _initializeWeeks();

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 初始化缩放动画
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 初始化周次
  void _initializeWeeks() {
    _curWeek = _calculateCurrentWeek();
    _week = _curWeek;
  }

  /// 关闭菜单的辅助方法
  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
        _animationController.reverse();
      });
    }
  }

  /// 添加新课程
  /// [context] 用于导航的上下文
  Future<void> _onAddButtonPressed(BuildContext context) async {
    _closeMenu();
    final newCourse = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CourseAdd()));

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

  /// 切换显示周末状态
  void _toggleWeekend() {
    _closeMenu();
    setState(() => _showWeekend = !_showWeekend);
  }

  /// 处理周次变化
  /// [week] 新的周次
  void _handleWeekChange(int week) {
    _closeMenu();
    setState(() {
      // 限制周次范围在1到19周之间
      if (week >= 1 && week <= 19) {
        _week = week;
      }
    });
  }

  /// 返回到当前周次
  void _handleWeekBack() => setState(() => _week = _curWeek);

  /// 更新当前周次
  /// [week] 新的当前周次
  Future<void> _handleCurWeekChange(int week) async {
    await WeekIndex.update(week);
    setState(() {
      _week = week;
      _curWeek = week;
    });
  }

  /// 获取格式化的当前日期
  String _getFormattedDate() {
    final date = DateTime.now();
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 计算当前周次
  /// 基于学期开始日期（9月1日）计算
  int _calculateCurrentWeek() {
    final now = DateTime.now();
    final currentYear = now.year;

    // 学期开始日期（假设每年9月1日开始）
    DateTime startOfWeek;
    if (now.month >= 9) {
      // 如果当前月份是9月或之后，学期开始日期是今年的9月1日
      startOfWeek = DateTime(currentYear, 9, 1);
    } else {
      // 如果当前月份是1月到8月，学期开始日期是上一年的9月1日
      startOfWeek = DateTime(currentYear - 1, 9, 1);
    }

    // 计算日期差值
    final difference = now.difference(startOfWeek).inDays;

    // 计算当前周次
    final currentWeek = (difference ~/ 7) + 1;

    // 确保周次不为负数
    return currentWeek > 0 ? currentWeek : 1;
  }

  /// 构建顶部栏标题
  Widget _buildAppBarTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            _getFormattedDate(),
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildWeekDisplay(),
      ],
    );
  }

  /// 构建周次显示
  Widget _buildWeekDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "第",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _week.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            "周",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建学期显示

  bool _shouldShowGoBack() {
    DateTime now = DateTime.now();
    DateTime semesterStart = DateTime(now.year, 9, 1); // 假设学期从9月1日开始
    return now.isAfter(semesterStart) && _curWeek > 1;
  }

  // 添加主题色选择方法
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择主题色'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _themeColor,
              onColorChanged: (Color color) {
                setState(() {
                  _themeColor = color;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeMenu,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _themeColor, // 使用主题色
          title: _buildAppBarTitle(),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _onAddButtonPressed(context),
            ),
            IconButton(
              icon: Icon(
                _showWeekend ? Icons.weekend : Icons.weekend_outlined,
                color: Colors.white,
              ),
              onPressed: _toggleWeekend,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SlideTable(
          onWeekChange: _handleWeekChange,
          offset: _week,
          showWeekend: _showWeekend,
          showTimeSlots: _showTimeSlots,
          themeColor: _themeColor,
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 返回按钮
            ScaleTransition(
              scale: _scaleAnimation,
              child: Visibility(
                visible: _isMenuOpen,
                child: FloatingActionButton(
                  heroTag: 'goBack',
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: Icon(Icons.arrow_back, color: _themeColor),
                  onPressed: () {
                    setState(() {
                      _week = _curWeek;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 时间显示按钮
            ScaleTransition(
              scale: _scaleAnimation,
              child: Visibility(
                visible: _isMenuOpen,
                child: FloatingActionButton(
                  heroTag: 'time',
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: Icon(
                    _showTimeSlots
                        ? Icons.access_time_filled
                        : Icons.access_time,
                    color: _themeColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _showTimeSlots = !_showTimeSlots;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 主题色选择按钮
            ScaleTransition(
              scale: _scaleAnimation,
              child: Visibility(
                visible: _isMenuOpen,
                child: FloatingActionButton(
                  heroTag: 'theme',
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 4,
                  onPressed: _showColorPicker,
                  child: Icon(Icons.palette, color: _themeColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 主菜单按钮
            FloatingActionButton(
              heroTag: 'menu',
              backgroundColor: _themeColor,
              elevation: 4,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _animationController,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isMenuOpen = !_isMenuOpen;
                  if (_isMenuOpen) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
