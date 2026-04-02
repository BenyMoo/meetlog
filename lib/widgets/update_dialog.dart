import 'package:flutter/material.dart';

import '../models/app_update_info.dart';
import '../services/external_link_service.dart';

class UpdateDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !updateInfo.forceUpdate,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: Theme.of(context).colorScheme.primary,
              size: 26,
            ),
            const SizedBox(width: 10),
            const Text('发现新版本'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'v${updateInfo.version}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 15,
                ),
              ),
            ),
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                '更新内容',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    updateInfo.releaseNotes,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!updateInfo.forceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('稍后再说'),
            ),
          FilledButton.icon(
            onPressed: () async {
              await ExternalLinkService.open(updateInfo.downloadUrl);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('立即更新'),
          ),
        ],
      ),
    );
  }

  static Future<void> show(BuildContext context, AppUpdateInfo info) {
    return showDialog(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (_) => UpdateDialog(updateInfo: info),
    );
  }
}
