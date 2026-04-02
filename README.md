# MeetLog (遇记)

一款专注于社交搭讪记录与复盘的 Flutter 应用。

## 项目简介

MeetLog 是一款纯本地化的移动应用，帮助用户记录搭讪经历、管理联系人信息，并通过数据统计进行自我复盘提升。

## 核心特性

- **纯本地存储**: 使用 Isar 数据库，无需后端服务器
- **数据备份**: 支持导出/导入 JSON 格式的备份数据
- **联系人管理**: 搭讪成功后记录联系人信息
- **数据统计**: 可视化展示成功率、失败原因分布
- **复盘功能**: 记录失败经历并进行反思总结

## 技术栈

- **Flutter**: 跨平台移动应用框架
- **Isar**: 高性能本地数据库
- **Riverpod**: 状态管理
- **go_router**: 路由管理
- **fl_chart**: 数据可视化图表
- **Material 3**: UI 设计规范

## 开发环境

- Flutter SDK: ^3.11.4
- Dart SDK: ^3.11.4
- 平台: iOS / Android

## 快速开始

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
flutter run


flutter run --android-skip-build-dependency-validation
```

### 代码生成

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 项目结构

```
lib/
├── main.dart           # 应用入口
├── models/            # 数据模型
│   ├── approach_record.dart
│   └── contact.dart
├── services/          # 服务层
│   └── local_db_service.dart
├── screens/           # 页面
│   ├── main_screen.dart
│   ├── add_record_screen.dart
│   ├── contacts_screen.dart
│   └── dashboard_screen.dart
├── providers/         # Riverpod Providers
└── routes/            # 路由配置
```

## 开发计划

详细开发计划请参考 [PLAN.md](PLAN.md)

## 许可证

MIT License
