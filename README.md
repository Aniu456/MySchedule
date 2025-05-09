# 我的课程表 app

欢迎访问https://gitee.com/a-niutongzhi

# 运行如下

(图片若有 bug，已修复) ![k1](https://github.com/user-attachments/assets/5964e283-0de2-49ff-8cdf-b4ca62cc0077) ![k2](https://github.com/user-attachments/assets/674c4fdd-c24a-4b32-9e4d-e006cbcb1098) ![k3](https://github.com/user-attachments/assets/37dee72d-5cf7-4ad4-9925-63bc8bdc31fe) ![k4](https://github.com/user-attachments/assets/61a34d8f-e1a6-40fb-ab37-0ff090b3f89f) ![k5](https://github.com/user-attachments/assets/862b0ce3-d9ee-4de9-9cfd-dc9b2d05a1ae)

# 关于 Hive 本地存储

项目使用 Hive 作为本地数据存储解决方案。

## 为什么选择 Hive？

1. **高性能**

   - Hive 在写入和删除操作上比其他存储方案快得多
   - 在写入操作上，Hive 速度可达到 SharedPreferences 的 4 倍

2. **支持丰富的数据类型**

   - 支持：`bool`, `int`, `double`, `String`, `DateTime`, `Uint8List`以及任何基本类型的`List`和`Map`

3. **加密功能**

   - 内置支持 AES-256 加密，可以保护敏感数据

4. **更好的类型安全**
   - 提供更强的类型检查，减少运行时错误

## 项目中的 Hive 使用示例

本项目中的 Hive 实现位于 `lib/utils/course_storage_hive.dart`，主要功能包括：

```dart
// 保存课程
static Future<void> saveCourses(List<Map<String, dynamic>> courses) async {
  final box = await _getBox();
  await box.put(_coursesKey, courses);
}

// 获取课程
static Future<List<Map>> getCourses() async {
  final box = await _getBox();
  final dynamic coursesData = box.get(_coursesKey);
  if (coursesData == null) return [];

  return List<Map>.from(coursesData);
}
```

## Hive 初始化

项目在 `main.dart` 中初始化 Hive：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('courses');
  runApp(const MyApp());
}
```

## 从 SharedPreferences 迁移到 Hive 的指南

## 为什么选择 Hive 代替 SharedPreferences？

1. **性能提升**

   - Hive 在读取操作上性能相似，但在写入和删除操作上比 SharedPreferences 快得多
   - 在写入操作上，Hive 大约比 SharedPreferences 快 4 倍

2. **支持更多数据类型**

   - SharedPreferences 仅支持基本类型：`bool`, `int`, `double`, `String`, `List<String>`
   - Hive 额外支持：`DateTime`, `Uint8List`以及任何基本类型的`List`和`Map`

3. **加密支持**

   - Hive 内置支持 AES-256 加密，可以保护敏感数据
   - SharedPreferences 不支持加密

4. **更好的类型安全**

   - Hive 提供更强的类型检查，减少运行时错误

5. **代码整合**
   - 如果你的项目已经使用 Hive 存储其他数据，可以减少依赖，统一数据存储方案

## 如何迁移

本项目示范了如何将 SharedPreferences 数据平滑迁移到 Hive：

1. 添加必要的依赖

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1 # 如果需要使用TypeAdapter
  build_runner: ^2.4.8 # 如果需要使用TypeAdapter
```

2. 初始化 Hive

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('yourBoxName');
  // 其他初始化...
}
```

3. 创建 Hive 存储类

```dart
class YourStorageHive {
  static const String _boxName = 'yourBoxName';

  // 获取Box
  static Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  // 存储数据
  static Future<void> saveData(String key, dynamic value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  // 读取数据
  static Future<dynamic> getData(String key, {dynamic defaultValue}) async {
    final box = await _getBox();
    return box.get(key, defaultValue: defaultValue);
  }
}
```

4. 迁移数据

```dart
class MigrationHelper {
  static Future<bool> migrateData() async {
    try {
      // 从SharedPreferences获取数据
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('yourKey');

      // 保存到Hive
      final box = await Hive.openBox('yourBoxName');
      await box.put('yourKey', data);

      return true;
    } catch (e) {
      print('Migration error: $e');
      return false;
    }
  }
}
```

## 注意事项

- 确保在迁移前备份重要数据
- 考虑添加回滚机制
- 在迁移完成后，可以考虑移除 SharedPreferences 依赖

## 参考资料

- [Hive 官方文档](https://pub.dev/packages/hive)
- [Hive Flutter 官方文档](https://pub.dev/packages/hive_flutter)
