import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/approach_record.dart';
import '../models/contact.dart';
import '../providers/db_providers.dart';

class AddRecordScreen extends ConsumerStatefulWidget {
  const AddRecordScreen({super.key});

  @override
  ConsumerState<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends ConsumerState<AddRecordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool? _isSuccess;
  bool _isExpanded = false;

  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _locationController = TextEditingController();
  final _reflectionController = TextEditingController();
  final _impressionController = TextEditingController();
  final _hobbyController = TextEditingController();

  String _selectedPlatform = '微信';
  int _impressionScore = 3;
  String? _selectedFailReason;

  final List<String> _platforms = ['微信', 'QQ', '微博', '抖音', '小红书', '电话', 'Instagram'];
  final List<String> _failReasons = [
    '说话太紧张',
    '开场白生硬',
    '对方有伴侣',
    '直接被拒',
    '时机不对',
    '话题枯竭',
    '肢体不自然',
    '对方赶时间',
    '其他'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _accountController.dispose();
    _locationController.dispose();
    _reflectionController.dispose();
    _impressionController.dispose();
    _hobbyController.dispose();
    super.dispose();
  }

  void _selectType(bool isSuccess) {
    setState(() {
      _isSuccess = isSuccess;
      _isExpanded = true;
    });
    _animationController.forward();
  }

  void _resetForm() {
    setState(() {
      _isSuccess = null;
      _isExpanded = false;
      _nameController.clear();
      _accountController.clear();
      _locationController.clear();
      _reflectionController.clear();
      _impressionController.clear();
      _hobbyController.clear();
      _selectedPlatform = '微信';
      _impressionScore = 3;
      _selectedFailReason = null;
    });
    _animationController.reset();
  }

  bool _isFormValid() {
    if (_isSuccess == true) {
      return _nameController.text.isNotEmpty &&
          _accountController.text.isNotEmpty &&
          _locationController.text.isNotEmpty;
    } else {
      return _locationController.text.isNotEmpty && _selectedFailReason != null;
    }
  }

  Future<void> _saveRecord() async {
    if (!_isFormValid()) return;

    final dbService = ref.read(localDbServiceProvider);

    if (_isSuccess == true) {
      final record = ApproachRecord(
        dateTime: DateTime.now(),
        location: _locationController.text,
        isSuccess: true,
      );

      final contact = Contact(
        name: _nameController.text,
        platform: _selectedPlatform,
        account: _accountController.text,
        impressionScore: _impressionScore,
        impression: _impressionController.text.isEmpty ? null : _impressionController.text,
        hobby: _hobbyController.text.isEmpty ? null : _hobbyController.text,
        recordId: 0,
      );

      await dbService.addRecord(record, contact: contact);
    } else {
      final record = ApproachRecord(
        dateTime: DateTime.now(),
        location: _locationController.text,
        isSuccess: false,
        failReason: _selectedFailReason,
        reflection: _reflectionController.text.isEmpty
            ? null
            : _reflectionController.text,
      );

      await dbService.addRecord(record);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSuccess == true ? '记录成功！继续加油！' : '已记录，下次会更好！'),
          backgroundColor: _isSuccess == true ? Colors.green : Colors.orange,
          duration: const Duration(milliseconds: 500),
        ),
      );
      context.go('/records');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增记录'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isExpanded) ...[
              const SizedBox(height: 40),
              _buildTypeCard(
                title: '成功拿到联系方式',
                subtitle: '太棒了！记录下这次成功的经历',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF4CAF50),
                onTap: () => _selectType(true),
              ),
              const SizedBox(height: 20),
              _buildTypeCard(
                title: '遗憾失败',
                subtitle: '没关系，复盘总结下次更好',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFFF7043),
                onTap: () => _selectType(false),
              ),
            ],
            if (_isExpanded) ...[
              Text(
                _isSuccess == true ? '成功记录' : '失败复盘',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _isSuccess == true
                      ? _buildSuccessForm()
                      : _buildFailForm(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputField(
          controller: _nameController,
          label: '称呼',
          hint: '对方的称呼或特征，如：穿白裙的女孩/Lina',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildPlatformSelector(),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _accountController,
          label: '账号',
          hint: '填入微信号或手机号',
          icon: Icons.alternate_email,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _locationController,
          label: '地点',
          hint: '在哪相遇的？如：星巴克/地铁2号线',
          icon: Icons.place_outlined,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _impressionController,
          label: '印象',
          hint: '对方的相貌、特点，如：长发、戴眼镜、穿白裙',
          icon: Icons.face_outlined,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _hobbyController,
          label: '爱好',
          hint: '对方喜欢什么、当时在干嘛，如：喜欢喝咖啡、在看书',
          icon: Icons.favorite_outline,
        ),
        const SizedBox(height: 24),
        _buildImpressionScore(),
        const SizedBox(height: 32),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildFailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputField(
          controller: _locationController,
          label: '地点',
          hint: '在哪相遇的？',
          icon: Icons.place_outlined,
        ),
        const SizedBox(height: 16),
        Text(
          '失败原因',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _failReasons.map((reason) {
            final isSelected = _selectedFailReason == reason;
            return ChoiceChip(
              label: Text(reason),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFailReason = selected ? reason : null;
                });
              },
              selectedColor: const Color(0xFFFF7043).withValues(alpha: 0.2),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFFFF7043) : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFF7043)
                    : Theme.of(context).colorScheme.outline,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          '即时复盘',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reflectionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '这次哪里做的不够好？下次怎么改进？',
            hintStyle: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF7043), width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '平台',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPlatform,
              isExpanded: true,
              style: Theme.of(context).textTheme.bodyMedium,
              items: _platforms.map((platform) {
                return DropdownMenuItem(
                  value: platform,
                  child: Text(platform),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlatform = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpressionScore() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '初印象评分',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () {
                setState(() {
                  _impressionScore = index + 1;
                });
              },
              icon: Icon(
                index < _impressionScore ? Icons.star : Icons.star_border,
                color: const Color(0xFFFFB300),
                size: 28,
              ),
            );
          }),
        ),
        Center(
          child: Text(
            '$_impressionScore 分',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFFFB300),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final color = _isSuccess == true ? const Color(0xFF4CAF50) : const Color(0xFFFF7043);
    final isValid = _isFormValid();
    return FilledButton(
      onPressed: isValid ? _saveRecord : null,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        '保存记录',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isValid ? Colors.white : Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
