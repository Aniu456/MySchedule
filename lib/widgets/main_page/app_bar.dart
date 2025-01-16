import 'package:flutter/material.dart';

//顶部栏组件
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String formattedDate;
  final int currentSemester;
  final int currentWeek;
  final Color themeColor;
  final Function() onAddCourse;
  final Function() onToggleWeekend;
  final Function() onSemesterTap;
  final bool showWeekend;

  const MainAppBar({
    super.key,
    required this.formattedDate,
    required this.currentSemester,
    required this.currentWeek,
    required this.themeColor,
    required this.onAddCourse,
    required this.onToggleWeekend,
    required this.onSemesterTap,
    required this.showWeekend,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: themeColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              formattedDate,
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
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: onAddCourse,
        ),
        IconButton(
          icon: Icon(
            showWeekend ? Icons.weekend : Icons.weekend_outlined,
            color: Colors.white,
          ),
          onPressed: onToggleWeekend,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWeekDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onSemesterTap,
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
                currentWeek.toString(),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
