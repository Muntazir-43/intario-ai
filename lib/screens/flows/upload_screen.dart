import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/flow_header.dart';
import 'package:intario_ai/widgets/gradient_button.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/models/wizard_state.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _tempPickedFile;
  final _picker = ImagePicker();

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _tempPickedFile = File(picked.path);
      });
      ref.read(wizardProvider.notifier).setLocalInputPath(picked.path);
    }
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _tempPickedFile = File(picked.path);
      });
      ref.read(wizardProvider.notifier).setLocalInputPath(picked.path);
    }
  }

  void _continue() {
    if (_tempPickedFile == null && ref.read(wizardProvider).localInputPath == null) return;
    context.push(_nextRoute());
  }

  String _nextRoute() {
    final feature = ref.read(wizardProvider).feature;
    switch (feature) {
      case FeatureType.roomRedesign:
      case FeatureType.virtualStaging:
        return '/flow/room-type';
      case FeatureType.seasonalDecor:
        return '/flow/theme';
      case FeatureType.styleTransfer:
        return '/flow/style-transfer-inspiration';
      case FeatureType.customPrompt:
        return '/flow/prompt';
      case FeatureType.bathroomRemodel:
      case FeatureType.kitchenRemodel:
        return '/flow/style';
      case FeatureType.wallPaint:
      case FeatureType.cabinetColor:
        return '/flow/color-picker';
      case FeatureType.frontYard:
      case FeatureType.backYard:
      case FeatureType.sideYard:
        return '/flow/garden-style';
      default:
        return '/flow/room-type';
    }
  }

  @override
  Widget build(BuildContext context) {
    final wizard = ref.watch(wizardProvider);
    final isDark = AppTheme.isDark(context);

    File? displayFile = _tempPickedFile;
    if (displayFile == null && wizard.localInputPath != null) {
      final f = File(wizard.localInputPath!);
      if (f.existsSync()) {
        displayFile = f;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: Column(
        children: [
          FlowHeader(
            title: 'Upload Image',
            currentStep: 1,
            totalSteps: wizard.totalSteps,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (displayFile == null) ...[
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 48,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.dGlass : AppTheme.background(context),
                            borderRadius: AppTheme.cardRadius,
                            border: Border.all(
                              color: AppTheme.border(context),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.dElevated : AppTheme.lDivider,
                                  borderRadius: AppTheme.iconRadius,
                                ),
                                child: Icon(
                                  Icons.upload_rounded,
                                  color: AppTheme.primary(context),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Upload an Image',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap to select a photo from your gallery',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primary(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _SourceCard(
                              icon: Icons.camera_alt_outlined,
                              label: 'Camera',
                              onTap: _pickFromCamera,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SourceCard(
                              icon: Icons.photo_library_outlined,
                              label: 'Gallery',
                              onTap: _pickFromGallery,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: AppTheme.cardRadius,
                          border: Border.all(
                            color: AppTheme.borderStrong(context),
                            width: 1.2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: AppTheme.cardRadius,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: Image.file(
                              displayFile,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _pickFromGallery,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary(context),
                                  side: BorderSide(color: AppTheme.primary(context)),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: AppTheme.buttonRadius),
                                ),
                                child: const Text('Change Photo'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              label: 'Continue',
                              isDisabled: displayFile == null,
                              onTap: _continue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: AppTheme.cardRadius,
          border: Border.all(color: AppTheme.border(context)),
          boxShadow: AppTheme.shadowLG(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primary(context), size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary(context))),
          ],
        ),
      ),
    );
  }
}
