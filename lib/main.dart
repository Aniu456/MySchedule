import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/main_pages.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'utils/course_storage_hive.dart';
import 'widgets/first_semester_setup.dart'; // 新增的组件用于引导设置第一学期

/// 应用程序入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Hive
  await Hive.initFlutter();
  await Hive.openBox('appSettings');
  await Hive.openBox('courses'); // 打开课程盒子

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
          // 添加中文本地化支持
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'), // 中文简体
            Locale('en', 'US'), // 英文
          ],
          locale: const Locale('zh', 'CN'), // 默认使用中文
          home: FutureBuilder<bool>(
            future: _checkFirstSemesterSetup(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final bool needsSetup = snapshot.data ?? true;
              if (needsSetup) {
                // 需要设置第一学期
                return const FirstSemesterSetup();
              } else {
                // 已经设置过，直接进入主页
                return const MainPage();
              }
            },
          ),
          // debugShowMaterialGrid: false, // 是否显示调试网格
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  /// 检查是否已设置第一学期
  Future<bool> _checkFirstSemesterSetup() async {
    return !(await CourseStorageHive.hasSemesterStartDate(1));
  }
}
