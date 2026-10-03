import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/gradient_button.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  static const _defaultMessage =
      'Something went wrong. Please try again.';

  @override
  Widget build(BuildContext context) {
    final message =
        GoRouterState.of(context).uri.queryParameters['message'] ??
            _defaultMessage;
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Error icon ──────────────────────────────────────────────
                Container(
                  width:  96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin:  Alignment.topLeft,
                      end:    Alignment.bottomRight,
                      colors: [
                        AppTheme.error.withValues(alpha: isDark ? 0.12 : 0.15),
                        AppTheme.error.withValues(alpha: isDark ? 0.04 : 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: isDark ? 0.15 : 0.20),
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppTheme.error,
                    size:  40,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Title ────────────────────────────────────────────────────
                Text(
                  'Generation Failed',
                  style: TextStyle(
                    fontSize:   22,
                    fontWeight: FontWeight.w500,
                    color:      AppTheme.textPrimary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color:    AppTheme.textSecondary(context),
                    height:   1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // ── Try again CTA ─────────────────────────────────────────────
                GradientButton(
                  label: 'Try Again',
                  onTap: () => context.go('/flow/confirm'),
                ),

                const SizedBox(height: 12),

                // ── Back to home ──────────────────────────────────────────────
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:        AppTheme.card(context),
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(
                        color: AppTheme.border(context),
                      ),
                      boxShadow: AppTheme.shadowLG(context),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical:   14,
                      ),
                      child: Center(
                        child: Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize:   15,
                            fontWeight: FontWeight.w500,
                            color:      AppTheme.textSecondary(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Expandable error detail ───────────────────────────────────
                if (message != _defaultMessage)
                  _ExpandableErrorDetail(message: message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Expandable error detail ───────────────────────────────────────────────────

class _ExpandableErrorDetail extends StatefulWidget {
  final String message;
  const _ExpandableErrorDetail({required this.message});

  @override
  State<_ExpandableErrorDetail> createState() => _ExpandableErrorDetailState();
}

class _ExpandableErrorDetailState extends State<_ExpandableErrorDetail> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.textSecondary(context),
                size:  14,
              ),
              const SizedBox(width: 6),
              Text(
                _expanded ? 'Hide details' : 'View error details',
                style: TextStyle(
                  fontSize: 12,
                  color:    AppTheme.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical:   12,
            ),
            decoration: BoxDecoration(
              color:        isDark ? AppTheme.dGlass : AppTheme.lDivider,
              borderRadius: BorderRadius.circular(16),
              border: isDark ? Border.all(color: AppTheme.dBorderSoft) : null,
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                fontSize:   12,
                color:      AppTheme.textSecondary(context),
                fontFamily: 'monospace',
                height:     1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
