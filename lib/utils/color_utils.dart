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
      if (colorData == null) {
        return defaultColor ?? Colors.teal;
      }

      // 检查是否为列表类型
      if (colorData is! List) {
        return defaultColor ?? Colors.teal;
      }

      // 检查列表长度
      if (colorData.length < 3) {
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
    if (color == Colors.red) return '红色';
    if (color == Colors.pink) return '粉色';
    if (color == Colors.purple) return '紫色';
    if (color == Colors.deepPurple) return '深紫色';
    if (color == Colors.indigo) return '靛蓝色';
    if (color == Colors.blue) return '蓝色';
    if (color == Colors.lightBlue) return '浅蓝色';
    if (color == Colors.cyan) return '青色';
    if (color == Colors.teal) return '蓝绿色';
    if (color == Colors.green) return '绿色';
    if (color == Colors.lightGreen) return '浅绿色';
    if (color == Colors.lime) return '酸橙色';
    if (color == Colors.yellow) return '黄色';
    if (color == Colors.amber) return '琥珀色';
    if (color == Colors.orange) return '橙色';
    if (color == Colors.deepOrange) return '深橙色';
    if (color == Colors.brown) return '棕色';
    if (color == Colors.grey) return '灰色';
    if (color == Colors.blueGrey) return '蓝灰色';
    return '自定义颜色';
  }
}

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
        Container(
          width: double.infinity,
          height: 60,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),

        // 主要颜色网格
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var color in ColorUtils.materialColors)
              GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = color);
                  widget.onColorChange(color);
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color
                          ? Colors.white
                          : Colors.transparent,
                      width: 3,
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
              ),
          ],
        ),

        // 常用主题色变种
        const SizedBox(height: 16),
        const Text('深浅变体', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_getColorFamily(_selectedColor).isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var color in _getColorFamily(_selectedColor))
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = color);
                    widget.onColorChange(color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// 获取颜色的色系变体
  List<Color> _getColorFamily(Color color) {
    // 匹配选中颜色的色系
    if (color == Colors.red) {
      return [Colors.red.shade300, Colors.red, Colors.red.shade700];
    } else if (color == Colors.pink) {
      return [Colors.pink.shade300, Colors.pink, Colors.pink.shade700];
    } else if (color == Colors.purple) {
      return [Colors.purple.shade300, Colors.purple, Colors.purple.shade700];
    } else if (color == Colors.deepPurple) {
      return [
        Colors.deepPurple.shade300,
        Colors.deepPurple,
        Colors.deepPurple.shade700
      ];
    } else if (color == Colors.indigo) {
      return [Colors.indigo.shade300, Colors.indigo, Colors.indigo.shade700];
    } else if (color == Colors.blue) {
      return [Colors.blue.shade300, Colors.blue, Colors.blue.shade700];
    } else if (color == Colors.lightBlue) {
      return [
        Colors.lightBlue.shade300,
        Colors.lightBlue,
        Colors.lightBlue.shade700
      ];
    } else if (color == Colors.cyan) {
      return [Colors.cyan.shade300, Colors.cyan, Colors.cyan.shade700];
    } else if (color == Colors.teal) {
      return [Colors.teal.shade300, Colors.teal, Colors.teal.shade700];
    } else if (color == Colors.green) {
      return [Colors.green.shade300, Colors.green, Colors.green.shade700];
    } else if (color == Colors.lightGreen) {
      return [
        Colors.lightGreen.shade300,
        Colors.lightGreen,
        Colors.lightGreen.shade700
      ];
    } else if (color == Colors.lime) {
      return [Colors.lime.shade300, Colors.lime, Colors.lime.shade700];
    } else if (color == Colors.yellow) {
      return [Colors.yellow.shade300, Colors.yellow, Colors.yellow.shade700];
    } else if (color == Colors.amber) {
      return [Colors.amber.shade300, Colors.amber, Colors.amber.shade700];
    } else if (color == Colors.orange) {
      return [Colors.orange.shade300, Colors.orange, Colors.orange.shade700];
    } else if (color == Colors.deepOrange) {
      return [
        Colors.deepOrange.shade300,
        Colors.deepOrange,
        Colors.deepOrange.shade700
      ];
    } else if (color == Colors.brown) {
      return [Colors.brown.shade300, Colors.brown, Colors.brown.shade700];
    } else if (color == Colors.blueGrey) {
      return [
        Colors.blueGrey.shade300,
        Colors.blueGrey,
        Colors.blueGrey.shade700
      ];
    }

    return [];
  }
}
