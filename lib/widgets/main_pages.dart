import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schedule/widgets/course_add_page.dart';
import 'package:schedule/widgets/slide_table.dart';
import 'package:schedule/widgets/main_page/app_bar.dart';
import 'package:schedule/widgets/main_page/floating_menu.dart';
import 'package:schedule/widgets/main_page/week_manager.dart';
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
  late int _week;
  late int _curWeek;
  bool _showWeekend = false;
  bool _showTimeSlots = false;
  bool _showGrid = true;
  bool _isMenuOpen = false;
  Color _themeColor = Colors.teal;
  List<Map<String, dynamic>> courses = <Map<String, dynamic>>[];
  int _currentSemester = 1;
  late AnimationController _animationController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _initializeWeeks();
    _loadCourses();
    _loadSemester();
    _initializeAnimation();
    _initializePageController();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _initializePageController() {
    _pageController = PageController(
      initialPage: _week - 1,
      viewportFraction: 1.0,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _initializeWeeks() {
    _curWeek = WeekManager.calculateCurrentWeek();
    _week = _curWeek;
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
        _animationController.reverse();
      });
    }
  }

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
        _showMessage('成功添加 ${newCourses.length} 门课程', isError: false);
      } catch (e) {
        debugPrint('Error adding course: $e');
        _showMessage('添加课程失败，请重试');
      }
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: _themeColor,
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
                setState(() => _themeColor = color);
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

  Future<void> _deleteCourses() async {
    await CourseStorage.deleteCourses();
    setState(() => courses.clear());
  }

  Future<void> _loadCourses() async {
    try {
      final loadedCourses = await CourseStorage.getCourses();
      setState(() {
        courses = loadedCourses.map((course) {
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
      _showMessage('加载课程数据失败');
    }
  }

  Future<void> _loadSemester() async {
    final semester = await CourseStorage.getSemester();
    setState(() => _currentSemester = semester);
  }

  void _handleSemesterChange(int semester) async {
    setState(() => _currentSemester = semester);
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
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleGoBack() {
    _pageController.jumpToPage(_curWeek - 1);
    setState(() {
      _week = _curWeek;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeMenu,
      child: Scaffold(
        appBar: MainAppBar(
          formattedDate: WeekManager.getFormattedDate(),
          currentSemester: _currentSemester,
          currentWeek: _week,
          themeColor: _themeColor,
          onAddCourse: () => _onAddButtonPressed(context),
          onToggleWeekend: () => setState(() => _showWeekend = !_showWeekend),
          onSemesterTap: _showSemesterPicker,
          showWeekend: _showWeekend,
        ),
        body: SlideTable(
          controller: _pageController,
          onWeekChange: (week) => setState(() => _week = week),
          onSemesterChange: _handleSemesterChange,
          currentSemester: _currentSemester,
          offset: _week,
          showWeekend: _showWeekend,
          showTimeSlots: _showTimeSlots,
          showGrid: _showGrid,
          themeColor: _themeColor,
          courses: courses,
        ),
        floatingActionButton: FloatingMenu(
          isMenuOpen: _isMenuOpen,
          showGrid: _showGrid,
          showTimeSlots: _showTimeSlots,
          themeColor: _themeColor,
          onMenuToggle: () {
            setState(() {
              _isMenuOpen = !_isMenuOpen;
              if (_isMenuOpen) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            });
          },
          onGoBack: _handleGoBack,
          onGridToggle: () => setState(() => _showGrid = !_showGrid),
          onTimeSlotsToggle: () =>
              setState(() => _showTimeSlots = !_showTimeSlots),
          onColorPick: _showColorPicker,
          onDelete: _showDeleteConfirmation,
          animationController: _animationController,
        ),
      ),
    );
  }
}
