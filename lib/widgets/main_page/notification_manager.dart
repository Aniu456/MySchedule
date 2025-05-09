import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';

/// 通知管理器
/// 负责处理消息提示和通知显示
class NotificationManager {
  final BuildContext context;
  Color themeColor;

  NotificationManager({
    required this.context,
    required this.themeColor,
  });

  /// 更新主题色
  void updateThemeColor(Color newColor) {
    themeColor = newColor;
  }

  /// 显示消息提示
  void showMessage(String message, {bool isError = true}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    // 使用安全的颜色
    final safeColor = ColorUtils.getSafeSnackBarColor(themeColor);

    // 确保在Widget构建之后显示SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        messenger.showSnackBar(
          SnackBar(
            content: Text(message, textAlign: TextAlign.center),
            backgroundColor: safeColor,
            behavior: SnackBarBehavior.floating,
            duration: Duration(milliseconds: isError ? 2000 : 1500),
            // 使用合适的边距避免溢出
            margin: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: isError ? '知道了' : '好的',
              textColor: Colors.white,
              onPressed: () => messenger.hideCurrentSnackBar(),
            ),
          ),
        );
      } catch (e) {
        // 忽略SnackBar错误
      }
    });
  }
}
