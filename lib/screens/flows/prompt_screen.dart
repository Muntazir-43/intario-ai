import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/flow_header.dart';
import 'package:intario_ai/widgets/gradient_button.dart';
import 'package:intario_ai/providers/wizard_provider.dart';

class PromptScreen extends ConsumerStatefulWidget {
  const PromptScreen({super.key});

  @override
  ConsumerState<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends ConsumerState<PromptScreen> {
  late final TextEditingController _promptCtrl;

  static const _suggestions = [
    'A modern minimalist living room with neutral tones, wooden textures, soft natural lighting, and clean furniture lines',
    'A luxurious bedroom with marble finishes, warm ambient lighting, velvet textures, and gold accents',
  ];

  @override
  void initState() {
    super.initState();
    final initialPrompt = ref.read(wizardProvider).prompt ?? '';
    _promptCtrl = TextEditingController(text: initialPrompt);
    _promptCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    ref.read(wizardProvider.notifier).setPrompt(_promptCtrl.text);
    setState(() {}); // For char count and button state
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  bool _isValid(String prompt) {
    final len = prompt.trim().length;
    return len >= 20 && len <= 500;
  }

  void _onContinue() {
    if (!_isValid(_promptCtrl.text)) return;
    
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
    final currentText = _promptCtrl.text;
    final charCount = currentText.length;

    return Scaffold(
      backgroundColor:            AppTheme.background(context),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          FlowHeader(
            title:       'Describe Your Vision',
            currentStep: 2,
            totalSteps:  wizard.totalSteps,
            onBack:      () => context.pop(),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color:        AppTheme.card(context),
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(
                        color: AppTheme.border(context),
                      ),
                      boxShadow: AppTheme.shadowLG(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller:  _promptCtrl,
                          maxLines:    6,
                          maxLength:   500,
                          buildCounter: (_, {required currentLength,
                            required isFocused, maxLength}) => null,
                          style: TextStyle(
                            fontSize: 14,
                            color:    AppTheme.textPrimary(context),
                            height:   1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Describe your ideal space in detail\n'
                                '(style, colors, materials, lighting, furniture, mood...)',
                            hintStyle: TextStyle(
                              fontSize:    13,
                              color:       AppTheme.textSecondary(context),
                              fontStyle:   FontStyle.italic,
                              height:      1.5,
                            ),
                            border:         InputBorder.none,
                            enabledBorder:  InputBorder.none,
                            focusedBorder:  InputBorder.none,
                            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            fillColor: Colors.transparent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$charCount/500',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:    AppTheme.textSecondary(context),
                                ),
                              ),
                              if (charCount > 0 && charCount < 20)
                                const Text(
                                  ' (min 20)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:    AppTheme.error,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Smart Suggestions',
                    style: TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w500,
                      color:      AppTheme.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ..._suggestions.map(
                        (suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          _promptCtrl.text = suggestion;
                          _promptCtrl.selection = TextSelection.fromPosition(
                            TextPosition(offset: suggestion.length),
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
                            suggestion,
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

                  const SizedBox(height: 2),

                  Container(
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Be specific about colors, styles, furniture, and the mood you want to create. The more detail, the better the result!',
                            style: TextStyle(
                              fontSize: 13,
                              color:    AppTheme.textSecondary(context),
                              height:   1.5,
                            ),
                          ),
                        ),
                      ],
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
              isDisabled: !_isValid(currentText),
              onTap:      _onContinue,
            ),
          ),
        ],
      ),
    );
  }
}
