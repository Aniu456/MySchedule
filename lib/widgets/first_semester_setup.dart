import 'package:flutter/material.dart';
import '../utils/semester_utils.dart';
import 'main_pages.dart';

/// 第一学期设置引导页面
class FirstSemesterSetup extends StatefulWidget {
  const FirstSemesterSetup({super.key});

  @override
  State<FirstSemesterSetup> createState() => _FirstSemesterSetupState();
}

class _FirstSemesterSetupState extends State<FirstSemesterSetup> {
  DateTime? _selectedDate;
  bool _isAdjusted = false;
  final int semester = 1; // 第一学期

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('设置第一学期'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 50,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '欢迎使用课程表',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '为了更好地为您服务，请设置第一学期的开始日期。\n课程表将根据此日期自动计算周次。',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      _buildDateDisplay(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showDatePicker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('选择日期'),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedDate != null)
                        ElevatedButton(
                          onPressed: _saveDateAndContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('确认并继续'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建日期显示部分
  Widget _buildDateDisplay() {
    if (_selectedDate == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '请选择当前学期开始日期',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    // 显示选择的日期
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.teal.shade50,
      ),
      child: Column(
        children: [
          Text(
            '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日 (周${_weekdayToChineseString(_selectedDate!.weekday)})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          if (_isAdjusted)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                '已调整为周一日期',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 将星期几转换为中文字符串
  String _weekdayToChineseString(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[weekday - 1];
  }

  /// 显示日期选择器
  void _showDatePicker() async {
    final DateTime now = DateTime.now();
    final initialDate = _selectedDate ?? now;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: '选择当前学期开始日期',
      confirmText: '确认',
      cancelText: '取消',
      locale: const Locale('zh'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // 将选择的日期调整为周一
      bool isAdjusted = picked.weekday != DateTime.monday;
      final adjustedDate = isAdjusted
          ? picked.subtract(Duration(days: picked.weekday - 1))
          : picked;

      setState(() {
        _selectedDate = adjustedDate;
        _isAdjusted = isAdjusted;
      });
    }
  }

  /// 保存日期并继续
  void _saveDateAndContinue() async {
    if (_selectedDate == null) return;

    // 保存第一学期的开始日期
    await SemesterUtils.setSemesterStartDate(semester, _selectedDate!);

    if (!mounted) return;

    // 导航到主页
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }
}
