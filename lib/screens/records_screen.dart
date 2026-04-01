import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/approach_record.dart';
import '../providers/db_providers.dart';
import 'add_record_screen.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddRecordScreen(),
                  ),
                );
              },
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('记录'),
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          floatingActionButton: FloatingActionButton.small(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddRecordScreen(),
                ),
              );
            },
            child: const Icon(Icons.add, size: 24),
          ),
          body: _buildRecordsList(context, ref, records),
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

  Widget _buildRecordsList(
    BuildContext context,
    WidgetRef ref,
    List<ApproachRecord> records,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(context, ref, record);
      },
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    WidgetRef ref,
    ApproachRecord record,
  ) {
    final dateFormat = DateFormat('MM/dd HH:mm');
    final isSuccess = record.isSuccess;

    return Dismissible(
      key: Key(record.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
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
      },
      onDismissed: (direction) async {
        final dbService = ref.read(localDbServiceProvider);
        await dbService.deleteRecord(record.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已删除')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSuccess
                ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                : const Color(0xFFFF7043).withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                      : const Color(0xFFFF7043).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check : Icons.close,
                  color: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF7043),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record.location,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(record.dateTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                    if (!isSuccess && record.failReason != null) ...[
                      const SizedBox(height: 8),
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
                    ],
                  ],
                ),
              ),
            ],
          ),
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
      child: SingleChildScrollView(
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.explore_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ).createShader(bounds),
                child: Text(
                  '开启你的故事',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '每一次相遇都是命运的安排',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '勇敢迈出第一步，记录下心动的瞬间',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
              const SizedBox(height: 40),
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
                      horizontal: 32,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
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
                      color: Colors.grey[400],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
