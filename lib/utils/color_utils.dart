import 'package:flutter/material.dart';

/// 颜色工具类
/// 用于统一处理颜色相关的功能，确保应用中颜色处理一致
class ColorUtils {
  /// 将Flutter Color对象转换为存储格式（整数列表）
  /// 存储格式为: [r, g, b]，其中r、g、b为0-255的整数
  static List<int> colorToStorage(Color color) {
    return [
      (color.r * 255).round(),
      (color.g * 255).round(),
      (color.b * 255).round()
    ];
  }

  /// 将存储格式转换为Flutter Color对象
  /// 存储格式为: [r, g, b]，其中r、g、b为0-255的整数
  static Color storageToColor(dynamic colorData, {Color? defaultColor}) {
    try {
      if (colorData == null || colorData is! List || colorData.length < 3) {
        return defaultColor ?? Colors.teal;
      }

      // 确保颜色值在有效范围内 (0-255)
      int r = _validateColorValue(colorData[0]);
      int g = _validateColorValue(colorData[1]);
      int b = _validateColorValue(colorData[2]);

      return Color.fromRGBO(r, g, b, 1.0);
    } catch (e) {
      // 任何异常情况都返回默认颜色
      return defaultColor ?? Colors.teal;
    }
  }

  /// 验证颜色值是否在0-255范围内
  static int _validateColorValue(dynamic value) {
    int intValue = 0;

    if (value is int) {
      intValue = value;
    } else if (value is double) {
      intValue = value.toInt();
    } else if (value is String) {
      intValue = int.tryParse(value) ?? 0;
    }

    // 确保在0-255范围内
    return intValue.clamp(0, 255);
  }

  /// 预定义的颜色数组，提供美观的颜色选择
  static const List<Color> materialColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
  ];

  /// 显示颜色选择器对话框
  /// 返回用户选择的颜色，如果用户取消则返回null
  static Future<Color?> showColorPickerDialog(
      BuildContext context, Color initialColor) async {
    Color pickedColor = initialColor;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择颜色'),
          content: SingleChildScrollView(
            child: MaterialColorPicker(
              selectedColor: initialColor,
              onColorChange: (color) {
                pickedColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop(pickedColor);
              },
            ),
          ],
        );
      },
    );

    // 如果颜色没有变化，返回null
    if (pickedColor == initialColor) {
      return null;
    }

    return pickedColor;
  }

  /// 获取安全的通知栏颜色
  /// 确保不会使用黑色作为通知栏背景色
  static Color getSafeSnackBarColor(Color color, {Color? fallbackColor}) {
    // 检查颜色是否太深
    if (_calculateLuminance(color) < 0.3) {
      return fallbackColor ?? Colors.teal;
    }
    return color;
  }

  /// 计算颜色的亮度，用于判断颜色是否太深
  static double _calculateLuminance(Color color) {
    return (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;
  }

  /// 获取颜色的中文名称（用于调试或用户界面）
  static String getColorName(Color color) {
    final colorNameMap = {
      Colors.red: '红色',
      Colors.pink: '粉色',
      Colors.purple: '紫色',
      Colors.deepPurple: '深紫色',
      Colors.indigo: '靛蓝色',
      Colors.blue: '蓝色',
      Colors.lightBlue: '浅蓝色',
      Colors.cyan: '青色',
      Colors.teal: '蓝绿色',
      Colors.green: '绿色',
      Colors.lightGreen: '浅绿色',
      Colors.lime: '酸橙色',
      Colors.yellow: '黄色',
      Colors.amber: '琥珀色',
      Colors.orange: '橙色',
      Colors.deepOrange: '深橙色',
      Colors.brown: '棕色',
      Colors.grey: '灰色',
      Colors.blueGrey: '蓝灰色',
    };

    return colorNameMap[color] ?? '自定义颜色';
  }
}

/// 颜色相关的扩展方法
extension ColorExt on Color {
  /// 转换为RGBO格式时使用的便捷方法
  Color toRGBO(double opacity) {
    return Color.fromRGBO(
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
      opacity,
    );
  }

  /// 获取适合此背景色的前景色（黑或白）
  Color contrastColor() {
    return ColorUtils._calculateLuminance(this) > 0.5
        ? Colors.black
        : Colors.white;
  }

  /// 获取此颜色的深浅变体列表
  List<Color> getVariants() {
    // 查找预定义的颜色变体
    for (final baseColor in _colorFamilyMap.keys) {
      if (this == baseColor) {
        return _colorFamilyMap[baseColor]!;
      }
    }
    // 如果没有预定义，返回空列表
    return [];
  }
}

// 颜色家族映射
final Map<Color, List<Color>> _colorFamilyMap = {
  Colors.red: [Colors.red.shade300, Colors.red, Colors.red.shade700],
  Colors.pink: [Colors.pink.shade300, Colors.pink, Colors.pink.shade700],
  Colors.purple: [
    Colors.purple.shade300,
    Colors.purple,
    Colors.purple.shade700
  ],
  Colors.deepPurple: [
    Colors.deepPurple.shade300,
    Colors.deepPurple,
    Colors.deepPurple.shade700
  ],
  Colors.indigo: [
    Colors.indigo.shade300,
    Colors.indigo,
    Colors.indigo.shade700
  ],
  Colors.blue: [Colors.blue.shade300, Colors.blue, Colors.blue.shade700],
  Colors.lightBlue: [
    Colors.lightBlue.shade300,
    Colors.lightBlue,
    Colors.lightBlue.shade700
  ],
  Colors.cyan: [Colors.cyan.shade300, Colors.cyan, Colors.cyan.shade700],
  Colors.teal: [Colors.teal.shade300, Colors.teal, Colors.teal.shade700],
  Colors.green: [Colors.green.shade300, Colors.green, Colors.green.shade700],
  Colors.lightGreen: [
    Colors.lightGreen.shade300,
    Colors.lightGreen,
    Colors.lightGreen.shade700
  ],
  Colors.lime: [Colors.lime.shade300, Colors.lime, Colors.lime.shade700],
  Colors.yellow: [
    Colors.yellow.shade300,
    Colors.yellow,
    Colors.yellow.shade700
  ],
  Colors.amber: [Colors.amber.shade300, Colors.amber, Colors.amber.shade700],
  Colors.orange: [
    Colors.orange.shade300,
    Colors.orange,
    Colors.orange.shade700
  ],
  Colors.deepOrange: [
    Colors.deepOrange.shade300,
    Colors.deepOrange,
    Colors.deepOrange.shade700
  ],
  Colors.brown: [Colors.brown.shade300, Colors.brown, Colors.brown.shade700],
  Colors.blueGrey: [
    Colors.blueGrey.shade300,
    Colors.blueGrey,
    Colors.blueGrey.shade700
  ],
};

/// 自定义Material风格颜色选择器
class MaterialColorPicker extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChange;

  const MaterialColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChange,
  });

  @override
  State<MaterialColorPicker> createState() => _MaterialColorPickerState();
}

class _MaterialColorPickerState extends State<MaterialColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 显示选中的颜色
        _ColorPreview(color: _selectedColor),

        // 主要颜色网格
        _ColorGrid(
          colors: ColorUtils.materialColors,
          selectedColor: _selectedColor,
          onColorSelected: _handleColorSelected,
        ),

        // 常用主题色变种
        _ColorVariants(
          color: _selectedColor,
          selectedColor: _selectedColor,
          onColorSelected: _handleColorSelected,
        ),
      ],
    );
  }

  void _handleColorSelected(Color color) {
    setState(() => _selectedColor = color);
    widget.onColorChange(color);
  }
}

/// 颜色预览组件
class _ColorPreview extends StatelessWidget {
  final Color color;

  const _ColorPreview({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// 颜色网格组件
class _ColorGrid extends StatelessWidget {
  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorGrid({
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var color in colors)
          _ColorItem(
            color: color,
            isSelected: selectedColor == color,
            onTap: () => onColorSelected(color),
            size: 45,
          ),
      ],
    );
  }
}

/// 颜色变体组件
class _ColorVariants extends StatelessWidget {
  final Color color;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorVariants({
    required this.color,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final variants = color.getVariants();
    if (variants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('深浅变体', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var variantColor in variants)
              _ColorItem(
                color: variantColor,
                isSelected: selectedColor == variantColor,
                onTap: () => onColorSelected(variantColor),
                size: 40,
                borderWidth: 2,
              ),
          ],
        ),
      ],
    );
  }
}

/// 颜色项组件
class _ColorItem extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;
  final double borderWidth;

  const _ColorItem({
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.size,
    this.borderWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
