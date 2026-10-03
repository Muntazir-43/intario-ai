import 'package:flutter/material.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/utils/haptics.dart';

class SelectionCard extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? emoji;
  final String? imageUrl;

  const SelectionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.emoji,
    this.imageUrl,
  });

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        AppHaptics.selection();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: widget.isSelected ? 1.03 : 1.0,
        curve: Curves.easeOutBack,
        child: ScaleTransition(
          scale: _scale,
          child: widget.imageUrl != null
              ? _ImageCard(
                  label: widget.label,
                  imageUrl: widget.imageUrl!,
                  isSelected: widget.isSelected,
                )
              : _EmojiCard(
                  label: widget.label,
                  emoji: widget.emoji ?? '🏠',
                  isSelected: widget.isSelected,
                ),
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String label;
  final String imageUrl;
  final bool isSelected;

  const _ImageCard({
    required this.label,
    required this.imageUrl,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = AppTheme.primary(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardRadius,
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
                  color: primary.withValues(alpha: isDark ? 0.15 : 0.25),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                cacheWidth: 600,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.card(context),
                  child: Icon(Icons.image_outlined,
                      color: AppTheme.textSecondary(context)),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: isDark ? 0.75 : 0.65),
                    ],
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient135(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmojiCard extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;

  const _EmojiCard({
    required this.label,
    required this.emoji,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primary(context);
    final isDark = AppTheme.isDark(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? primary.withValues(alpha: isDark ? 0.12 : 0.06) 
            : AppTheme.card(context),
        borderRadius: AppTheme.cardRadius,
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
                  color: primary.withValues(alpha: isDark ? 0.20 : 0.30),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : AppTheme.shadowMD(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? primary : AppTheme.textPrimary(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
