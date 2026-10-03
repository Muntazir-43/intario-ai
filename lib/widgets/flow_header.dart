import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/utils/haptics.dart';

class FlowHeader extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  const FlowHeader({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalSteps > 0 ? (currentStep / totalSteps).clamp(0.0, 1.0) : 0.0;
    final isDark = AppTheme.isDark(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top progress bar
        LayoutBuilder(
          builder: (_, constraints) {
            return Stack(
              children: [
                Container(
                  height: 4,
                  color: isDark ? AppTheme.dDivider : AppTheme.lDivider,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  height: 4,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient(context),
                  ),
                ),
              ],
            );
          },
        ),

        // Header
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                color: AppTheme.background(context).withOpacity(isDark ? 0.8 : 0.92),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () {
                              AppHaptics.lightTap();
                              onBack();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.dGlass : AppTheme.lDivider,
                                borderRadius: AppTheme.iconRadius,
                                border: isDark ? Border.all(color: AppTheme.dBorderSoft) : null,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppTheme.primary(context),
                                size: 18,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: AppTheme.cardTitle(context),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Step $currentStep of $totalSteps',
                                  style: AppTheme.caption(context),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // Spacer for center alignment
                          const SizedBox(width: 52),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppTheme.border(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
