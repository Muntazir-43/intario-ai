import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/flow_header.dart';
import 'package:intario_ai/widgets/gradient_button.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/models/wizard_state.dart';

class HintScreen extends ConsumerStatefulWidget {
  const HintScreen({super.key});

  @override
  ConsumerState<HintScreen> createState() => _HintScreenState();
}

class _HintScreenState extends ConsumerState<HintScreen> {
  late final TextEditingController _hintCtrl;

  static const _bathroomHints = [
    'with freestanding bathtub and brass fixtures',
    'with marble tiles and soft warm lighting',
    'with glass shower enclosure and modern vanity',
    'with spa-like ambiance and neutral tones',
    'with wooden accents and natural stone textures',
  ];

  static const _kitchenHints = [
    'with open shelving and matte black fixtures',
    'with marble countertops and warm pendant lighting',
    'with farmhouse sink and shaker-style cabinets',
    'with island seating and minimalist hardware',
    'with two-tone cabinets and brass accents',
  ];

  @override
  void initState() {
    super.initState();
    final initialHint = ref.read(wizardProvider).styleHint ?? '';
    _hintCtrl = TextEditingController(text: initialHint);
    _hintCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    ref.read(wizardProvider.notifier).setHint(_hintCtrl.text);
  }

  @override
  void dispose() {
    _hintCtrl.dispose();
    super.dispose();
  }

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
    final isDark = AppTheme.isDark(context);
    final hints  = wizard.feature == FeatureType.bathroomRemodel
        ? _bathroomHints
        : _kitchenHints;

    return Scaffold(
      backgroundColor:            AppTheme.background(context),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          FlowHeader(
            title:       'Style Hint',
            currentStep: 3,
            totalSteps:  wizard.totalSteps,
            onBack:      () => context.pop(),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Style Details (Optional)',
                    style: TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w500,
                      color:      AppTheme.primary(context),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color:        AppTheme.card(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.border(context),
                      ),
                    ),
                    child: TextField(
                      controller: _hintCtrl,
                      maxLines:   3,
                      style: TextStyle(
                        fontSize: 14,
                        color:    AppTheme.textPrimary(context),
                        height:   1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. materials, fixtures, finishes, lighting...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color:    AppTheme.textSecondary(context),
                        ),
                        border:         InputBorder.none,
                        enabledBorder:  InputBorder.none,
                        focusedBorder:  InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical:   14,
                        ),
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add specific details to refine your design',
                    style: TextStyle(
                      fontSize: 12,
                      color:    AppTheme.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Suggestions',
                    style: TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w500,
                      color:      AppTheme.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...hints.map(
                        (hint) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          _hintCtrl.text = hint;
                          _hintCtrl.selection = TextSelection.fromPosition(
                            TextPosition(offset: hint.length),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical:   12,
                          ),
                          decoration: BoxDecoration(
                            color:        AppTheme.card(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.border(context),
                            ),
                          ),
                          child: Text(
                            hint,
                            style: TextStyle(
                              fontSize: 13,
                              color:    AppTheme.primary(context),
                              height:   1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.ctaScrimGradient(context),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: GradientButton(
              label:      'Continue',
              isDisabled: false,
              onTap:      _onContinue,
            ),
          ),
        ],
      ),
    );
  }
}
