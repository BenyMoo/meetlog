import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/approach_record.dart';
import '../providers/db_providers.dart';
import '../services/local_db_service.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  bool _isReordering = false;
  List<ApproachRecord> _records = [];

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordsProvider);

    return recordsAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('记录'),
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            body: _EmptyStateWidget(
              onAction: () {
                context.push('/add-record');
              },
            ),
          );
        }
        
        if (!_isReordering || _records.isEmpty) {
          _records = List.from(records);
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('记录'),
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              if (records.length > 1)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isReordering = !_isReordering;
                      if (!_isReordering) {
                        _saveOrder();
                      }
                    });
                  },
                  child: Text(
                    _isReordering ? '完成' : '排序',
                    style: TextStyle(
                      color: _isReordering 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.small(
            onPressed: () {
              context.push('/add-record');
            },
            child: const Icon(Icons.add, size: 24),
          ),
          body: _isReordering 
              ? _buildReorderableList(context, ref)
              : _buildRecordsList(context, ref),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('记录'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('记录'),
          centerTitle: true,
        ),
        body: Center(child: Text('加载失败: $error')),
      ),
    );
  }

  Future<void> _saveOrder() async {
    final dbService = ref.read(localDbServiceProvider);
    for (int i = 0; i < _records.length; i++) {
      if (_records[i].id != null) {
        await dbService.updateRecordOrder(_records[i].id!, i);
      }
    }
    ref.invalidate(recordsProvider);
  }

  Widget _buildReorderableList(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _records.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _records.removeAt(oldIndex);
          _records.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final record = _records[index];
        return Container(
          key: ValueKey(record.id),
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildRecordCard(context, ref, record, showDeleteButton: false),
        );
      },
    );
  }

  Widget _buildRecordsList(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return _buildRecordCard(context, ref, record);
      },
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    WidgetRef ref,
    ApproachRecord record, {
    bool showDeleteButton = true,
  }) {
    final dateFormat = DateFormat('MM/dd HH:mm');
    final isSuccess = record.isSuccess;

    return GestureDetector(
      onLongPress: showDeleteButton ? () => _showRecordOptions(context, ref, record) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSuccess
                ? [
                    const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    const Color(0xFF4CAF50).withValues(alpha: 0.05),
                  ]
                : [
                    const Color(0xFFFF7043).withValues(alpha: 0.1),
                    const Color(0xFFFF7043).withValues(alpha: 0.05),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSuccess
                ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                : const Color(0xFFFF7043).withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                      : const Color(0xFFFF7043).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check : Icons.close,
                  color: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF7043),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(record.dateTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (!isSuccess && record.failReason != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7043).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    record.failReason!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFFF7043),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              if (showDeleteButton) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.more_vert,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordOptions(BuildContext context, WidgetRef ref, ApproachRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[400]),
              title: Text('删除记录', style: TextStyle(color: Colors.red[400])),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('确定要删除这条记录吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('删除', style: TextStyle(color: Colors.red[400])),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  final dbService = ref.read(localDbServiceProvider);
                  await dbService.deleteRecord(record.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已删除')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatefulWidget {
  final VoidCallback onAction;

  const _EmptyStateWidget({required this.onAction});

  @override
  State<_EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<_EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: child,
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.explore_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ).createShader(bounds),
                child: Text(
                  '开启你的故事',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '每一次相遇都是命运的安排',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '勇敢迈出第一步，记录下心动的瞬间',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: widget.onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '开始第一次记录',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '点击上方按钮开始',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ),
              ),
            ),
          );
        },
      ),
    );
  }
}
