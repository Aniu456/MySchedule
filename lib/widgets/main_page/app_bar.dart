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

  /// 获取自适应字体大小
  double getAdaptiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSizeFactor = screenWidth / 375.0;
    final size = baseSize * fontSizeFactor;
    return size.clamp(baseSize * 0.8, baseSize * 1.4);
  }

  @override
  Widget build(BuildContext context) {
    final adaptiveHeight = kToolbarHeight *
        (MediaQuery.of(context).size.width / 375.0).clamp(1.0, 1.3);

    return AppBar(
      elevation: 0,
      backgroundColor: themeColor,
      toolbarHeight: adaptiveHeight,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: getAdaptiveFontSize(context, 15.5),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildWeekDisplay(context),
        ],
      ),
      actions: <Widget>[
        IconButton(
          iconSize: getAdaptiveFontSize(context, 24),
          padding: EdgeInsets.all(getAdaptiveFontSize(context, 8)),
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: onAddCourse,
        ),
        IconButton(
          iconSize: getAdaptiveFontSize(context, 24),
          padding: EdgeInsets.all(getAdaptiveFontSize(context, 8)),
          icon: Icon(
            showWeekend ? Icons.weekend : Icons.weekend_outlined,
            color: Colors.white,
          ),
          onPressed: onToggleWeekend,
        ),
        SizedBox(width: getAdaptiveFontSize(context, 8)),
      ],
    );
  }

  Widget _buildWeekDisplay(BuildContext context) {
    final containerPadding = EdgeInsets.symmetric(
      horizontal: getAdaptiveFontSize(context, 6),
      vertical: getAdaptiveFontSize(context, 4),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onSemesterTap,
          child: Container(
            padding: containerPadding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius:
                  BorderRadius.circular(getAdaptiveFontSize(context, 16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$currentSemester",
                  style: TextStyle(
                    fontSize: getAdaptiveFontSize(context, 14),
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: getAdaptiveFontSize(context, 16),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: getAdaptiveFontSize(context, 4)),
        Container(
          padding: containerPadding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius:
                BorderRadius.circular(getAdaptiveFontSize(context, 16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "第",
                style: TextStyle(
                  fontSize: getAdaptiveFontSize(context, 13),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: getAdaptiveFontSize(context, 4)),
              Text(
                currentWeek.toString(),
                style: TextStyle(
                  fontSize: getAdaptiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: getAdaptiveFontSize(context, 4)),
              Text(
                "周",
                style: TextStyle(
                  fontSize: getAdaptiveFontSize(context, 13),
                  color: Colors.white,
                ),
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
