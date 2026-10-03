import 'package:flutter/material.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/gradient_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;
  final String?  actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon in gradient circle
            Container(
              width:  80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient135(context),
                shape:    BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary(context).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style:     AppTheme.sectionHead(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style:     AppTheme.bodySmall(context),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              GradientButton(
                label: actionLabel!,
                onTap: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
