import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intario_ai/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  static const _items = [
    _NavItem(icon: Icons.home_rounded,        label: 'Home',     route: '/'),
    _NavItem(icon: Icons.folder_copy_rounded, label: 'Projects', route: '/projects'),
    _NavItem(icon: Icons.person_rounded,      label: 'Profile',  route: '/profile'),
    _NavItem(icon: Icons.settings_rounded,    label: 'Settings', route: '/settings'),
  ];

  int _selectedIndex(String location) {
    for (int i = _items.length - 1; i >= 0; i--) {
      if (_items[i].route == '/'
          ? location == '/'
          : location.startsWith(_items[i].route)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final bottom   = MediaQuery.of(context).viewPadding.bottom;
    final index    = _selectedIndex(location);
    final isDark   = AppTheme.isDark(context);

    return Positioned(
      left: 24,
      right: 24,
      bottom: bottom + 16,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white.withOpacity(0.40),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : AppTheme.lPrimary.withOpacity(0.10),
                    width: 2,
                  ),
                  boxShadow: AppTheme.shadowLG(context),
                ),
                child: GNav(
                  selectedIndex: index,
                  onTabChange: (i) {
                    final route = _items[i].route;
                    final alreadyActive = route == '/'
                        ? location == '/'
                        : location.startsWith(route);

                    if (!alreadyActive) {
                      context.go(route);
                    }
                  },
                  gap: 8,
                  iconSize: 20,
                  tabBorderRadius: 999,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  duration: const Duration(milliseconds: 500),
                  color: AppTheme.textSecondary(context),
                  activeColor: Colors.white,
                  tabBackgroundColor: AppTheme.primary(context),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.0,
                  ),
                  tabs: _items.map((e) {
                    return GButton(
                      icon: e.icon,
                      text: e.label,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
