import 'package:flutter/material.dart';
import '../../utils/course_storage_hive.dart';
import '../../utils/color_utils.dart';

/// 周次选择器组件
/// 用于显示已选择的周次，以连续区间的形式展示
class WeekPickerWidget extends StatelessWidget {
  /// 已选择的周次列表
  final List<int> weeks;

  /// 当前主题颜色
  final Color currentColor;

  const WeekPickerWidget({
    super.key,
    required this.weeks,
    required this.currentColor,
  });

  /// 将周次列表转换为连续区间的字符串表示
  List<String> _getWeekRanges() {
    if (weeks.isEmpty) return [];

    List<String> weekRanges = [];
    weeks.sort();
    int start = weeks.first;
    int end = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        end = weeks[i];
      } else {
        weekRanges.add(start == end ? '第$start周' : '第$start-$end周');
        start = weeks[i];
        end = weeks[i];
      }
    }

    weekRanges.add(start == end ? '第$start周' : '第$start-$end周');
    return weekRanges;
  }

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) {
      return Center(
        child: Text(
          '点击选择上课周次',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _getWeekRanges().map((range) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: currentColor.toRGBO(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            range,
            style: TextStyle(
              color: currentColor,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 周次选择对话框
/// 用于选择上课周次，支持单选和滑动多选，并提供模板功能
class WeekPickerDialog extends StatefulWidget {
  /// 初始选中的周次列表
  final List<int> initialWeeks;

  /// 主题颜色
  final Color themeColor;

  /// 周次选择回调
  final ValueChanged<List<int>> onWeeksSelected;

  const WeekPickerDialog({
    super.key,
    required this.initialWeeks,
    required this.themeColor,
    required this.onWeeksSelected,
  });

  @override
  State<WeekPickerDialog> createState() => _WeekPickerDialogState();
}

class _WeekPickerDialogState extends State<WeekPickerDialog> {
  /// 当前选中的周次列表
  late List<int> selectedWeeks;

  /// 保存的周次模板列表
  List<List<int>> weekTemplates = [];

  /// 是否正在加载模板
  bool isLoadingTemplates = true;

  /// 滑动选择的起始周次
  int? dragStartWeek;

  /// 是否为选中操作（true为选中，false为取消选中）
  bool? isSelecting;

  @override
  void initState() {
    super.initState();
    selectedWeeks = List.from(widget.initialWeeks);
    _loadWeekTemplates();
  }

  /// 加载周次模板
  Future<void> _loadWeekTemplates() async {
    try {
      final templates = await CourseStorageHive.getWeekTemplates();
      setState(() {
        weekTemplates = templates;
        isLoadingTemplates = false;
      });
    } catch (e) {
      setState(() {
        isLoadingTemplates = false;
      });
    }
  }

  /// 保存当前选择为模板
  Future<void> _saveAsTemplate() async {
    if (selectedWeeks.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择周次再保存模板')),
      );
      return;
    }

    try {
      await CourseStorageHive.saveWeekTemplate(selectedWeeks);
      if (!mounted) return;
      _loadWeekTemplates(); // 重新加载模板

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模板保存成功')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: ${e.toString()}')),
      );
    }
  }

  /// 切换周次选择状态
  void _toggleWeek(int week) {
    setState(() {
      if (selectedWeeks.contains(week)) {
        selectedWeeks.remove(week);
      } else {
        selectedWeeks.add(week);
      }
      selectedWeeks.sort();
    });
  }

  /// 应用模板
  void _applyTemplate(List<int> template) {
    setState(() {
      selectedWeeks = List.from(template);
    });
  }

  /// 构建周次选择网格
  Widget _buildWeekGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        final week = index + 1;
        final isSelected = selectedWeeks.contains(week);
        return InkWell(
          onTap: () => _toggleWeek(week),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? widget.themeColor : Colors.transparent,
              border: Border.all(
                color: widget.themeColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$week',
                style: TextStyle(
                  color: isSelected ? Colors.white : widget.themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建模板部分
  Widget _buildTemplates() {
    if (isLoadingTemplates) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (weekTemplates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Text(
            '暂无保存的模板',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text('已保存模板:', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: weekTemplates.map((template) {
            // 将模板转换为更可读的形式
            final ranges = _convertToRanges(template);
            return ActionChip(
              backgroundColor: widget.themeColor.toRGBO(0.1),
              label: Text(
                ranges.join(', '),
                style: TextStyle(
                  color: widget.themeColor,
                  fontSize: 12,
                ),
              ),
              onPressed: () => _applyTemplate(template),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 将周次列表转换为简洁的字符串表示
  List<String> _convertToRanges(List<int> weeks) {
    if (weeks.isEmpty) return [];

    List<String> ranges = [];
    weeks.sort();
    int start = weeks.first;
    int end = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      if (weeks[i] == end + 1) {
        end = weeks[i];
      } else {
        ranges.add(start == end ? '$start' : '$start-$end');
        start = weeks[i];
        end = weeks[i];
      }
    }

    ranges.add(start == end ? '$start' : '$start-$end');
    return ranges;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择上课周次'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 选择周次网格
              _buildWeekGrid(),

              const SizedBox(height: 16),
              const Divider(),

              // 模板部分
              _buildTemplates(),
            ],
          ),
        ),
      ),
      actions: [
        // 保存模板按钮
        TextButton.icon(
          onPressed: _saveAsTemplate,
          icon: const Icon(Icons.save, size: 18),
          label: const Text('保存为模板'),
        ),

        const Spacer(),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            widget.onWeeksSelected(selectedWeeks);
            Navigator.pop(context);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
