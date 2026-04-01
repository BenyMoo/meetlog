import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/contact.dart';
import '../providers/db_providers.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case '微信':
        return Icons.chat;
      case '电话':
        return Icons.phone;
      case '小红书':
        return Icons.book;
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
      case '电话':
        return const Color(0xFF4CAF50);
      case '小红书':
        return const Color(0xFFFF2442);
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

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('图鉴'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                });
              },
              decoration: InputDecoration(
                hintText: '搜索称呼或账号',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: Icon(Icons.clear, color: Colors.grey[500]),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
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
                final filteredContacts = _filterContacts(contacts);
                if (filteredContacts.isEmpty) {
                  if (_searchQuery.isNotEmpty) {
                    return _SearchEmptyState(query: _searchQuery);
                  }
                  return const _ContactsEmptyState();
                }
                return _buildContactsList(context, filteredContacts);
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

  Widget _buildContactCard(BuildContext context, Contact contact) {
    final dateFormat = DateFormat('MM/dd');
    final platformColor = _getPlatformColor(contact.platform);
    final showReminder = _shouldShowReminder(contact.followUpDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: platformColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              contact.platform,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: platformColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.account,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < contact.impressionScore
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFFFB300),
                              size: 18,
                            );
                          }),
                          const SizedBox(width: 8),
                          if (contact.followUpDate != null)
                            Text(
                              '跟进: ${dateFormat.format(contact.followUpDate!)}',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[500],
                                      ),
                            ),
                        ],
                      ),
                    ],
                  ),
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            const Color(0xFFFFF8E1).withValues(alpha: 0.5),
            const Color(0xFFFFECB3).withValues(alpha: 0.3),
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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFB300).withValues(alpha: 0.2),
                      const Color(0xFFFF8F00).withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.15),
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
                      color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: Color(0xFFFF8F00),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFF8F00),
                  Color(0xFFFFB300),
                ],
              ).createShader(bounds),
              child: Text(
                '收集心动瞬间',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '每一个联系方式都是一段故事的开始',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '成功拿到联系方式后，会自动收藏在这里',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFFFF8F00),
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
                                color: const Color(0xFFFF8F00),
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '去「记录」页面添加你的第一次搭讪吧！',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
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
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.search_off_rounded,
                  size: 50,
                  color: Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '未找到 "$query"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '试试其他关键词吧',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
