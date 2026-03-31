# MeetLog (遇记) Flutter 项目开发计划

## 项目概述
- **应用名称**: MeetLog (遇记)
- **平台**: iOS/Android (纯移动端)
- **核心特性**: 无后端、纯本地 Isar 数据库、支持 JSON 备份导入导出
- **技术栈**: Flutter + Isar + Riverpod + go_router + Material 3

---

## ✅ 阶段一：项目初始化与基础架构（已完成）

### 1.1 创建 Flutter 项目
- 执行 `flutter create meetlog`
- 配置项目结构（lib/models, lib/services, lib/screens, lib/providers, lib/routes）

### 1.2 配置 pubspec.yaml 依赖
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 数据库
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  
  # 状态管理
  flutter_riverpod: ^2.4.9
  
  # 路由
  go_router: ^13.0.0
  
  # 文件操作
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  
  # 序列化
  json_annotation: ^4.8.1
  
  # UI组件
  fl_chart: ^0.66.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # 代码生成
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

### 1.3 配置平台权限

**iOS (ios/Runner/Info.plist)**:
```xml
<key>NSDocumentsFolderUsageDescription</key>
<string>需要访问文档目录以保存备份数据</string>
```

**Android (android/app/src/main/AndroidManifest.xml)**:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### 1.4 配置 Material 3 主题
在 `MaterialApp` 中启用 Material 3:
```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
  ),
);
```

---

## ✅  阶段二：数据模型设计

### 2.1 ApproachRecord 数据模型
**字段定义**:
- `id` (int?) - Isar 自增主键，使用 `@Id()` 注解
- `dateTime` (DateTime) - 搭讪时间
- `location` (String) - 地点
- `isSuccess` (bool) - 是否成功
- `failReason` (String?) - 失败原因
- `reflection` (String?) - 复盘文本

**序列化方式**:
- 使用 `json_serializable` 自动生成 `fromJson` 和 `toJson` 方法
- 通过 `@JsonSerializable()` 注解配置序列化规则

### 2.2 Contact 数据模型
**字段定义**:
- `id` (int?) - Isar 自增主键，使用 `@Id()` 注解
- `recordId` (int) - 关联的记录ID
- `name` (String) - 称呼
- `platform` (String) - 平台（微信/电话/小红书/Instagram）
- `account` (String) - 账号
- `impressionScore` (int) - 印象分 1-5
- `followUpDate` (DateTime?) - 跟进日期

**序列化方式**:
- 使用 `json_serializable` 自动生成 `fromJson` 和 `toJson` 方法

### 2.3 执行代码生成
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## 阶段三：数据访问层开发

### 3.1 LocalDbService 核心功能
**初始化方法**:
- 使用 `path_provider` 获取应用文档目录
- 初始化 Isar 实例（仅移动端）
- 单例模式实现

**CRUD 方法**:
- `init()` - 初始化数据库
- `addRecord(ApproachRecord record, Contact? contact)` - 新增记录（成功时同时保存 Contact）
- `getAllRecords()` - 查询所有记录
- `getAllContacts()` - 查询所有联系人
- `getContactsByRecordId(int recordId)` - 查询指定记录的联系人
- `deleteRecord(int id)` - 删除记录
- `insertTestData()` - 插入测试数据（开发阶段使用）

**备份导出功能**:
- `exportData()` - 导出所有数据为 JSON 文件
  - 从数据库取出所有 ApproachRecord 和 Contact
  - 转换为 JSON 字符串
  - 使用 `file_picker` 弹出保存对话框
  - 保存为 `meetlog_backup.json`

**备份导入功能**:
- `importData()` - 从 JSON 文件恢复数据
  - 使用 `file_picker` 选择备份文件
  - 读取并解析 JSON
  - 清除当前数据库
  - 批量写入备份数据

### 3.2 Riverpod Provider 配置
- 创建 `localDbServiceProvider` - 提供数据库服务实例
- 创建 `recordsProvider` (StreamProvider) - 监听记录数据变化
- 创建 `contactsProvider` (StreamProvider) - 监听联系人数据变化

---

## 阶段四：应用初始化与路由配置

### 4.1 main.dart 初始化流程
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDbService.instance.init();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 4.2 MainScreen 主界面
**结构**:
- 使用 `NavigationBar` (Material 3 底部导航栏)
- 三个 Tab：
  - 记录 (`/records`) - 首页，新增记录入口
  - 图鉴 (`/contacts`) - 联系人列表
  - 复盘 (`/dashboard`) - 数据统计面板

### 4.3 路由配置 (go_router)
- 定义路由表
- 配置初始路由为 `/records`
- 使用 `ShellRoute` 保持底部导航栏状态

---

## 阶段五：核心页面开发

### 5.1 AddRecordScreen - 新增搭讪记录页面
**UI 布局**:
- 顶部两个大面积 Card 按钮：
  - "✅ 成功拿到联系方式"
  - "❌ 遗憾失败"

**成功表单** (点击成功按钮展开):
- 称呼输入框（提示："对方的称呼或特征，如：穿白裙的女孩/Lina"）
- 平台选择下拉框（微信/电话/小红书/Instagram）
- 账号输入框（提示："填入微信号或手机号"）
- 地点输入框（提示："在哪相遇的？如：星巴克/地铁2号线"）
- 初印象评分（1-5星）

**失败表单** (点击失败按钮展开):
- ChoiceChip 选择失败原因：
  - 太紧张
  - 开场白生硬
  - 对方有伴侣
  - 直接被拒
  - 其他
- 多行文本框：即时复盘（提示："这次哪里做的不够好？下次怎么改进？"）

**交互**:
- 保存按钮调用 `LocalDbService`
- 保存成功后弹窗提示
- 返回列表页并刷新数据

### 5.2 ContactsScreen - 联系人图鉴页面
**UI 布局**:
- 顶部搜索框（按姓名/特征搜索）
- `ListView.builder` 列表

**列表项 Card**:
- 对方称呼（大字）
- 记录时间和地点（小字）
- 印象分（星星图标展示）
- 平台图标（通用 Icon 代替）

**特殊功能**:
- 如果距离 `followUpDate` 小于 1 天，卡片右上角显示红底白字标签："🔔 该打个招呼啦"
- 监听 Riverpod Provider，新增联系人后自动刷新

### 5.3 DashboardScreen - 数据统计面板
**UI 布局**:
- 顶部 `SegmentedButton` 切换：【本周总结】/【本月总结】

**图表展示** (使用 fl_chart):
- **成功率饼图** (`PieChart`)
  - 展示成功与失败比例
  - 中心显示总次数（如"共15次"）
  
- **失败原因柱状图** (`BarChart`)
  - X轴：失败原因
  - Y轴：次数

**复盘回顾墙**:
- 纵向 `ListView`（使用 `NestedScrollView` 处理滑动嵌套）
- 展示该周期内所有失败复盘文本
- 每条显示：时间、失败原因标签、反思内容

**数据管理入口**:
- AppBar 右上角 `IconButton` (设置/数据图标)
- 点击弹出 `BottomSheet`
- 包含两个按钮：
  - "导出数据备份"
  - "导入数据恢复"

---

## 阶段六：功能集成与优化

### 6.1 备份功能集成
- 在 DashboardScreen 的 BottomSheet 中调用 `LocalDbService.exportData()`
- 在 DashboardScreen 的 BottomSheet 中调用 `LocalDbService.importData()`

### 6.2 异常处理
- 用户取消文件选择
- 文件读取失败
- 数据格式错误
- 数据库写入失败
- Android 11+ 分区存储权限处理

### 6.3 UI 优化
- Material 3 设计规范
- 单手操作友好的布局
- 流畅的动画过渡
- 适当的加载状态提示

---

## 技术要点总结

1. **Isar 数据库**: 本地高性能数据库，支持复杂查询和关系
2. **Riverpod**: 响应式状态管理，自动监听数据变化
3. **go_router**: 声明式路由管理
4. **file_picker**: 跨平台文件选择器
5. **fl_chart**: 美观的图表库
6. **Material 3**: 最新设计规范
7. **json_serializable**: 类型安全的 JSON 序列化

---

## 风险评估与缓解措施

| 风险项 | 等级 | 缓解措施 |
|--------|------|----------|
| 依赖版本冲突 | 低 | 已验证兼容性 |
| 平台权限问题 | 中 | 提前配置权限，处理 Android 11+ 分区存储 |
| 数据序列化错误 | 低 | 使用 json_serializable 自动生成 |
| UI 滑动嵌套问题 | 中 | 使用 NestedScrollView |
| 文件读写失败 | 中 | 完善异常处理，用户取消操作处理 |

---

## 开发顺序（优化版）

1. ✅ 初始化项目 → 配置依赖 → 配置平台权限
2. ✅ 创建数据模型 → 使用 json_serializable → 执行代码生成
3. ✅ 实现 LocalDbService → 包含初始化和测试数据方法
4. ✅ 搭建 MainScreen → 配置 Material 3 主题 → 配置路由
5. ✅ 开发 AddRecordScreen → 可产生真实数据
6. ✅ 开发 ContactsScreen → 使用真实数据测试
7. ✅ 开发 DashboardScreen → 集成图表和备份功能
8. ✅ 全面测试 → 优化用户体验
