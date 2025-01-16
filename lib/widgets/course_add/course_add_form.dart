import 'package:flutter/material.dart';

/// 课程基本信息表单组件
/// 用于输入课程名称、授课教师、备注等基本信息
class CourseAddForm extends StatelessWidget {
  /// 课程名称输入框焦点控制器
  final FocusNode courseFocusNode;

  /// 教师姓名输入框焦点控制器
  final FocusNode teacherFocusNode;

  /// 备注输入框焦点控制器
  final FocusNode remarksFocusNode;

  /// 当前选中的颜色
  final Color currentColor;

  /// 颜色选择回调
  final VoidCallback onColorPick;

  /// 课程名称保存回调
  final ValueChanged<String?> onCourseSaved;

  /// 教师姓名保存回调
  final ValueChanged<String?> onTeacherSaved;

  /// 备注保存回调
  final ValueChanged<String?> onRemarksSaved;

  const CourseAddForm({
    super.key,
    required this.courseFocusNode,
    required this.teacherFocusNode,
    required this.remarksFocusNode,
    required this.currentColor,
    required this.onColorPick,
    required this.onCourseSaved,
    required this.onTeacherSaved,
    required this.onRemarksSaved,
  });

  /// 构建输入框
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FocusNode focusNode,
    required ValueChanged<String?> onSaved,
    String? Function(String?)? validator,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool alignLabelWithHint = false,
  }) {
    return TextFormField(
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        alignLabelWithHint: alignLabelWithHint,
      ),
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      validator: validator,
      onSaved: onSaved,
    );
  }

  /// 构建颜色选择器按钮
  Widget _buildColorPicker() {
    return InkWell(
      onTap: onColorPick,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: currentColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.color_lens,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 课程名称输入框
        _buildTextField(
          label: '课程名称',
          icon: Icons.book,
          focusNode: courseFocusNode,
          onSaved: onCourseSaved,
          validator: (value) => value?.isEmpty ?? true ? '请输入课程名称' : null,
        ),
        const SizedBox(height: 16),
        // 教师姓名输入框和颜色选择器
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: '授课教师',
                icon: Icons.person,
                focusNode: teacherFocusNode,
                onSaved: onTeacherSaved,
                validator: (value) => value?.isEmpty ?? true ? '请输入授课教师' : null,
              ),
            ),
            const SizedBox(width: 16),
            _buildColorPicker(),
          ],
        ),
        const SizedBox(height: 16),
        // 备注输入框
        _buildTextField(
          label: '备注（选填，最多20字）',
          icon: Icons.note,
          focusNode: remarksFocusNode,
          onSaved: onRemarksSaved,
          maxLines: null,
          minLines: 1,
          maxLength: 20,
          alignLabelWithHint: true,
        ),
      ],
    );
  }
}
