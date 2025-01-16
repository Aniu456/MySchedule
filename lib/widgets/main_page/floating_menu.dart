import 'package:flutter/material.dart';

//浮动菜单组件
class FloatingMenu extends StatelessWidget {
  final bool isMenuOpen;
  final bool showGrid;
  final bool showTimeSlots;
  final Color themeColor;
  final Function() onMenuToggle;
  final Function() onGoBack;
  final Function() onGridToggle;
  final Function() onTimeSlotsToggle;
  final Function() onColorPick;
  final Function() onDelete;
  final AnimationController animationController;

  const FloatingMenu({
    super.key,
    required this.isMenuOpen,
    required this.showGrid,
    required this.showTimeSlots,
    required this.themeColor,
    required this.onMenuToggle,
    required this.onGoBack,
    required this.onGridToggle,
    required this.onTimeSlotsToggle,
    required this.onColorPick,
    required this.onDelete,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 返回按钮
        ScaleTransition(
          scale: animationController,
          child: Visibility(
            visible: isMenuOpen,
            child: FloatingActionButton(
              heroTag: 'goBack',
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: onGoBack,
              child: Icon(Icons.arrow_back, color: themeColor),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // 网格显示按钮
        ScaleTransition(
          scale: animationController,
          child: Visibility(
            visible: isMenuOpen,
            child: FloatingActionButton(
              heroTag: 'grid',
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: onGridToggle,
              child: Icon(
                showGrid ? Icons.grid_on : Icons.grid_off,
                color: themeColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // 时间显示按钮
        ScaleTransition(
          scale: animationController,
          child: Visibility(
            visible: isMenuOpen,
            child: FloatingActionButton(
              heroTag: 'time',
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: onTimeSlotsToggle,
              child: Icon(
                showTimeSlots ? Icons.access_time_filled : Icons.access_time,
                color: themeColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // 主题色选择按钮
        ScaleTransition(
          scale: animationController,
          child: Visibility(
            visible: isMenuOpen,
            child: FloatingActionButton(
              heroTag: 'theme',
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: onColorPick,
              child: Icon(Icons.palette, color: themeColor),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // 主菜单按钮
        FloatingActionButton(
          heroTag: 'menu',
          backgroundColor: themeColor,
          elevation: 4,
          onPressed: onMenuToggle,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: animationController,
            color: Colors.white,
          ),
        ),
        ScaleTransition(
          scale: animationController,
          child: Visibility(
            visible: isMenuOpen,
            child: FloatingActionButton(
              heroTag: 'delete',
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: onDelete,
              child: const Icon(Icons.delete, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
