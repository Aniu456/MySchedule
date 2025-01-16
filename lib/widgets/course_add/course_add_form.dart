import 'package:flutter/material.dart';

//课程基本信息表单
class CourseAddForm extends StatelessWidget {
  final FocusNode courseFocusNode;
  final FocusNode teacherFocusNode;
  final FocusNode remarksFocusNode;
  final Color currentColor;
  final Function() onColorPick;
  final Function(String?) onCourseSaved;
  final Function(String?) onTeacherSaved;
  final Function(String?) onRemarksSaved;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          focusNode: courseFocusNode,
          decoration: const InputDecoration(
            labelText: '课程名称',
            prefixIcon: Icon(Icons.book),
          ),
          validator: (value) => value?.isEmpty ?? true ? '请输入课程名称' : null,
          onSaved: onCourseSaved,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                focusNode: teacherFocusNode,
                decoration: const InputDecoration(
                  labelText: '授课教师',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty ?? true ? '请输入授课教师' : null,
                onSaved: onTeacherSaved,
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
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
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          focusNode: remarksFocusNode,
          decoration: const InputDecoration(
            labelText: '备注（选填，最多20字）',
            prefixIcon: Icon(Icons.note),
            alignLabelWithHint: true,
          ),
          maxLines: null,
          minLines: 1,
          maxLength: 20,
          onSaved: onRemarksSaved,
        ),
      ],
    );
  }
}
