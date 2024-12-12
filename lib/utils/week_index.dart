// import 'package:path_provider/path_provider.dart'; // 用于获取应用程序目录
// import '../config.dart'; // 引入项目配置文件
// import 'dart:io'; // Dart 的 IO 库，用于文件操作

/// 该类维护当前是第几周
class WeekIndex {
  // static late int curWeek;
  static int curWeek = 1;

  /// 初始化周索引
  static Future<void> init() async {
    // 获取存储周索引的文件路径
    // final dir = (await getApplicationDocumentsDirectory()).path + we ekIndex;
    // File file = File(dir);
    // 如果文件不存在，创建文件并设置初始周索引为1
    // if (!(await file.exists())) {
    // await file.create();
    await _setWeekIndex(1);
    // }
    // 获取当前周索引并赋值给 curWeek
    // curWeek = await _getWeekIndex();
  }

  /// 更新当前周索引
  static Future<void> update(int week) async {
    await _setWeekIndex(week); // 设置新的周索引
    // curWeek = await _getWeekIndex(); // 更新 curWeek
  }

  /// 设置周数的锚点，锚点为第一周的周一零点
  static Future<void> _setWeekIndex(int week) async {
    assert(week >= 1); // 确保周数大于等于1
    week -= 1; // 计算当前周前的周数
    var date = DateTime.now();
    // 将当前日期向前移动指定周数
    date = date.subtract(Duration(days: week * 7));

    // 获取该周周一零点的时间
    date = date.subtract(Duration(
      days: date.weekday - 1, // 获取周一
      hours: date.hour, // 将小时归零
      minutes: date.minute, // 将分钟归零
      seconds: date.second, // 将秒归零
    ));

    // 获取存储周索引的文件路径
    // final dir = (await getApplicationDocumentsDirectory()).path + weekIndex;
    // File file = File(dir);
    // try {
    //   await file.writeAsString(date.toString()); // 将日期写入文件
    // } catch (e) {
    //   print(e); // 捕获并打印错误
    // }
  }

  // _getWeekIndex() {}
}
