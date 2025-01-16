import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schedule/widgets/course_add_page.dart';
import 'package:schedule/widgets/slide_table.dart';
import '../utils/course_storage.dart';

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
  bool _showGrid = true; // 添加网格显示状态
  bool _isMenuOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 文本样式常量

  // 添加动画控制器和动画
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 添加主题色变量，默认使用 Colors.teal
  Color _themeColor = Colors.teal;

  List<Map<String, dynamic>> courses = <Map<String, dynamic>>[];

  // 添加当前学期状态
  int _currentSemester = 1;

  @override
  void initState() {
    super.initState();
    _initializeWeeks();
    _loadCourses();
    _loadSemester();

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
    final newCourses = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseAdd(
          currentSemester: _currentSemester,
          themeColor: _themeColor,
        ),
      ),
    );

    if (newCourses != null && newCourses is List && newCourses.isNotEmpty) {
      try {
        setState(() {
          courses.addAll(newCourses.cast<Map<String, dynamic>>());
        });
        await CourseStorage.saveCourses(courses);

        // 显示成功提示
        Future.delayed(const Duration(milliseconds: 100), () {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '成功添加 ${newCourses.length} 门课程',
                textAlign: TextAlign.center,
              ),
              backgroundColor: _themeColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
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
        });
      } catch (e) {
        debugPrint('Error adding course: $e');
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: const Text(
              '添加课程失败，请重试',
              textAlign: TextAlign.center,
            ),
            backgroundColor: _themeColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
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
      // 限制周次范围在1到20周之间
      if (week >= 1 && week <= 20) {
        _week = week;
      }
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
        _buildWeekDisplay(_currentSemester),
      ],
    );
  }

  /// 构建周次显示
  Widget _buildWeekDisplay(int currentSemester) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 添加学期显示
        GestureDetector(
          onTap: _showSemesterPicker, // 添加点击事件
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$currentSemester",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 周次显示
        Container(
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
                style: TextStyle(fontSize: 14, color: Colors.white),
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
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('确定要删除当前学期的所有课程吗？'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                '删除',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _deleteCourses();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCourses() async {
    await CourseStorage.deleteCourses();
    setState(() {
      courses.clear();
    });
  }

  Future<void> _loadCourses() async {
    try {
      final loadedCourses = await CourseStorage.getCourses();
      setState(() {
        courses = loadedCourses.map((course) {
          // 确保所有必要的字段都存在
          return {
            'courseName': course['courseName'] ?? '',
            'teacherName': course['teacherName'] ?? '',
            'remarks': course['remarks'] ?? '',
            'color': List<int>.from(course['color'] ?? [0, 0, 0]),
            'times': (course['times'] as List?)?.map((time) {
                  if (time is List) {
                    return time.map((item) => item.toString()).toList();
                  }
                  return [];
                }).toList() ??
                [],
            'weeks': List<int>.from(course['weeks'] ?? []),
            'semester': course['semester'] ?? 1,
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading courses: $e');
      // 可以在这里添加错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('加载课程数据失败')),
      );
    }
  }

  // 添加加载学期的方法
  Future<void> _loadSemester() async {
    final semester = await CourseStorage.getSemester();
    setState(() {
      _currentSemester = semester;
    });
  }

  // 添加处理学期变化的方法
  void _handleSemesterChange(int semester) async {
    setState(() {
      _currentSemester = semester;
    });
    await CourseStorage.saveSemester(semester);
  }

  void _showSemesterPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择学期'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              final semester = index + 1;
              return ListTile(
                title: Text('第$semester学期'),
                selected: _currentSemester == semester,
                onTap: () {
                  _handleSemesterChange(semester);
                  Navigator.pop(context);
                },
                // style: ListTileStyle.list,
                // // selectedTileColor: Colors.grey[200],
                // shape: const UnderlineInputBorder(
                //   borderSide: BorderSide(color: Colors.grey),
                // ),
              );
            },
          ),
        ),
      ),
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
          backgroundColor: _themeColor,
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
          onSemesterChange: _handleSemesterChange,
          currentSemester: _currentSemester,
          offset: _week,
          showWeekend: _showWeekend,
          showTimeSlots: _showTimeSlots,
          showGrid: _showGrid,
          themeColor: _themeColor,
          courses: courses,
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
            // 网格显示按钮
            ScaleTransition(
              scale: _scaleAnimation,
              child: Visibility(
                visible: _isMenuOpen,
                child: FloatingActionButton(
                  heroTag: 'grid',
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: Icon(
                    _showGrid ? Icons.grid_on : Icons.grid_off,
                    color: _themeColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _showGrid = !_showGrid;
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
            ScaleTransition(
              scale: _scaleAnimation,
              child: Visibility(
                visible: _isMenuOpen,
                child: FloatingActionButton(
                  heroTag: 'delete',
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 4,
                  onPressed: _showDeleteConfirmation,
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
