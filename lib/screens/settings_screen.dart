import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/db_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数据管理',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.upload_file,
                  title: '导出数据备份',
                  subtitle: '将数据导出为 JSON 文件',
                  onTap: () async {
                    final dbService = ref.read(localDbServiceProvider);
                    final path = await dbService.exportData();
                    if (context.mounted) {
                      if (path != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('备份已保存: $path')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('导出已取消')),
                        );
                      }
                    }
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.download,
                  title: '导入数据恢复',
                  subtitle: '从 JSON 文件恢复数据',
                  onTap: () async {
                    final dbService = ref.read(localDbServiceProvider);
                    final success = await dbService.importData();
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('数据已恢复')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('导入失败或已取消')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '开发选项',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.science_outlined,
                  title: '插入测试数据',
                  subtitle: '用于开发测试',
                  onTap: () async {
                    final dbService = ref.read(localDbServiceProvider);
                    await dbService.insertTestData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('测试数据已插入')),
                      );
                    }
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.delete_outline,
                  title: '清空所有数据',
                  subtitle: '删除所有记录和联系人',
                  titleColor: Colors.red[400],
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('确认清空'),
                        content: const Text('确定要清空所有数据吗？此操作不可撤销。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('清空', style: TextStyle(color: Colors.red[400])),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      final dbService = ref.read(localDbServiceProvider);
                      await dbService.clearAllData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('数据已清空')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '关于',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: '版本',
                  subtitle: '1.0.0',
                  onTap: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (titleColor ?? Theme.of(context).colorScheme.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: titleColor ?? Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 76),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.grey[200],
      ),
    );
  }
}
