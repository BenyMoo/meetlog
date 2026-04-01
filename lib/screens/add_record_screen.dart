import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  String _selectedPlatform = '微信';
  int _impressionScore = 3;
  String? _selectedFailReason;

  final List<String> _platforms = ['微信', '电话', '小红书', 'Instagram'];
  final List<String> _failReasons = ['太紧张', '开场白生硬', '对方有伴侣', '直接被拒', '其他'];

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
      _selectedPlatform = '微信';
      _impressionScore = 3;
      _selectedFailReason = null;
    });
    _animationController.reset();
  }

  Future<void> _saveRecord() async {
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入地点')),
      );
      return;
    }

    final dbService = ref.read(localDbServiceProvider);

    if (_isSuccess == true) {
      if (_nameController.text.isEmpty || _accountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请填写称呼和账号')),
        );
        return;
      }

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
        recordId: 0,
      );

      await dbService.addRecord(record, contact: contact);
    } else {
      if (_selectedFailReason == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择失败原因')),
        );
        return;
      }

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
        ),
      );
      _resetForm();
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
              Row(
                children: [
                  IconButton(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isSuccess == true ? '成功记录' : '失败复盘',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
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
        const SizedBox(height: 24),
        Text(
          '失败原因',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
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
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFFF7043) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFF7043)
                    : Colors.grey[300]!,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          '即时复盘',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reflectionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '这次哪里做的不够好？下次怎么改进？',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFFF7043), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 32),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPlatform,
              isExpanded: true,
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
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
                size: 40,
              ),
            );
          }),
        ),
        Center(
          child: Text(
            '$_impressionScore 分',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    return FilledButton(
      onPressed: _saveRecord,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text(
        '保存记录',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
