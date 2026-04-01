import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/contact.dart';
import '../providers/db_providers.dart';
import '../services/local_db_service.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isReordering = false;
  List<Contact> _contacts = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case '微信':
        return Icons.chat_rounded;
      case 'QQ':
        return Icons.chat;
      case '微博':
        return Icons.alternate_email;
      case '抖音':
        return Icons.music_note;
      case '小红书':
        return Icons.book;
      case '电话':
        return Icons.phone;
      case 'Instagram':
        return Icons.camera_alt;
      default:
        return Icons.contact_page;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case '微信':
        return const Color(0xFF07C160);
      case 'QQ':
        return const Color(0xFF12B7F5);
      case '微博':
        return const Color(0xFFE6162D);
      case '抖音':
        return const Color(0xFF000000);
      case '小红书':
        return const Color(0xFFFF2442);
      case '电话':
        return const Color(0xFF4CAF50);
      case 'Instagram':
        return const Color(0xFFE1306C);
      default:
        return Colors.grey;
    }
  }

  bool _shouldShowReminder(DateTime? followUpDate) {
    if (followUpDate == null) return false;
    final now = DateTime.now();
    final difference = followUpDate.difference(now);
    return difference.inHours < 24 && difference.inHours > -24;
  }

  List<Contact> _filterContacts(List<Contact> contacts) {
    if (_searchQuery.isEmpty) return contacts;
    return contacts.where((contact) {
      return contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact.account.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _saveOrder() async {
    final dbService = ref.read(localDbServiceProvider);
    for (int i = 0; i < _contacts.length; i++) {
      await dbService.updateContactOrder(_contacts[i].id, i);
    }
    ref.invalidate(contactsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('联系人'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          contactsAsync.when(
            data: (contacts) {
              if (contacts.length > 1 && _searchQuery.isEmpty) {
                return TextButton(
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
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  if (value.isNotEmpty) {
                    _isReordering = false;
                  }
                });
              },
              decoration: InputDecoration(
                hintText: '搜索称呼或账号',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: contactsAsync.when(
              data: (contacts) {
                if (!_isReordering || _contacts.isEmpty) {
                  _contacts = List.from(contacts);
                }
                final filteredContacts = _filterContacts(_contacts);
                if (filteredContacts.isEmpty) {
                  if (_searchQuery.isNotEmpty) {
                    return _SearchEmptyState(query: _searchQuery);
                  }
                  return const _ContactsEmptyState();
                }
                return _isReordering && _searchQuery.isEmpty
                    ? _buildReorderableList(context, filteredContacts)
                    : _buildContactsList(context, filteredContacts);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('加载失败: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderableList(BuildContext context, List<Contact> contacts) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: contacts.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = contacts.removeAt(oldIndex);
          contacts.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Container(
          key: ValueKey(contact.id),
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildContactCard(context, contact, showOptions: false),
        );
      },
    );
  }

  Widget _buildContactsList(BuildContext context, List<Contact> contacts) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return _buildContactCard(context, contact);
      },
    );
  }

  Widget _buildContactCard(BuildContext context, Contact contact, {bool showOptions = true}) {
    final dateFormat = DateFormat('MM/dd');
    final platformColor = _getPlatformColor(contact.platform);
    final showReminder = _shouldShowReminder(contact.followUpDate);

    return GestureDetector(
      onTap: () => _showContactDetail(context, contact),
      onLongPress: showOptions ? () => _showContactOptions(context, contact) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          platformColor.withValues(alpha: 0.2),
                          platformColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getPlatformIcon(contact.platform),
                      color: platformColor,
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
                            Expanded(
                              child: Text(
                                contact.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: platformColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                contact.platform,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 11,
                                      color: platformColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contact.account,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < contact.impressionScore
                                    ? Icons.star
                                    : Icons.star_border,
                                color: const Color(0xFFFFB300),
                                size: 14,
                              );
                            }),
                            const SizedBox(width: 8),
                            if (contact.followUpDate != null)
                              Text(
                                '跟进: ${dateFormat.format(contact.followUpDate!)}',
                                style:
                                    Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                        ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showOptions)
                    Icon(
                      Icons.more_vert,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
            if (showReminder)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_active, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '该打个招呼啦',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context, Contact contact) {
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
              title: Text('删除联系人', style: TextStyle(color: Colors.red[400])),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('确定要删除这个联系人吗？'),
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
                  await dbService.deleteContact(contact.id);
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

  void _showContactDetail(BuildContext context, Contact contact) async {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final platformColor = _getPlatformColor(contact.platform);
    
    final dbService = ref.read(localDbServiceProvider);
    final record = await dbService.getRecordById(contact.recordId);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        platformColor.withValues(alpha: 0.2),
                        platformColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getPlatformIcon(contact.platform),
                    color: platformColor,
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
                          Expanded(
                            child: Text(
                              contact.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: contact.name));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('昵称已复制'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.copy,
                              size: 18,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: platformColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              contact.platform,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: platformColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ...List.generate(5, (index) {
                            return Icon(
                              index < contact.impressionScore ? Icons.star : Icons.star_border,
                              color: const Color(0xFFFFB300),
                              size: 16,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (record != null)
              _buildDetailRow(context, '地点', record.location, Icons.place_outlined),
            _buildDetailRow(context, '账号', contact.account, Icons.alternate_email),
            if (contact.impression != null && contact.impression!.isNotEmpty)
              _buildDetailRow(context, '印象', contact.impression!, Icons.face_outlined),
            if (contact.hobby != null && contact.hobby!.isNotEmpty)
              _buildDetailRow(context, '爱好', contact.hobby!, Icons.favorite_outline),
            if (contact.followUpDate != null)
              _buildDetailRow(context, '跟进日期', dateFormat.format(contact.followUpDate!), Icons.calendar_today),
            if (contact.createdAt != null)
              _buildDetailRow(context, '添加时间', dateFormat.format(contact.createdAt!), Icons.access_time),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label 已复制'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.copy,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactsEmptyState extends StatefulWidget {
  const _ContactsEmptyState();

  @override
  State<_ContactsEmptyState> createState() => _ContactsEmptyStateState();
}

class _ContactsEmptyStateState extends State<_ContactsEmptyState>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            tertiaryColor.withValues(alpha: isDark ? 0.08 : 0.05),
            tertiaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tertiaryColor.withValues(alpha: 0.2),
                      tertiaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: tertiaryColor.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: tertiaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 32,
                      color: tertiaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  tertiaryColor,
                  Theme.of(context).colorScheme.primary,
                ],
              ).createShader(bounds),
              child: Text(
                '收集心动瞬间',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '每一个联系方式都是一段故事的开始',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              '成功拿到联系方式后，会自动收藏在这里',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: tertiaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: tertiaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tertiaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: tertiaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '小贴士',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tertiaryColor,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '去「记录」页面添加你的第一次搭讪吧！',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  final String query;

  const _SearchEmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.search_off_rounded,
                  size: 50,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '未找到 "$query"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '试试其他关键词吧',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
