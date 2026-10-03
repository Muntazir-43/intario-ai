import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/constants/color_schemes.dart';
import 'package:intario_ai/constants/themes.dart';
import 'package:intario_ai/models/wizard_state.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/utils/haptics.dart';
import 'package:intario_ai/widgets/gradient_button.dart';

class ConfirmScreen extends ConsumerWidget {
  const ConfirmScreen({super.key});

  void _onGenerate(BuildContext context) {
    context.push('/flow/generating');
  }

  List<Widget> _buildRows(BuildContext context, WizardState wizard) {
    final rows = <Widget>[];

    void add(
        String label,
        String? value,
        IconData icon,
        String editRoute, {
          Color? iconColor,
        }) {
      if (value == null || value.isEmpty) return;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SelectionRow(
            label: label,
            value: value,
            icon: icon,
            iconColor: iconColor,
            editRoute: editRoute,
          ),
        ),
      );
    }

    final f = wizard.feature;

    switch (f) {
      case FeatureType.seasonalDecor:
        add(
          'Theme',
          SeasonalThemes.label(wizard.specialityDecor ?? '') ??
              wizard.specialityDecor,
          Icons.auto_awesome_outlined,
          '/flow/theme',
        );

        add(
          'Room Type',
          wizard.roomType,
          Icons.chair_outlined,
          '/flow/room-type',
        );

        add(
          'Design Style',
          wizard.designStyle,
          Icons.palette_outlined,
          '/flow/style',
        );

        break;

      case FeatureType.roomRedesign:
      case FeatureType.virtualStaging:
        add(
          'Room Type',
          wizard.roomType,
          Icons.chair_outlined,
          '/flow/room-type',
        );

        add(
          'Design Style',
          wizard.designStyle,
          Icons.palette_outlined,
          '/flow/style',
        );

        add(
          'Color Scheme',
          ColorSchemes.label(wizard.colorScheme ?? '') ??
              wizard.colorScheme,
          Icons.color_lens_outlined,
          '/flow/color-scheme',
        );

        break;

      case FeatureType.styleTransfer:
        add(
          'Room Type',
          wizard.roomType,
          Icons.chair_outlined,
          '/flow/room-type',
        );

        break;

      case FeatureType.customPrompt:
        final truncated = (wizard.prompt ?? '').length > 60
            ? '${wizard.prompt!.substring(0, 60)}...'
            : wizard.prompt;

        add(
          'Prompt',
          truncated,
          Icons.edit_note_outlined,
          '/flow/prompt',
        );

        break;

      case FeatureType.bathroomRemodel:
      case FeatureType.kitchenRemodel:
        add(
          'Design Style',
          wizard.designStyle,
          Icons.palette_outlined,
          '/flow/style',
        );

        add(
          'Style Hint',
          wizard.styleHint,
          Icons.lightbulb_outline_rounded,
          '/flow/hint',
        );

        break;

      case FeatureType.wallPaint:
      case FeatureType.cabinetColor:
        add(
          f == FeatureType.wallPaint
              ? 'Wall Color'
              : 'Cabinet Color',
          wizard.selectedHexColor,
          Icons.circle,
          '/flow/color-picker',
        );

        break;

      case FeatureType.frontYard:
      case FeatureType.backYard:
      case FeatureType.sideYard:
        add(
          'Garden Style',
          wizard.gardenStyle,
          Icons.park_outlined,
          '/flow/garden-style',
        );

        break;

      default:
        add(
          'Room Type',
          wizard.roomType,
          Icons.chair_outlined,
          '/flow/room-type',
        );

        add(
          'Design Style',
          wizard.designStyle,
          Icons.palette_outlined,
          '/flow/style',
        );

        break;
    }

    return rows;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizard = ref.watch(wizardProvider);
    final isDark = AppTheme.isDark(context);
    final feature = wizard.feature;
    final isStyleTransfer = feature == FeatureType.styleTransfer;

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: Column(
        children: [
          // ───────────────── Header ─────────────────

          SafeArea(
            bottom: false,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.background(context).withOpacity(isDark ? 0.85 : 0.92),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.border(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        AppHaptics.lightTap();
                        context.pop();
                      },
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

                    Text(
                      'Confirm Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ───────────────── Content ─────────────────

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ───────────────── Main Preview ─────────────────

                  if (!isStyleTransfer)
                    _InstantPreview(
                      url: wizard.originalImageUrl,
                      localPath: wizard.localInputPath,
                    ),

                  // ───────────────── Style Transfer ─────────────────

                  if (isStyleTransfer) ...[
                    _Label('Your Room'),

                    _InstantPreview(
                      url: wizard.originalImageUrl,
                      localPath: wizard.localInputPath,
                      height: 140,
                    ),

                    const SizedBox(height: 12),

                    _Label('Inspiration Image'),

                    _InstantPreview(
                      url: wizard.inspirationImageUrl,
                      localPath: wizard.localInspirationPath,
                      height: 140,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ───────────────── Selection Rows ─────────────────

                  ..._buildRows(context, wizard),

                  const SizedBox(height: 6),

                  // ───────────────── AI Box ─────────────────

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primary(context).withValues(alpha: isDark ? 0.05 : 0.04),
                          AppTheme.accent(context).withValues(alpha: isDark ? 0.05 : 0.04),
                        ],
                      ),
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(
                        color: AppTheme.primary(context).withValues(alpha: isDark ? 0.15 : 0.10),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '✨',
                          style: TextStyle(fontSize: 24),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Generation',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Our AI will create your design based on your selections. This usually takes 30–60 seconds.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary(context),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ───────────────── CTA ─────────────────

          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.ctaScrimGradient(context),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: GradientButton(
              label: 'Generate Design',
              onTap: () => _onGenerate(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INSTANT PREVIEW
// ─────────────────────────────────────────────────────────────

class _InstantPreview extends StatefulWidget {
  final String? url;
  final String? localPath;
  final double height;

  const _InstantPreview({
    this.url,
    this.localPath,
    this.height = 200,
  });

  @override
  State<_InstantPreview> createState() => _InstantPreviewState();
}

class _InstantPreviewState extends State<_InstantPreview> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.url != null && widget.url!.isNotEmpty) {
        precacheImage(
          CachedNetworkImageProvider(widget.url!),
          context,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget image;
    final isDark = AppTheme.isDark(context);

    // ───────────────── Local File ─────────────────

    if (widget.localPath != null) {
      final file = File(widget.localPath!);

      if (file.existsSync()) {
        image = Image.file(
          file,
          fit: BoxFit.cover,
          cacheWidth: 1024,
          filterQuality: FilterQuality.medium,
        );
      } else {
        image = _placeholder();
      }
    }

    // ───────────────── Network ─────────────────

    else if (widget.url != null && widget.url!.isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: widget.url!,
        fit: BoxFit.cover,
        memCacheWidth: 1024,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) {
          return Container(
            color: isDark ? AppTheme.dGlass : AppTheme.lDivider,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: AppTheme.textSecondary(context),
              size: 32,
            ),
          );
        },
      );
    }

    // ───────────────── Empty ─────────────────

    else {
      image = _placeholder();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardRadius,
        border: Border.all(
          color: AppTheme.borderStrong(context),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: SizedBox(
          width: double.infinity,
          height: widget.height,
          child: image,
        ),
      ),
    );
  }

  Widget _placeholder() {
    final isDark = AppTheme.isDark(context);
    final baseColor = isDark ? AppTheme.dGlass : AppTheme.lDivider;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withValues(alpha: isDark ? 0.02 : 0.65),
            baseColor,
            baseColor.withValues(alpha: isDark ? 0.02 : 0.65),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LABEL
// ─────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary(context),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SELECTION ROW
// ─────────────────────────────────────────────────────────────

class _SelectionRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String editRoute;
  final Color? iconColor;

  const _SelectionRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.editRoute,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = AppTheme.primary(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: AppTheme.cardRadius,
        border: Border.all(
          color: AppTheme.border(context),
        ),
        boxShadow: AppTheme.shadowLG(context),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: isDark ? 0.12 : 0.15),
                  AppTheme.accent(context).withValues(alpha: isDark ? 0.12 : 0.15),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: primary.withValues(alpha: isDark ? 0.20 : 0.20),
              ),
            ),
            child: Icon(
              icon,
              color: iconColor ?? primary,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(context),
                  ),
                ),

                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withValues(alpha: isDark ? 0.08 : 0.10),
                        AppTheme.accent(context).withValues(alpha: isDark ? 0.08 : 0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: primary.withValues(alpha: isDark ? 0.15 : 0.20),
                    ),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              AppHaptics.lightTap();

              context.push(
                editRoute,
                extra: {'fromConfirm': true},
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.dGlass : AppTheme.lDivider,
                borderRadius: AppTheme.iconRadius,
                border: isDark ? Border.all(color: AppTheme.dBorderSoft) : null,
              ),
              child: Icon(
                Icons.edit_outlined,
                color: AppTheme.textSecondary(context),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
