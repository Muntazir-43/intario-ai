import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/flow_header.dart';
import 'package:intario_ai/widgets/gradient_button.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/constants/color_schemes.dart';

class ColorSchemeScreen extends ConsumerStatefulWidget {
  const ColorSchemeScreen({super.key});

  @override
  ConsumerState<ColorSchemeScreen> createState() => _ColorSchemeScreenState();
}

class _ColorSchemeScreenState extends ConsumerState<ColorSchemeScreen> {
  void _onContinue() {
    final fromConfirm = (GoRouterState.of(context).extra as Map?)?['fromConfirm'] ?? false;
    if (fromConfirm) {
      context.pop();
    } else {
      context.push('/flow/confirm');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wizard = ref.watch(wizardProvider);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          FlowHeader(
            title:       'Select Color Scheme',
            currentStep: 4,
            totalSteps:  wizard.totalSteps,
            onBack:      () => context.pop(),
          ),

          // ── Scrollable content ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 15),
                    child: _SectionLabel('Recommended'),
                  ),
                  GridView.builder(
                    shrinkWrap:  true,
                    physics:     const NeverScrollableScrollPhysics(),
                    padding:     const EdgeInsets.only(bottom: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:   2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing:  12,
                      childAspectRatio: 1.6,
                    ),
                    itemCount:   ColorSchemes.recommendedItems.length,
                    itemBuilder: (_, i) {
                      final item = ColorSchemes.recommendedItems[i];
                      final isSelected = ColorSchemes.apiValue(item['label'] as String) == wizard.colorScheme;
                      return _ColorSchemeCard(
                        scheme:     item,
                        isSelected: isSelected,
                        onTap: () =>
                            ref.read(wizardProvider.notifier).setColorScheme(item['label'] as String),
                      );
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 15),
                    child: _SectionLabel('All Color Schemes'),
                  ),

                  GridView.builder(
                    shrinkWrap:  true,
                    physics:     const NeverScrollableScrollPhysics(),
                    padding:     const EdgeInsets.only(bottom: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:   2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing:  12,
                      childAspectRatio: 1.6,
                    ),
                    itemCount:   ColorSchemes.allItems.length,
                    itemBuilder: (_, i) {
                      final item = ColorSchemes.allItems[i];
                      final isSelected = ColorSchemes.apiValue(item['label'] as String) == wizard.colorScheme;
                      return _ColorSchemeCard(
                        scheme:     item,
                        isSelected: isSelected,
                        onTap: () =>
                            ref.read(wizardProvider.notifier).setColorScheme(item['label'] as String),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Fixed CTA ─────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.ctaScrimGradient(context),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: GradientButton(
              label:      'Continue',
              isDisabled: wizard.colorScheme == null,
              onTap:      _onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Color scheme card ─────────────────────────────────────────────────────────

class _ColorSchemeCard extends StatelessWidget {
  final Map<String, dynamic> scheme;
  final bool                 isSelected;
  final VoidCallback         onTap;

  const _ColorSchemeCard({
    required this.scheme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = (scheme['colors'] as List<dynamic>)
        .map((c) => Color(c as int))
        .toList();
    final isDark = AppTheme.isDark(context);
    final primary = AppTheme.primary(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:        AppTheme.card(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? primary
                : AppTheme.border(context),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
            ...AppTheme.shadowLG(context),
            BoxShadow(
              color:        primary.withValues(alpha: isDark ? 0.15 : 0.20),
              blurRadius:   12,
              spreadRadius: 1,
            ),
          ]
              : AppTheme.shadowMD(context),
        ),
        child: Column(
          children: [
            // ── Color strips ─────────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft:     Radius.circular(24),
                  topRight:    Radius.circular(24),
                ),
                child: Row(
                  children: colors
                      .map(
                        (c) => Expanded(
                      child: Container(color: c),
                    ),
                  )
                      .toList(),
                ),
              ),
            ),

            // ── Label ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                scheme['label'] as String,
                style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w500,
                  color:      AppTheme.textPrimary(context),
                ),
                textAlign: TextAlign.center,
                maxLines:  1,
                overflow:  TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize:      12,
        fontWeight:    FontWeight.w500,
        color:         AppTheme.textSecondary(context),
        letterSpacing: 0.5,
      ),
    );
  }
}
