import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      toolbarHeight: kToolbarHeight.h,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 15.5.sp,
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
          iconSize: 24.sp,
          padding: EdgeInsets.all(8.r),
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: onAddCourse,
        ),
        IconButton(
          iconSize: 24.sp,
          padding: EdgeInsets.all(8.r),
          icon: Icon(
            showWeekend ? Icons.weekend : Icons.weekend_outlined,
            color: Colors.white,
          ),
          onPressed: onToggleWeekend,
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildWeekDisplay(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onSemesterTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$currentSemester",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 6.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "第",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                currentWeek.toString(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                "周",
                style: TextStyle(
                  fontSize: 13.sp,
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
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);
}
