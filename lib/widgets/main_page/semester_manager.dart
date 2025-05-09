import 'package:flutter/material.dart';
import '../../utils/course_storage_hive.dart';
import '../../utils/semester_utils.dart';
import 'week_manager.dart';

/// 学期管理器
/// 负责处理学期相关的所有功能
class SemesterManager {
  final Function(String, {bool isError}) showMessage;
  final Function(void Function()) setState;
  final BuildContext context;
  final Color themeColor;

  SemesterManager({
    required this.showMessage,
    required this.setState,
    required this.context,
    required this.themeColor,
  });

  /// 处理学期变更
  Future<void> handleSemesterChange(
    int semester, {
    required int currentSemester,
    required Function(int, int, int) onSemesterChanged,
    required Function() onCoursesNeedReload,
    required Function() onPageControllerReset,
  }) async {
    try {
      if (semester < 1 || semester > 10) {
        showMessage('学期编号无效，请选择1-10范围内的学期', isError: true);
        return;
      }

      // 检查学期是否已设置开始日期
      bool hasSemesterDate =
          await CourseStorageHive.hasSemesterStartDate(semester);
      if (!hasSemesterDate) {
        showMessage('请先设置第$semester学期的开始日期', isError: true);
        return;
      }

      // 先保存学期设置到持久化存储
      await CourseStorageHive.saveSemester(semester);

      // 计算当前周次
      int newCurWeek = await WeekManager.calculateCurrentWeek(semester);

      // 立即更新状态
      onSemesterChanged(semester, newCurWeek, newCurWeek);

      // 通知需要重置页面控制器
      onPageControllerReset();

      // 重新加载课程数据
      onCoursesNeedReload();

      // 显示切换成功提示
      showMessage('已切换到第$semester学期第$newCurWeek周', isError: false);
    } catch (e) {
      showMessage('切换学期失败: ${e.toString()}', isError: true);
    }
  }

  /// 加载学期数据
  Future<int> loadSemester() async {
    try {
      // 从存储中获取上次保存的学期设置
      int savedSemester = await CourseStorageHive.getSemester();

      // 检查保存的学期是否已设置开始日期
      bool hasSemesterDate =
          await CourseStorageHive.hasSemesterStartDate(savedSemester);
      if (!hasSemesterDate) {
        // 如果保存的学期未设置日期，尝试找到第一个已设置日期的学期
        for (int i = 1; i <= 10; i++) {
          if (await CourseStorageHive.hasSemesterStartDate(i)) {
            savedSemester = i;
            break;
          }
        }
      }

      // 保存确定的学期
      await CourseStorageHive.saveSemester(savedSemester);

      return savedSemester;
    } catch (e) {
      return 1; // 出错时返回默认学期1
    }
  }

  /// 获取星期几的中文名称
  String getWeekdayName(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[weekday - 1];
  }

  /// 检查是否需要推荐切换学期
  Future<int?> checkAndRecommendSemester(int currentSemester) async {
    // 不再自动推荐学期，用户可以根据需要自行添加和切换学期
    return null;
  }

  /// 构建学期列表项
  Future<List<Widget>> buildSemesterList(int currentSemester) async {
    List<Widget> semesterItems = [];

    // 先获取所有已设置的学期
    List<int> configuredSemesters = [];
    for (int semester = 1; semester <= 10; semester++) {
      if (await CourseStorageHive.hasSemesterStartDate(semester)) {
        configuredSemesters.add(semester);
      }
    }

    if (configuredSemesters.isEmpty) {
      // 如果没有已设置的学期，显示提示
      return [
        const ListTile(
          title: Text('请先设置至少一个学期', style: TextStyle(color: Colors.red)),
          subtitle: Text('点击下方的"添加学期"按钮来添加新学期'),
        )
      ];
    }

    // 构建已设置的学期选项
    for (int semester in configuredSemesters) {
      // 获取学期开始日期
      DateTime? semesterDate =
          await CourseStorageHive.getSemesterStartDate(semester);

      final isSelected = currentSemester == semester;
      final bgColor = isSelected ? themeColor.withOpacity(0.15) : Colors.white;
      final borderColor = isSelected ? themeColor : Colors.grey.shade300;
      final borderWidth = isSelected ? 2.0 : 1.0;

      // 创建基本Container，回调将在外部设置
      semesterItems.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isSelected ? themeColor : Colors.grey.shade200,
              foregroundColor: isSelected ? Colors.white : Colors.black54,
              child: Text('$semester'),
            ),
            title: Text(
              '第$semester学期',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? themeColor : Colors.black,
              ),
            ),
            subtitle: semesterDate != null
                ? Text(
                    '开始日期: ${semesterDate.year}年${semesterDate.month}月${semesterDate.day}日 (周${getWeekdayName(semesterDate.weekday)})',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  )
                : const Text('未设置开始日期'),
            // 不在这里设置trailing和onTap，这将在主页面设置
            selected: isSelected,
          ),
        ),
      );
    }

    // 添加"添加学期"按钮
    // 找出下一个可添加的学期编号
    int nextSemesterToAdd = 1;
    while (configuredSemesters.contains(nextSemesterToAdd) &&
        nextSemesterToAdd <= 10) {
      nextSemesterToAdd++;
    }

    if (nextSemesterToAdd <= 10) {
      semesterItems.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: null, // 回调将在外部设置
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add),
                const SizedBox(width: 8),
                const Text('添加学期'),
                // 隐藏的数据，用于在外部获取要添加的学期编号
                Opacity(
                  opacity: 0,
                  child: Text('semester:$nextSemesterToAdd'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 添加提示文本
    semesterItems.add(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '提示：',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '1. 每学期开始日期必须是周一',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
            Text(
              '2. 点击日历图标可以修改学期开始日期',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
            Text(
              '3. 点击学期项可以切换到该学期',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ),
      ),
    );

    return semesterItems;
  }

  /// 设置新学期的开始日期
  Future<bool> setupNewSemesterDate(int semester, DateTime selectedDate) async {
    try {
      // 验证学期日期的有效性
      bool isValid = await validateSemesterDate(semester, selectedDate);
      if (!isValid) {
        return false;
      }

      // 将选择的日期调整为周一
      DateTime adjustedDate;
      final weekday = selectedDate.weekday;

      if (weekday != DateTime.monday) {
        // 如果不是周一，调整到下一个周一
        adjustedDate = selectedDate.add(Duration(days: (8 - weekday) % 7));
        if (adjustedDate.weekday != DateTime.monday) {
          // 确保是周一
          adjustedDate =
              adjustedDate.subtract(Duration(days: adjustedDate.weekday - 1));
        }
      } else {
        adjustedDate = selectedDate;
      }

      // 保存学期开始日期
      await SemesterUtils.setSemesterStartDate(semester, adjustedDate);

      showMessage(
          '已设置第$semester学期开始日期：${adjustedDate.year}年${adjustedDate.month}月${adjustedDate.day}日',
          isError: false);
      return true;
    } catch (e) {
      showMessage('设置学期日期失败: ${e.toString()}', isError: true);
      return false;
    }
  }

  /// 验证学期日期是否有效
  Future<bool> validateSemesterDate(int semester, DateTime selectedDate) async {
    // 如果是第一学期，只需要确保日期是在合理范围内（2020-2030年）
    if (semester == 1) return true;

    // 对于非第一学期，需要检查与前面学期的关系

    // 首先获取第一学期的日期
    DateTime? firstSemesterDate =
        await CourseStorageHive.getSemesterStartDate(1);
    if (firstSemesterDate == null) {
      showMessage('请先设置第一学期的开始日期', isError: true);
      return false;
    }

    // 检查是否晚于第一学期
    if (selectedDate.isBefore(firstSemesterDate)) {
      showMessage(
          '第$semester学期的开始日期不能早于第1学期（${firstSemesterDate.year}年${firstSemesterDate.month}月${firstSemesterDate.day}日）',
          isError: true);
      return false;
    }

    // 获取前一个学期的日期（如果已设置）
    int prevSemester = semester - 1;
    while (prevSemester >= 1) {
      DateTime? prevSemesterDate =
          await CourseStorageHive.getSemesterStartDate(prevSemester);
      if (prevSemesterDate != null) {
        // 检查是否晚于前一个学期
        if (selectedDate.isBefore(prevSemesterDate)) {
          showMessage(
              '第$semester学期的开始日期不能早于第$prevSemester学期（${prevSemesterDate.year}年${prevSemesterDate.month}月${prevSemesterDate.day}日）',
              isError: true);
          return false;
        }
        break; // 找到最近的前一个学期后退出循环
      }
      prevSemester--;
    }

    // 获取后一个学期的日期（如果已设置）
    int nextSemester = semester + 1;
    while (nextSemester <= 10) {
      DateTime? nextSemesterDate =
          await CourseStorageHive.getSemesterStartDate(nextSemester);
      if (nextSemesterDate != null) {
        // 检查是否早于后一个学期
        if (selectedDate.isAfter(nextSemesterDate)) {
          showMessage(
              '第$semester学期的开始日期不能晚于第$nextSemester学期（${nextSemesterDate.year}年${nextSemesterDate.month}月${nextSemesterDate.day}日）',
              isError: true);
          return false;
        }
        break; // 找到最近的后一个学期后退出循环
      }
      nextSemester++;
    }

    return true;
  }
}
