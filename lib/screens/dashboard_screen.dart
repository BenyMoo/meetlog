import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/approach_record.dart';
import '../providers/db_providers.dart';
import 'settings_screen.dart';

enum TimeRange { week, month }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  TimeRange _selectedRange = TimeRange.week;

  DateTime get _startDate {
    final now = DateTime.now();
    if (_selectedRange == TimeRange.week) {
      return now.subtract(Duration(days: now.weekday - 1));
    } else {
      return DateTime(now.year, now.month, 1);
    }
  }

  DateTime get _endDate {
    final now = DateTime.now();
    if (_selectedRange == TimeRange.week) {
      return now;
    } else {
      return DateTime(now.year, now.month + 1, 0);
    }
  }

  List<ApproachRecord> _filterRecordsByRange(List<ApproachRecord> records) {
    return records.where((r) {
      return r.dateTime.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
          r.dateTime.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('复盘'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: recordsAsync.when(
        data: (allRecords) {
          final records = _filterRecordsByRange(allRecords);
          return _buildContent(context, records);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('加载失败: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ApproachRecord> records) {
    final successCount = records.where((r) => r.isSuccess).length;
    final failCount = records.length - successCount;
    final failRecords = records.where((r) => !r.isSuccess).toList();

    final failReasonStats = <String, int>{};
    for (final record in failRecords) {
      if (record.failReason != null) {
        failReasonStats[record.failReason!] =
            (failReasonStats[record.failReason!] ?? 0) + 1;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<TimeRange>(
            segments: const [
              ButtonSegment(value: TimeRange.week, label: Text('本周总结')),
              ButtonSegment(value: TimeRange.month, label: Text('本月总结')),
            ],
            selected: {_selectedRange},
            onSelectionChanged: (Set<TimeRange> selection) {
              setState(() {
                _selectedRange = selection.first;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSummaryCard(context, records.length, successCount, failCount),
          const SizedBox(height: 20),
          if (records.isNotEmpty) ...[
            _buildPieChartSection(context, successCount, failCount),
            const SizedBox(height: 24),
            if (failReasonStats.isNotEmpty) ...[
              _buildBarChartSection(context, failReasonStats),
              const SizedBox(height: 24),
            ],
            if (failRecords.isNotEmpty) ...[
              _buildReflectionWall(context, failRecords),
            ],
          ] else
            _DashboardEmptyState(selectedRange: _selectedRange),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    int total,
    int success,
    int fail,
  ) {
    final rate = total > 0 ? (success / total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, '总次数', total.toString(), Icons.list),
          _buildVerticalDivider(),
          _buildStatItem(context, '成功', success.toString(), Icons.check_circle,
              color: const Color(0xFF4CAF50)),
          _buildVerticalDivider(),
          _buildStatItem(context, '失败', fail.toString(), Icons.cancel,
              color: const Color(0xFFFF7043)),
          _buildVerticalDivider(),
          _buildStatItem(context, '成功率', '$rate%', Icons.trending_up,
              color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildPieChartSection(
    BuildContext context,
    int success,
    int fail,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '成功率分布',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  value: success.toDouble(),
                  title: success > 0 ? '成功\n$success' : '',
                  color: const Color(0xFF4CAF50),
                  radius: 60,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                PieChartSectionData(
                  value: fail.toDouble(),
                  title: fail > 0 ? '失败\n$fail' : '',
                  color: const Color(0xFFFF7043),
                  radius: 60,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartSection(
    BuildContext context,
    Map<String, int> failReasonStats,
  ) {
    final reasons = failReasonStats.keys.toList();
    final maxCount = failReasonStats.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '失败原因分析',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxCount + 1).toDouble(),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= reasons.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          reasons[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              barGroups: reasons.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: failReasonStats[entry.value]!.toDouble(),
                      color: const Color(0xFFFF7043),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionWall(
    BuildContext context,
    List<ApproachRecord> failRecords,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '复盘回顾墙',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ...failRecords.map((record) {
          if (record.reflection == null || record.reflection!.isEmpty) {
            return const SizedBox();
          }
          return _buildReflectionCard(context, record);
        }),
      ],
    );
  }

  Widget _buildReflectionCard(BuildContext context, ApproachRecord record) {
    final dateFormat = DateFormat('MM/dd HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateFormat.format(record.dateTime),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7043).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.failReason ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFFF7043),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            record.reflection!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DashboardEmptyState extends StatefulWidget {
  final TimeRange selectedRange;

  const _DashboardEmptyState({required this.selectedRange});

  @override
  State<_DashboardEmptyState> createState() => _DashboardEmptyStateState();
}

class _DashboardEmptyStateState extends State<_DashboardEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

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
            const Color(0xFFE3F2FD).withValues(alpha: 0.5),
            const Color(0xFFBBDEFB).withValues(alpha: 0.3),
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
                        const Color(0xFF42A5F5).withValues(alpha: 0.2),
                        const Color(0xFF1E88E5).withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E88E5).withValues(alpha: 0.15),
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
                        color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        size: 40,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF1E88E5),
                    Color(0xFF42A5F5),
                  ],
                ).createShader(bounds),
                child: Text(
                  '用数据见证成长',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.selectedRange == TimeRange.week
                    ? '本周还没有任何记录'
                    : '本月还没有任何记录',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '开始记录后，这里将展示你的成长轨迹',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildFeatureItem(
                          context,
                          label: '成功率分析',
                        ),
                        const SizedBox(width: 16),
                        _buildFeatureItem(
                          context,
                          label: '失败原因',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildFeatureItem(
                          context,
                          label: '复盘回顾',
                        ),
                        const SizedBox(width: 16),
                        _buildFeatureItem(
                          context,
                          label: '成长曲线',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '添加第一条记录，解锁全部功能',
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

  Widget _buildFeatureItem(
    BuildContext context, {
    required String label,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 16,
              color: Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
