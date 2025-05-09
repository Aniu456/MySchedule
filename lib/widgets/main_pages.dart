import 'package:flutter/material.dart';
import 'package:schedule/widgets/course_add_page.dart';
import 'package:schedule/widgets/first_semester_setup.dart';
import 'package:schedule/widgets/slide_table.dart';
import 'package:schedule/widgets/main_page/app_bar.dart';
import 'package:schedule/widgets/main_page/floating_menu.dart';
import 'package:schedule/widgets/main_page/week_manager.dart';
import 'package:schedule/widgets/main_page/semester_manager.dart';
import 'package:schedule/widgets/main_page/dialog_manager.dart';
import 'package:schedule/widgets/main_page/course_manager.dart';
import 'package:schedule/widgets/main_page/notification_manager.dart';
import '../utils/course_storage_hive.dart';
import '../utils/semester_utils.dart';

/// 主页面组件
/// 负责显示课程表和处理用户交互，包括：
/// - 课程的显示和管理
/// - 周次的切换和显示
/// - 主题颜色的设置
/// - 显示选项的控制（周末、时间段、网格）
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // 周次相关
  late int _week = 1; // 给_week一个初始值，避免LateInitializationError
  late int _curWeek = 1;

  // 显示选项
  bool _showWeekend = false;
  bool _showTimeSlots = false;
  bool _showGrid = true;
  bool _isMenuOpen = false;

  // 主题和课程数据
  Color _themeColor = Colors.teal;
  List<Map<String, dynamic>> courses = <Map<String, dynamic>>[];
  int _currentSemester = 1;

  // 控制器和Key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late PageController _pageController;

  // 管理器
  late SemesterManager _semesterManager;
  late DialogManager _dialogManager;
  late CourseManager _courseManager;
  late NotificationManager _notificationManager;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();

    // 初始化管理器（在initState中不能直接使用context，所以在_initApp中初始化）
    _initApp();
  }

  /// 异步初始化应用
  Future<void> _initApp() async {
    // 初始化管理器
    _notificationManager = NotificationManager(
      context: context,
      themeColor: _themeColor,
    );

    _semesterManager = SemesterManager(
      showMessage: _notificationManager.showMessage,
      setState: setState,
      context: context,
      themeColor: _themeColor,
    );

    _dialogManager = DialogManager(
      context: context,
      themeColor: _themeColor,
    );

    _courseManager = CourseManager(
      showMessage: _notificationManager.showMessage,
      setState: setState,
    );

    // 清除无效的学期数据
    await CourseStorageHive.clearInvalidSemesterData();

    // 检查第一学期是否已设置
    bool hasFirstSemester = await CourseStorageHive.hasSemesterStartDate(1);
    if (!hasFirstSemester && mounted) {
      // 如果未设置第一学期且界面仍然存在，跳转到设置页面
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const FirstSemesterSetup()),
      );
      return;
    }

    // 先加载学期，然后加载周次，最后加载课程
    await _loadSemester();
    await _loadCourses();

    // 不再自动检测和推荐学期
  }

  /// 初始化动画控制器
  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageController = PageController(initialPage: _week - 1);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// 初始化周次
  Future<void> _initializeWeeks() async {
    _curWeek = await WeekManager.calculateCurrentWeek(_currentSemester);
    setState(() {
      _week = _curWeek;
    });
  }

  /// 关闭浮动菜单
  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
        _animationController.reverse();
      });
    }
  }

  /// 处理添加课程
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
      final success = await _courseManager.addCourses(
          courses, newCourses.cast<Map<String, dynamic>>());

      // 添加课程成功后，强制更新UI
      if (success) {
        setState(() {
          // 课程已在列表中更新，触发UI刷新
        });
      }
    }
  }

  /// 显示消息提示
  void _showMessage(String message, {bool isError = true}) {
    _notificationManager.showMessage(message, isError: isError);
  }

  /// 显示颜色选择器
  void _showColorPicker() async {
    final newColor = await _dialogManager.showColorPicker();
    if (newColor != null) {
      setState(() => _themeColor = newColor);

      // 只更新主题色，而不是重新创建整个实例
      _notificationManager.updateThemeColor(_themeColor);
      _dialogManager.updateThemeColor(_themeColor);
      _semesterManager.updateThemeColor(_themeColor);
    }
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmation() async {
    final confirmDelete = await _dialogManager.showDeleteConfirmation();
    if (confirmDelete) {
      final success = await _courseManager.deleteAllCourses();
      if (success) {
        setState(() => courses.clear());
      }
    }
  }

  /// 加载课程数据
  Future<void> _loadCourses() async {
    final loadedCourses = await _courseManager.loadCourses();
    setState(() {
      courses = loadedCourses;
    });
  }

  /// 加载学期数据
  Future<void> _loadSemester() async {
    final semester = await _semesterManager.loadSemester();
    setState(() {
      _currentSemester = semester;
    });
    await _initializeWeeks();
  }

  /// 显示学期选择对话框
  void _showSemesterPicker() async {
    // 确保当前学期在1-10范围内
    if (_currentSemester < 1 || _currentSemester > 10) {
      setState(() {
        _currentSemester = _currentSemester.clamp(1, 10);
      });
    }

    // 使用对话框管理器显示学期选择对话框
    await _dialogManager.showSemesterPicker(
      currentSemester: _currentSemester,
      buildSemesterList: () => _buildSemesterList(),
    );
  }

  /// 处理学期变更
  Future<void> _handleSemesterChange(int semester) async {
    await _semesterManager.handleSemesterChange(
      semester,
      currentSemester: _currentSemester,
      onSemesterChanged: (newSemester, newCurWeek, newWeek) {
        setState(() {
          _currentSemester = newSemester;
          _curWeek = newCurWeek;
          _week = newWeek;
        });
      },
      onPageControllerReset: () {
        if (_pageController.hasClients) {
          _pageController.dispose();
        }
        _pageController = PageController(initialPage: _curWeek - 1);
      },
      onCoursesNeedReload: () async {
        await _loadCourses();
      },
    );
  }

  /// 构建学期列表项
  Future<List<Widget>> _buildSemesterList() async {
    List<Widget> originalItems =
        await _semesterManager.buildSemesterList(_currentSemester);
    List<Widget> modifiedItems = [];

    for (Widget item in originalItems) {
      // 处理"添加学期"按钮
      if (item is Container && item.child is ElevatedButton) {
        final button = item.child as ElevatedButton;

        // 检查是否为添加按钮
        if (button.child is Row) {
          final row = button.child as Row;
          if (row.children.isNotEmpty &&
              row.children.first is Icon &&
              (row.children.first as Icon).icon == Icons.add) {
            // 从隐藏数据中提取学期编号
            int semesterToAdd = 1; // 默认值
            for (Widget child in row.children) {
              if (child is Opacity && child.child is Text) {
                final text = (child.child as Text).data ?? '';
                final match = RegExp(r'semester:(\d+)').firstMatch(text);
                if (match != null) {
                  semesterToAdd = int.parse(match.group(1) ?? '1');
                  break;
                }
              }
            }

            // 创建新按钮并添加点击回调
            modifiedItems.add(
              Container(
                margin: item.margin,
                child: ElevatedButton(
                  onPressed: () => _addNewSemester(semesterToAdd),
                  style: button.style,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('添加学期'),
                    ],
                  ),
                ),
              ),
            );
            continue;
          }
        }
      }

      // 处理其他控件，代码保持不变...
      if (item is Container && item.child is ListTile) {
        final listTile = item.child as ListTile;

        // 获取学期编号
        int? semester;
        if (listTile.leading is CircleAvatar) {
          final avatarText = (listTile.leading as CircleAvatar).child;
          if (avatarText is Text) {
            semester = int.tryParse(avatarText.data ?? '');
          }
        }

        if (semester != null) {
          // 修改ListTile，添加适当的回调
          modifiedItems.add(
            Container(
              margin: item.margin,
              decoration: item.decoration,
              child: ListTile(
                contentPadding: listTile.contentPadding,
                leading: listTile.leading,
                title: listTile.title,
                subtitle: listTile.subtitle,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      color: _themeColor,
                      onPressed: () {
                        Navigator.pop(context);
                        // 此处使用!运算符，因为我们已经检查过semester不为null
                        _showDatePicker(semester!);
                      },
                      tooltip: '设置开始日期',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.check_circle,
                        size: semester == _currentSemester ? 28 : 24,
                      ),
                      color: semester == _currentSemester
                          ? _themeColor
                          : Colors.grey,
                      onPressed: () {
                        Navigator.pop(context);
                        _handleSemesterChange(semester!);
                      },
                      tooltip: '选择此学期',
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(Duration.zero, () {
                    _handleSemesterChange(semester!);
                  });
                },
                selected: semester == _currentSemester,
              ),
            ),
          );
        } else {
          modifiedItems.add(item);
        }
      } else {
        // 不需要修改的项直接添加
        modifiedItems.add(item);
      }
    }

    return modifiedItems;
  }

  /// 添加新学期
  void _addNewSemester(int semester) async {
    Navigator.pop(context); // 关闭学期选择对话框

    // 显示日期选择器
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: '选择第$semester学期开始日期',
      confirmText: '确定',
      cancelText: '取消',
      locale: const Locale('zh'), // 设置语言为中文
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _themeColor, // 使用主题色
              onPrimary: Colors.white, // 主题色上的文字颜色
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final success =
          await _semesterManager.setupNewSemesterDate(semester, selectedDate);
      if (success) {
        // 如果添加成功，询问是否切换到新学期
        final shouldSwitch =
            await _dialogManager.showSwitchSemesterDialog(semester);
        if (shouldSwitch) {
          _handleSemesterChange(semester);
        } else {
          // 刷新学期列表
          _showSemesterPicker();
        }
      }
    }
  }

  /// 显示日期选择器
  void _showDatePicker(int semester) async {
    // 获取初始日期
    DateTime? semesterDate =
        await CourseStorageHive.getSemesterStartDate(semester);

    if (semesterDate == null) {
      semesterDate = DateTime.now();
      // 调整到周一
      if (semesterDate.weekday != DateTime.monday) {
        semesterDate =
            semesterDate.add(Duration(days: (8 - semesterDate.weekday) % 7));
      }
    }

    // 使用对话框管理器显示日期选择器
    final adjustedDate =
        await _dialogManager.showSemesterDatePicker(semester, semesterDate);

    if (adjustedDate != null) {
      try {
        // 验证日期是否有效
        bool isValid =
            await _semesterManager.validateSemesterDate(semester, adjustedDate);
        if (!isValid) {
          return; // 如果日期无效，直接返回，不保存
        }

        // 保存学期开始日期
        await SemesterUtils.setSemesterStartDate(semester, adjustedDate);

        // 如果是当前学期，强制刷新当前视图
        if (semester == _currentSemester) {
          await _initializeWeeks();

          // 确保状态更新后再刷新页面
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(_week - 1);
            }
          });
        }

        setState(() {}); // 强制刷新UI

        // 显示成功消息
        final weekday = adjustedDate.weekday;
        bool isAdjusted = weekday != DateTime.monday;
        String message =
            '已设置第$semester学期开始日期：${adjustedDate.year}年${adjustedDate.month}月${adjustedDate.day}日';
        if (isAdjusted) {
          message += '（已自动调整为周一）';
        }
        _showMessage(message, isError: false);

        // 如果不是当前学期，询问是否立即切换
        if (semester != _currentSemester) {
          final shouldSwitch =
              await _dialogManager.showSwitchSemesterDialog(semester);
          if (shouldSwitch) {
            _handleSemesterChange(semester);
          }
        }
      } catch (e) {
        _showMessage('设置学期日期失败，请重试');
      }
    }
  }

  /// 处理课程更新
  Future<void> _handleCourseUpdate(Map<String, dynamic> updatedCourse) async {
    await _courseManager.updateCourse(courses, updatedCourse);
  }

  /// 处理周末显示切换
  void _handleWeekendToggle() {
    setState(() => _showWeekend = !_showWeekend);
  }

  /// 返回当前周
  Future<void> _handleGoBack() async {
    try {
      // 获取当前日期
      final now = DateTime.now();

      // 获取所有已设置的学期
      List<int> configuredSemesters = [];
      for (int i = 1; i <= 10; i++) {
        if (await CourseStorageHive.hasSemesterStartDate(i)) {
          configuredSemesters.add(i);
        }
      }

      if (configuredSemesters.isEmpty) {
        _showMessage('请先设置至少一个学期的开始日期', isError: true);
        return;
      }

      // 找到最适合当前日期的学期
      int bestSemester = configuredSemesters[0];
      int minDaysDifference = 10000; // 大数，作为初始比较值

      for (int semester in configuredSemesters) {
        DateTime? semesterDate =
            await CourseStorageHive.getSemesterStartDate(semester);
        if (semesterDate != null) {
          // 计算日期差值的绝对值
          int daysDifference = (now.difference(semesterDate).inDays).abs();
          if (daysDifference < minDaysDifference) {
            minDaysDifference = daysDifference;
            bestSemester = semester;
          }
        }
      }

      // 使用找到的最佳学期
      final currentSemester = bestSemester;

      // 计算当前学期的当前周次
      final currentWeek =
          await SemesterUtils.calculateCurrentWeek(currentSemester);

      // 更新状态
      setState(() {
        _currentSemester = currentSemester;
        _curWeek = currentWeek;
        _week = currentWeek;
        _isMenuOpen = false;
        _animationController.reverse();
      });

      // 保存当前学期设置
      await CourseStorageHive.saveSemester(currentSemester);

      // 切换到对应的页面
      if (_pageController.hasClients) {
        _pageController.jumpToPage(currentWeek - 1);
      }

      // 显示成功提示
      _showMessage('已返回当前日期：第$currentSemester学期第$currentWeek周', isError: false);
    } catch (e) {
      _showMessage('返回当前日期失败: ${e.toString()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeMenu,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: MainAppBar(
          formattedDate: WeekManager.getFormattedDate(),
          currentSemester: _currentSemester,
          currentWeek: _week,
          themeColor: _themeColor,
          onAddCourse: () => _onAddButtonPressed(context),
          onToggleWeekend: _handleWeekendToggle,
          onSemesterTap: _showSemesterPicker,
          showWeekend: _showWeekend,
        ),
        body: SlideTable(
          initialWeek: _week,
          currentSemester: _currentSemester,
          showWeekend: _showWeekend,
          showTimeSlots: _showTimeSlots,
          showGrid: _showGrid,
          themeColor: _themeColor,
          courses: courses,
          onCourseUpdated: _handleCourseUpdate,
          onCourseDeleted: (course) async {
            await _courseManager.deleteCourse(courses, course);
          },
          onWeekChange: (week) => setState(() => _week = week),
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
