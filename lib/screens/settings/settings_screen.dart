import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/bottom_nav_bar.dart';
import 'package:intario_ai/providers/settings_provider.dart';
import 'package:intario_ai/utils/haptics.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showSnackBar(BuildContext context, String msg) {
    final isDark = AppTheme.isDark(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: isDark ? AppTheme.dSecondaryBg : AppTheme.lTextPrimary,
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    AppHaptics.selection();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackground(context),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary(context),
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppTheme.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppHaptics.lightTap();
              Navigator.pop(context, false);
            },
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary(context))),
          ),
          TextButton(
            onPressed: () {
              AppHaptics.mediumTap();
              Navigator.pop(context, true);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      _showSnackBar(context, 'Logged out');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary(context)
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Membership ──────────────────────────────────────────
                    _SectionLabel('Membership'),
                    const SizedBox(height: 8),
                    _SectionCard(
                      children: [
                        _ToggleItem(
                          icon: Icons.auto_awesome_rounded,
                          label: 'Intario Pro',
                          subtitle: 'Unlock all premium features',
                          value: settings.isPro,
                          onChanged: () {
                            AppHaptics.mediumTap();
                            notifier.setProStatus(!settings.isPro);
                          },
                          isPremium: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Preferences ──────────────────────────────────────────
                    _SectionLabel('Preferences'),
                    const SizedBox(height: 8),
                    _SectionCard(
                      children: [
                        _ToggleItem(
                          icon: Icons.notifications_outlined,
                          label: 'Push Notifications',
                          subtitle: 'Get alerts about your designs',
                          value: settings.pushNotifications,
                          onChanged: () {
                            AppHaptics.lightTap();
                            notifier.toggleNotifications();
                          },
                        ),
                        const _MenuDivider(),
                        _ToggleItem(
                          icon: Icons.dark_mode_outlined,
                          label: 'Dark Mode',
                          subtitle: 'Premium cinematic appearance',
                          value: settings.themeMode == ThemeMode.dark,
                          onChanged: () {
                            AppHaptics.lightTap();
                            notifier.setThemeMode(
                              settings.themeMode == ThemeMode.dark
                                  ? ThemeMode.light
                                  : ThemeMode.dark,
                            );
                          },
                        ),
                        const _MenuDivider(),
                        _ToggleItem(
                          icon: Icons.save_outlined,
                          label: 'Auto Save',
                          subtitle: 'Automatically save your work',
                          value: settings.autoSave,
                          onChanged: () {
                            AppHaptics.lightTap();
                            notifier.toggleAutoSave();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── About ─────────────────────────────────────────────────
                    _SectionLabel('About'),
                    const SizedBox(height: 8),
                    _SectionCard(
                      children: [
                        const _InfoItem(
                          icon: Icons.info_outline_rounded,
                          label: 'App Version',
                          value: '1.0.0',
                        ),
                        const _MenuDivider(),
                        _TapItem(
                          icon: Icons.shield_outlined,
                          label: 'Privacy Policy',
                          onTap: () {
                            AppHaptics.lightTap();
                          },
                        ),
                        const _MenuDivider(),
                        _TapItem(
                          icon: Icons.description_outlined,
                          label: 'Terms of Service',
                          onTap: () {
                            AppHaptics.lightTap();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Account ───────────────────────────────────────────────
                    _SectionLabel('Account'),
                    const SizedBox(height: 8),
                    _SectionCard(
                      children: [
                        _LogoutItem(
                          onTap: () => _confirmLogout(context),
                        ),
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

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

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

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final VoidCallback onChanged;
  final bool isPremium;

  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = AppTheme.primary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPremium
                  ? primary.withValues(alpha: 0.1)
                  : (isDark ? AppTheme.dGlass : AppTheme.lDivider),
              borderRadius: AppTheme.iconRadius,
              border: isDark && !isPremium ? Border.all(color: AppTheme.dBorderSoft) : null,
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient135(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('PRO',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (_) => onChanged(),
            activeTrackColor: primary.withValues(alpha: 0.5),
            activeColor: primary,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Padding(
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
          Text(label,
              style: TextStyle(fontSize: 15, color: AppTheme.textPrimary(context))),
          const Spacer(),
          Text(value,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context))),
        ],
      ),
    );
  }
}

class _TapItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TapItem({required this.icon, required this.label, required this.onTap});
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
            Text(label,
                style: TextStyle(fontSize: 15, color: AppTheme.textPrimary(context))),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary(context), size: 18),
          ],
        ),
      ),
    );
  }
}

class _LogoutItem extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutItem({required this.onTap});
  @override
  Widget build(BuildContext context) {
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
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: AppTheme.iconRadius),
              child: const Icon(Icons.logout_rounded,
                  color: AppTheme.error, size: 20),
            ),
            const SizedBox(width: 14),
            const Text('Logout',
                style: TextStyle(fontSize: 15, color: AppTheme.error)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary(context),
          letterSpacing: 0.5),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();
  @override
  Widget build(BuildContext context) {
    return Divider(
        indent: 68,
        height: 1,
        thickness: 0.5,
        color: AppTheme.divider(context));
  }
}
