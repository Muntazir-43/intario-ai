import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/flow_header.dart';
import 'package:intario_ai/widgets/gradient_button.dart';
import 'package:intario_ai/widgets/selection_card.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/constants/themes.dart';

class ThemeScreen extends ConsumerStatefulWidget {
  const ThemeScreen({super.key});

  @override
  ConsumerState<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends ConsumerState<ThemeScreen> {
  void _onContinue() {
    ref.read(wizardProvider.notifier).setStep(3);

    final fromConfirm =
        (GoRouterState.of(context).extra as Map?)?['fromConfirm'] ?? false;
    if (fromConfirm) {
      context.pop();
    } else {
      context.push('/flow/room-type');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wizard = ref.watch(wizardProvider);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: Column(
        children: [
          FlowHeader(
            title: 'Select Theme',
            currentStep: 2,
            totalSteps:  wizard.totalSteps,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 15, 24, 120),
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: SeasonalThemes.all.length,
                itemBuilder: (_, i) {
                  final item = SeasonalThemes.all[i];
                  final isSelected =
                      SeasonalThemes.apiValue(item['label']!) ==
                          wizard.specialityDecor;
                  return SelectionCard(
                    label: item['label']!,
                    emoji: item['emoji']!,
                    isSelected: isSelected,
                    onTap: () {
                      ref
                          .read(wizardProvider.notifier)
                          .setSpecialityDecor(item['label']!);
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.ctaScrimGradient(context),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: GradientButton(
              label: 'Continue',
              isDisabled: wizard.specialityDecor == null,
              onTap: _onContinue,
            ),
          ),
        ],
      ),
    );
  }
}
