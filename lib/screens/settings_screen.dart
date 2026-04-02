import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../providers/db_providers.dart';
import '../providers/pro_provider.dart';
import '../providers/theme_provider.dart';
import '../services/pro_license_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProActivated = ref.watch(proActivatedProvider);
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
              '外观',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                _buildThemeTile(context, ref),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '会员',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: isProActivated ? Icons.verified : Icons.workspace_premium,
                  title: '激活 Pro 版',
                  subtitle: isProActivated
                      ? '当前状态：已激活'
                      : '复制设备请求串，去外部系统换取激活码',
                  onTap: () => _showProActivationDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '数据管理',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          SnackBar(
                            content: Text('备份已保存: $path'),
                            duration: const Duration(milliseconds: 500),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('导出已取消'),
                            duration: Duration(milliseconds: 500),
                          ),
                        );
                      }
                    }
                  },
                ),
                _buildDivider(context),
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
                          const SnackBar(
                            content: Text('数据已恢复'),
                            duration: Duration(milliseconds: 500),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('导入失败或已取消'),
                            duration: Duration(milliseconds: 500),
                          ),
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                        const SnackBar(
                          content: Text('测试数据已插入'),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    }
                  },
                ),
                _buildDivider(context),
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
                          const SnackBar(
                            content: Text('数据已清空'),
                            duration: Duration(milliseconds: 500),
                          ),
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  onTap: () => _showVersionNoticeDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showVersionNoticeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('用户说明'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. 用户数据完全本地存储，不收集任何个人信息。'),
            SizedBox(height: 8),
            Text('2. 未经授权，不得对本应用进行二次开发、转售或用于商业售卖。'),
            SizedBox(height: 8),
            Text('3. 用户继续使用本应用，即视为同意用户协议与隐私政策。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              SystemNavigator.pop();
            },
            child: const Text('不同意'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('同意'),
          ),
        ],
      ),
    );
  }

  void _showProActivationDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String activationRequest = '';
    String deviceSummary = '';
    String? errorText;
    bool isBusy = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('激活 Pro 版'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '关注微信公众号：$proActivationWechat',
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. 生成激活序列号，会自动复制到剪贴板\n2. 在公众号回复激活MeetLog序列号\n3. 粘贴激活码完成APP激活',
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                        color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: isBusy
                      ? null
                      : () async {
                          setState(() {
                            isBusy = true;
                            errorText = null;
                          });
                          try {
                            final notifier =
                                ref.read(proActivatedProvider.notifier);
                            final identity =
                                await notifier.getDeviceIdentity();
                            final request =
                                await notifier.buildActivationRequest();
                            await Clipboard.setData(
                              ClipboardData(text: request),
                            );
                            if (!dialogContext.mounted) {
                              return;
                            }
                            setState(() {
                              activationRequest = request;
                              deviceSummary =
                                  '${identity.deviceIdType}  ${identity.maskedDeviceId}';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('设备激活请求已复制'),
                                duration: Duration(milliseconds: 700),
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              errorText = e.toString();
                            });
                          } finally {
                            if (dialogContext.mounted) {
                              setState(() {
                                isBusy = false;
                              });
                            }
                          }
                        },
                  icon: const Icon(Icons.copy_all_outlined),
                  label: Text(isBusy ? '生成中...' : '生成激活序列号-自动复制'),
                ),
                if (deviceSummary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '当前设备标识: $deviceSummary',
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  ),
                ],
                if (activationRequest.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(dialogContext)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activationRequest,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(dialogContext)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: '请输入外部系统返回的激活码',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorText!,
                    style: TextStyle(color: Colors.red[400], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (ref.read(proActivatedProvider))
              TextButton(
                onPressed: () async {
                  await ref.read(proActivatedProvider.notifier).deactivate();
                  if (!dialogContext.mounted) {
                    return;
                  }
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已清除本机激活状态'),
                      duration: Duration(milliseconds: 700),
                    ),
                  );
                },
                child: const Text('清除激活'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: isBusy
                  ? null
                  : () async {
                      setState(() {
                        isBusy = true;
                        errorText = null;
                      });
                      final notifier = ref.read(proActivatedProvider.notifier);
                      try {
                        final result = await notifier.activate(controller.text);
                        if (!dialogContext.mounted) {
                          return;
                        }
                        if (!result.valid) {
                          setState(() {
                            errorText = result.reason;
                          });
                          return;
                        }
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pro 已激活，可离线使用'),
                            duration: Duration(milliseconds: 700),
                          ),
                        );
                      } catch (e) {
                        if (!dialogContext.mounted) {
                          return;
                        }
                        setState(() {
                          errorText = e.toString();
                        });
                      } finally {
                        if (dialogContext.mounted) {
                          setState(() {
                            isBusy = false;
                          });
                        }
                      }
                    },
              child: const Text('激活'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeName = switch (themeMode) {
      AppThemeMode.light => '浅色',
      AppThemeMode.dark => '深色',
      AppThemeMode.system => '跟随系统',
    };

    return InkWell(
      onTap: () => _showThemeDialog(context, ref),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '主题',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    themeName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: RadioGroup<AppThemeMode>(
          groupValue: currentMode,
          onChanged: (value) {
            if (value != null) {
              ref.read(themeModeProvider.notifier).setThemeMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                title: '浅色',
                mode: AppThemeMode.light,
              ),
              _buildThemeOption(
                title: '深色',
                mode: AppThemeMode.dark,
              ),
              _buildThemeOption(
                title: '跟随系统',
                mode: AppThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required AppThemeMode mode,
  }) {
    return RadioListTile<AppThemeMode>(
      title: Text(title),
      value: mode,
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (titleColor ?? Theme.of(context).colorScheme.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: titleColor ?? Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
