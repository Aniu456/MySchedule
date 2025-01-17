import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/main_pages.dart';

/// 应用程序入口
void main() {
  runApp(const MyApp());
}

/// 应用程序根组件
/// 配置应用的主题和全局设置
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // 设计稿的尺寸
      designSize: const Size(375, 812), // iPhone X 的设计尺寸
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
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
      },
    );
  }
}
