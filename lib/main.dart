import 'package:flutter/material.dart';
import 'package:schedule/widgets/main_pages.dart';

void main() async {
  // 运行应用
  return runApp(const MyApp());
}

// 自定义的 MyApp 类，继承自 StatelessWidgete
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '课程表', // 应用的标题
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          // appBarTheme: const AppBarTheme(
          //   backgroundColor: Colors.white, // 设置全局标题栏的背景颜色
          // ),
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            width: double.infinity,
          )),
      home: const MainPage(), // 应用的主页
      // debugShowMaterialGrid: false, // 是否显示调试网格
      debugShowCheckedModeBanner: false,
    );
  }
}
