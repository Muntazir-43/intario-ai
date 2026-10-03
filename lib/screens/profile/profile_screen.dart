import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/bottom_nav_bar.dart';
import 'package:intario_ai/providers/projects_provider.dart';
import 'package:intario_ai/providers/settings_provider.dart';
import 'package:intario_ai/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditingName = false;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      ref.read(profileProvider.notifier).setAvatar(picked.path);
    }
  }

  void _saveName() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      ref.read(profileProvider.notifier).setName(newName);
    }
    setState(() {
      _isEditingName = false;
    });
  }

  void _showProDialog() {
    final settings = ref.read(settingsProvider);
    final isPro = settings.isPro;
    final isDark = AppTheme.isDark(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackground(context),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isPro ? 'Pro Subscription' : 'Upgrade to Pro',
              style: TextStyle(color: AppTheme.textPrimary(context)),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary(context)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isPro) ...[
              Text(
                'Unlock all premium features including:',
                style: TextStyle(color: AppTheme.textSecondary(context)),
              ),
              const SizedBox(height: 12),
              const _FeatureBullet(text: 'High-resolution rendering'),
              const _FeatureBullet(text: 'Unlimited design generations'),
              const _FeatureBullet(text: 'Early access to AR features'),
            ] else
              Text(
                'You have active Pro status. All premium features are unlocked.',
                style: TextStyle(color: AppTheme.textSecondary(context)),
              ),
          ],
        ),
        actions: [
          if (!isPro)
            ElevatedButton(
              onPressed: () {
                ref.read(settingsProvider.notifier).setProStatus(true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Successfully upgraded to Pro! ✨'), 
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.primary(context),
                  ),
                );
              },
              child: const Text('Unlock Now'),
            )
          else
            TextButton(
              onPressed: () {
                ref.read(settingsProvider.notifier).setProStatus(false);
                Navigator.pop(context);
              },
              child: const Text('Cancel Subscription', style: TextStyle(color: AppTheme.error)),
            ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackground(context),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Change Password', style: TextStyle(color: AppTheme.textPrimary(context))),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary(context)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
              ),
              obscureText: true,
              style: TextStyle(color: AppTheme.textPrimary(context)),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
              ),
              obscureText: true,
              style: TextStyle(color: AppTheme.textPrimary(context)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password updated successfully'), 
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.primary(context),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Help Center',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.mail_outline, color: AppTheme.primary(context)),
              title: Text('Contact Support', style: TextStyle(color: AppTheme.textPrimary(context))),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.question_answer_outlined, color: AppTheme.primary(context)),
              title: Text('Frequently Asked Questions', style: TextStyle(color: AppTheme.textPrimary(context))),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'G';
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(profileProvider);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor:            AppTheme.background(context),
      extendBody:                 true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 160),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.card(context),
                        borderRadius: AppTheme.cardRadius,
                        border: Border.all(color: AppTheme.border(context)),
                        boxShadow: AppTheme.shadowLG(context),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _pickAvatar,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 36,
                                      backgroundImage: profile.avatarPath != null ? FileImage(File(profile.avatarPath!)) : null,
                                      backgroundColor: Colors.transparent,
                                      child: profile.avatarPath == null
                                          ? Container(
                                              width: 72, height: 72,
                                              decoration: BoxDecoration(
                                                gradient: AppTheme.primaryGradient135(context),
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(_getInitials(profile.name), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0, right: 0,
                                      child: Container(
                                        width: 22, height: 22,
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient135(context),
                                          shape: BoxShape.circle,
                                          border: isDark ? Border.all(color: AppTheme.dSecondaryBg, width: 1.5) : null,
                                        ),
                                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isEditingName)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _nameController,
                                              autofocus: true,
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context)),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                                fillColor: Colors.transparent,
                                              ),
                                              onSubmitted: (_) => _saveName(),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: _saveName,
                                            icon: Icon(Icons.check_rounded, color: AppTheme.primary(context), size: 20),
                                            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      )
                                    else
                                      GestureDetector(
                                        onTap: () {
                                          _nameController.text = profile.name;
                                          setState(() => _isEditingName = true);
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(profile.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context))),
                                            const SizedBox(width: 6),
                                            Icon(Icons.edit_outlined, color: AppTheme.primary(context), size: 14),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(profile.email, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 32, color: AppTheme.divider(context)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(value: projects.length.toString(), label: 'Designs'),
                              _VerticalDivider(),
                              _StatItem(value: projects.length.toString(), label: 'Saved'),
                              _VerticalDivider(),
                              _StatItem(
                                value: settings.isPro ? 'Pro' : 'Free',
                                label: 'Plan',
                                valueColor: settings.isPro ? AppTheme.accent(context) : AppTheme.primary(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel('Account'),
                    const SizedBox(height: 8),
                    _MenuCard(
                      children: [
                        _MenuItem(icon: Icons.lock_outline_rounded, label: 'Change Password', onTap: _showChangePasswordDialog),
                        const _MenuDivider(),
                        _MenuItem(icon: Icons.card_membership_rounded, label: 'Subscription', onTap: _showProDialog),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Support'),
                    const SizedBox(height: 8),
                    _MenuCard(
                      children: [
                        _MenuItem(icon: Icons.info_outline_rounded, label: 'About Intario AI', onTap: () {}),
                        const _MenuDivider(),
                        _MenuItem(icon: Icons.help_outline_rounded, label: 'Help Center', onTap: _showHelpCenter),
                        const _MenuDivider(),
                        _MenuItem(icon: Icons.description_outlined, label: 'Terms & Privacy', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const BottomNavBar(),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final String text;
  const _FeatureBullet({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: AppTheme.accent(context), size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context))),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  const _StatItem({required this.value, required this.label, this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: valueColor ?? AppTheme.textPrimary(context))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppTheme.divider(context));
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary(context), letterSpacing: 0.5));
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context), 
        borderRadius: AppTheme.cardRadius, 
        border: Border.all(color: AppTheme.border(context)), 
        boxShadow: AppTheme.shadowLG(context),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.cardRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.dGlass : AppTheme.lDivider, 
                borderRadius: AppTheme.iconRadius,
                border: isDark ? Border.all(color: AppTheme.dBorderSoft) : null,
              ), 
              child: Icon(icon, color: AppTheme.primary(context), size: 20),
            ),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textPrimary(context))),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary(context), size: 18),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();
  @override
  Widget build(BuildContext context) {
    return Divider(indent: 68, height: 1, thickness: 0.5, color: AppTheme.divider(context));
  }
}
