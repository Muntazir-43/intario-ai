import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intario_ai/models/wizard_state.dart';
import 'package:intario_ai/models/project_model.dart';
import 'package:intario_ai/services/decor8_service.dart';
import 'package:intario_ai/services/gallery_service.dart';
import 'package:intario_ai/services/firebase_storage_service.dart';
import 'package:intario_ai/utils/enum_normalizer.dart';
import 'package:intario_ai/providers/projects_provider.dart';
import 'package:intario_ai/providers/settings_provider.dart';
import 'package:dio/dio.dart';

class WizardNotifier extends StateNotifier<WizardState> {
  final Ref _ref;
  final Decor8Service _decor8;
  final GalleryService _galleryService = GalleryService();
  final FirebaseStorageService _storage = FirebaseStorageService();

  WizardNotifier(this._ref)
      : _decor8 = Decor8Service(
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 90),
            ),
          ),
        ),
        super(const WizardState());

  // ── Load from Existing Project ─────────────────────────────────────────────
  void loadFromProject(ProjectModel project) {
    reset();

    // Attempt to parse feature string back to enum
    FeatureType? feature;
    try {
      feature = FeatureType.values.firstWhere((e) => e.name == project.feature);
    } catch (_) {}

    state = state.copyWith(
      feature: feature,
      originalImageUrl: project.originalImageUrl,
      inputImageUrl: project.originalImageUrl,
      designStyle: project.metadata['designStyle'],
      roomType: project.metadata['roomType'],
      colorScheme: project.metadata['colorScheme'],
      selectedHexColor: project.metadata['hexColor'],
      specialityDecor: project.metadata['specialityDecor'],
      gardenStyle: project.metadata['gardenStyle'],
      prompt: project.metadata['prompt'],
      styleHint: project.metadata['styleHint'],
      inspirationImageUrl: project.metadata['inspirationImageUrl'],
      totalSteps: feature != null ? _totalStepsFor(feature) : 4,
    );
  }

  // ── Feature ────────────────────────────────────────────────────────────────
  void setFeature(FeatureType feature) {
    reset();
    final steps = _totalStepsFor(feature);
    state = state.copyWith(
      feature: feature,
      totalSteps: steps,
    );
  }

  // ── Images ─────────────────────────────────────────────────────────────────
  void setLocalInputPath(String path) {
    state = state.copyWith(localInputPath: path);
  }

  void setLocalInspirationPath(String path) {
    state = state.copyWith(localInspirationPath: path);
  }

  void setImage(String cdnUrl, {String? localPath}) {
    if (state.originalImageUrl == null) {
      state = state.copyWith(
        inputImageUrl: cdnUrl,
        originalImageUrl: cdnUrl,
        localInputPath: localPath,
      );
    } else {
      state = state.copyWith(inputImageUrl: cdnUrl);
    }
  }

  void setInspirationImage(String cdnUrl, {String? localPath}) {
    state = state.copyWith(
      inspirationImageUrl: cdnUrl,
      localInspirationPath: localPath,
    );
  }

  void setRoomType(String label) {
    state = state.copyWith(roomType: EnumNormalizer.normalizeRoomType(label));
  }

  void setStyle(String label) {
    state = state.copyWith(designStyle: EnumNormalizer.normalizeStyle(label));
  }

  void setColorScheme(String label) {
    state = state.copyWith(colorScheme: EnumNormalizer.normalizeColorScheme(label));
  }

  void setSpecialityDecor(String label) {
    state = state.copyWith(specialityDecor: EnumNormalizer.normalizeSpecialityDecor(label));
  }

  void setGardenStyle(String label) {
    state = state.copyWith(gardenStyle: EnumNormalizer.normalizeGardenStyle(label));
  }

  void setYardType(String literal) {
    state = state.copyWith(yardType: literal);
  }

  void setHexColor(String hex) {
    state = state.copyWith(selectedHexColor: EnumNormalizer.normalizeHexColor(hex));
  }

  void setPrompt(String text) {
    state = state.copyWith(prompt: text);
  }

  void setHint(String text) {
    state = state.copyWith(styleHint: text);
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  // ── Generate ───────────────────────────────────────────────────────────────
  Future<void> generate() async {
    if (state.feature == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 1. Check if we need to upload the input image
      if (state.inputImageUrl == null && state.localInputPath != null) {
        final url = await _storage.uploadImage(File(state.localInputPath!));
        state = state.copyWith(
          inputImageUrl: url,
          originalImageUrl: url,
        );
      }

      // 2. Check if we need to upload inspiration image (for style transfer)
      if (state.feature == FeatureType.styleTransfer &&
          state.inspirationImageUrl == null &&
          state.localInspirationPath != null) {
        final url = await _storage.uploadImage(File(state.localInspirationPath!));
        state = state.copyWith(inspirationImageUrl: url);
      }

      if (state.inputImageUrl == null) {
        throw Exception('Input image is missing.');
      }

      // 3. Dispatch to AI service
      final result = await _buildAndDispatch();

      state = state.copyWith(
        isLoading: false,
        generatedImageUrl: result,
      );

      // Save record to local list
      await _saveRecordToHistory(result);

      // Auto download to Gallery if enabled
      final autoSave = _ref.read(settingsProvider).autoSave;
      if (autoSave) {
        try {
          await _galleryService.saveNetworkImage(result);
        } catch (e) {
          print('Auto-save to gallery failed: $e');
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is Exception ? _messageFrom(e) : 'Generation failed.',
      );
    }
  }

  // ── Reset ──────────────────────────────────────────────────────────────────
  void reset() {
    state = const WizardState();
  }

  // ── Private helpers ────────────────────────────────────────────────────────
  Future<String> _buildAndDispatch() {
    final f = state.feature!;
    switch (f) {
      case FeatureType.roomRedesign:
      case FeatureType.virtualStaging:
        return _decor8.generateImage(
          endpoint: '/generate_designs_for_room',
          body: EnumNormalizer.buildRoomDesignBody(
            inputImageUrl: state.inputImageUrl!,
            roomType: state.roomType,
            designStyle: state.designStyle,
            colorScheme: state.colorScheme,
          ),
        );
      case FeatureType.styleTransfer:
        return _decor8.generateImage(
          endpoint: '/generate_designs_for_room',
          body: EnumNormalizer.buildRoomDesignBody(
            inputImageUrl: state.inputImageUrl!,
            roomType: state.roomType,
            designStyleImageUrl: state.inspirationImageUrl,
          ),
        );
      case FeatureType.customPrompt:
        return _decor8.generateImage(
          endpoint: '/generate_designs_for_room',
          body: EnumNormalizer.buildRoomDesignBody(
            inputImageUrl: state.inputImageUrl!,
            prompt: state.prompt,
          ),
        );
      case FeatureType.seasonalDecor:
        return _decor8.generateImage(
          endpoint: '/generate_designs_for_room',
          body: EnumNormalizer.buildRoomDesignBody(
            inputImageUrl: state.inputImageUrl!,
            specialityDecor: state.specialityDecor,
            roomType: state.roomType,
            designStyle: state.designStyle,
          ),
        );
      case FeatureType.bathroomRemodel:
        return _decor8.generateImage(
          endpoint: '/remodel_bathroom',
          body: EnumNormalizer.buildRemodelBody(
            inputImageUrl: state.inputImageUrl!,
            designStyle: state.designStyle ?? '',
            styleHint: state.styleHint,
          ),
        );
      case FeatureType.kitchenRemodel:
        return _decor8.generateImage(
          endpoint: '/remodel_kitchen',
          body: EnumNormalizer.buildRemodelBody(
            inputImageUrl: state.inputImageUrl!,
            designStyle: state.designStyle ?? '',
            styleHint: state.styleHint,
          ),
        );
      case FeatureType.wallPaint:
        return _decor8.generateImage(
          endpoint: '/change_wall_color',
          body: EnumNormalizer.buildWallColorBody(
            inputImageUrl: state.inputImageUrl!,
            hexColor: state.selectedHexColor ?? '#FFFFFF',
            roomType: state.roomType,
          ),
        );
      case FeatureType.cabinetColor:
        return _decor8.generateImage(
          endpoint: '/change_kitchen_cabinets_color',
          body: EnumNormalizer.buildCabinetColorBody(
            inputImageUrl: state.inputImageUrl!,
            hexColor: state.selectedHexColor ?? '#FFFFFF',
          ),
        );
      case FeatureType.frontYard:
      case FeatureType.backYard:
      case FeatureType.sideYard:
        return _decor8.generateImage(
          endpoint: '/generate_landscaping_designs',
          body: EnumNormalizer.buildLandscapingBody(
            inputImageUrl: state.inputImageUrl!,
            yardType: f == FeatureType.frontYard
                ? EnumNormalizer.frontYard
                : (f == FeatureType.backYard
                    ? EnumNormalizer.backYard
                    : EnumNormalizer.sideYard),
            gardenStyle: state.gardenStyle ?? '',
          ),
        );
    }
  }

  Future<void> _saveRecordToHistory(String generatedUrl) async {
    final project = ProjectModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleFor(state.feature!),
      feature: state.feature!.name,
      originalImageUrl: state.originalImageUrl!,
      generatedImageUrl: generatedUrl,
      metadata: _buildMetadata(),
      createdAt: DateTime.now(),
    );
    await _ref.read(projectsProvider.notifier).saveProject(project);
  }

  Map<String, dynamic> _buildMetadata() {
    return {
      if (state.designStyle != null) 'designStyle': state.designStyle,
      if (state.roomType != null) 'roomType': state.roomType,
      if (state.colorScheme != null) 'colorScheme': state.colorScheme,
      if (state.selectedHexColor != null) 'hexColor': state.selectedHexColor,
      if (state.specialityDecor != null) 'specialityDecor': state.specialityDecor,
      if (state.gardenStyle != null) 'gardenStyle': state.gardenStyle,
      if (state.prompt != null) 'prompt': state.prompt,
      if (state.styleHint != null) 'styleHint': state.styleHint,
      if (state.inspirationImageUrl != null)
        'inspirationImageUrl': state.inspirationImageUrl,
    };
  }

  String _titleFor(FeatureType feature) {
    switch (feature) {
      case FeatureType.roomRedesign:
        return 'Room Redesign';
      case FeatureType.virtualStaging:
        return 'Virtual Staging';
      case FeatureType.styleTransfer:
        return 'Style Transfer';
      case FeatureType.customPrompt:
        return 'Custom Design';
      case FeatureType.bathroomRemodel:
        return 'Bathroom Remodel';
      case FeatureType.kitchenRemodel:
        return 'Kitchen Remodel';
      case FeatureType.wallPaint:
        return 'Wall Paint';
      case FeatureType.cabinetColor:
        return 'Cabinet Color';
      case FeatureType.frontYard:
        return 'Front Yard';
      case FeatureType.backYard:
        return 'Back Yard';
      case FeatureType.sideYard:
        return 'Side Yard';
      case FeatureType.seasonalDecor:
        return 'Seasonal Decor';
    }
  }

  int _totalStepsFor(FeatureType feature) {
    switch (feature) {
      case FeatureType.wallPaint:
      case FeatureType.cabinetColor:
      case FeatureType.frontYard:
      case FeatureType.backYard:
      case FeatureType.sideYard:
      case FeatureType.customPrompt:
        return 2;
      case FeatureType.bathroomRemodel:
      case FeatureType.kitchenRemodel:
        return 3;
      case FeatureType.styleTransfer:
        return 3;
      case FeatureType.roomRedesign:
      case FeatureType.virtualStaging:
      case FeatureType.seasonalDecor:
        return 4;
    }
  }

  String _messageFrom(Exception e) =>
      e.toString().contains(':') ? e.toString().split(':').last.trim() : e.toString();
}

final wizardProvider =
    StateNotifierProvider<WizardNotifier, WizardState>((ref) => WizardNotifier(ref));
