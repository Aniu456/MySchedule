import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';

/// 对话框管理器
/// 负责处理应用中的各种对话框显示
class DialogManager {
  final BuildContext context;
  Color themeColor;

  DialogManager({
    required this.context,
    required this.themeColor,
  });

  /// 更新主题色
  void updateThemeColor(Color newColor) {
    themeColor = newColor;
  }

  /// 显示颜色选择器
  Future<Color?> showColorPicker() async {
    return ColorUtils.showColorPickerDialog(context, themeColor);
  }

  /// 显示删除确认对话框
  Future<bool> showDeleteConfirmation() async {
    bool confirmDelete = false;

    await showDialog(
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
                confirmDelete = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return confirmDelete;
  }

  /// 显示学期选择对话框
  Future<void> showSemesterPicker({
    required int currentSemester,
    required Future<List<Widget>> Function() buildSemesterList,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('学期设置',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '当前学期：第$currentSemester学期',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<Widget>>(
                  future: buildSemesterList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('加载学期数据失败'));
                    }

                    return ListView(
                      children: snapshot.data!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示建议学期对话框
  Future<bool> showRecommendSemesterDialog(int recommendedSemester) async {
    bool shouldSwitch = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(
            '根据当前日期（${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日），您应该处于第$recommendedSemester学期，是否切换？'),
        actions: [
          TextButton(
            child: const Text('保持当前'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('切换'),
            onPressed: () {
              shouldSwitch = true;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );

    return shouldSwitch;
  }

  /// 显示切换学期对话框
  Future<bool> showSwitchSemesterDialog(int semester) async {
    bool shouldSwitch = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('切换到第$semester学期？'),
          content: Text('您刚刚设置了第$semester学期，是否要立即切换到该学期？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                shouldSwitch = true;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    return shouldSwitch;
  }

  /// 显示日期选择器
  Future<DateTime?> showSemesterDatePicker(
      int semester, DateTime? initialDate) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
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
              primary: themeColor, // 使用主题色
              onPrimary: Colors.white, // 主题色上的文字颜色
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      // 将选择的日期调整为周一
      final weekday = selectedDate.weekday;
      DateTime adjustedDate;

      if (weekday != DateTime.monday) {
        // 如果不是周一，调整到本周一
        adjustedDate = selectedDate.subtract(Duration(days: weekday - 1));
        return adjustedDate;
      }

      return selectedDate;
    }

    return null;
  }

  /// 提示用户设置学期开始日期
  Future<bool> promptForSemesterSetup(int semester) async {
    bool shouldSetup = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('需要设置第$semester学期'),
          content: Text(
              '根据当前日期（${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日），您现在应该处于第$semester学期。\n\n请设置第$semester学期的开始日期，以便正确显示课程表。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('稍后设置'),
            ),
            ElevatedButton(
              onPressed: () {
                shouldSetup = true;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('现在设置'),
            ),
          ],
        );
      },
    );

    return shouldSetup;
  }
}
