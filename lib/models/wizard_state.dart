enum FeatureType {
  roomRedesign,
  virtualStaging,
  styleTransfer,
  customPrompt,
  bathroomRemodel,
  kitchenRemodel,
  wallPaint,
  cabinetColor,
  frontYard,
  backYard,
  sideYard,
  seasonalDecor,
}

class WizardState {
  final FeatureType? feature;

  // Images
  final String? localInputPath;        // Local file path for instant loading
  final String? localInspirationPath;  // Local file path for inspiration
  final String? inputImageUrl;         // CDN URL after Firebase upload
  final String? originalImageUrl;      // Immutable snapshot — never overwrite
  final String? inspirationImageUrl;   // Style Transfer second image

  // Room design params
  final String? roomType;            // Normalised API enum
  final String? designStyle;         // Normalised API enum
  final String? colorScheme;         // COLOR_SCHEME_N
  final String? specialityDecor;     // SPECIALITY_DECOR_N

  // Prompt-based
  final String? prompt;
  final String? styleHint;

  // Color
  final String? selectedHexColor;    // #RRGGBB

  // Exterior
  final String? gardenStyle;
  final String? yardType;

  // Step tracking
  final int currentStep;
  final int totalSteps;

  // Async state
  final bool isLoading;
  final bool isUploading;
  final String? generatedImageUrl;
  final String? error;

  const WizardState({
    this.feature,
    this.localInputPath,
    this.localInspirationPath,
    this.inputImageUrl,
    this.originalImageUrl,
    this.inspirationImageUrl,
    this.roomType,
    this.designStyle,
    this.colorScheme,
    this.specialityDecor,
    this.prompt,
    this.styleHint,
    this.selectedHexColor,
    this.gardenStyle,
    this.yardType,
    this.currentStep = 1,
    this.totalSteps  = 4,
    this.isLoading   = false,
    this.isUploading = false,
    this.generatedImageUrl,
    this.error,
  });

  WizardState copyWith({
    FeatureType? feature,
    String?  localInputPath,
    String?  localInspirationPath,
    String?  inputImageUrl,
    String?  originalImageUrl,
    String?  inspirationImageUrl,
    String?  roomType,
    String?  designStyle,
    String?  colorScheme,
    String?  specialityDecor,
    String?  prompt,
    String?  styleHint,
    String?  selectedHexColor,
    String?  gardenStyle,
    String?  yardType,
    int?     currentStep,
    int?     totalSteps,
    bool?    isLoading,
    bool?    isUploading,
    String?  generatedImageUrl,
    String?  error,
    // Explicit null-clearers
    bool clearError           = false,
    bool clearGeneratedImage  = false,
    bool clearInspiration     = false,
  }) {
    return WizardState(
      feature:              feature              ?? this.feature,
      localInputPath:       localInputPath       ?? this.localInputPath,
      localInspirationPath: localInspirationPath ?? this.localInspirationPath,
      inputImageUrl:        inputImageUrl        ?? this.inputImageUrl,
      originalImageUrl:     originalImageUrl     ?? this.originalImageUrl,
      inspirationImageUrl:  clearInspiration     ? null : (inspirationImageUrl ?? this.inspirationImageUrl),
      roomType:             roomType             ?? this.roomType,
      designStyle:          designStyle          ?? this.designStyle,
      colorScheme:          colorScheme          ?? this.colorScheme,
      specialityDecor:      specialityDecor      ?? this.specialityDecor,
      prompt:               prompt               ?? this.prompt,
      styleHint:            styleHint            ?? this.styleHint,
      selectedHexColor:     selectedHexColor     ?? this.selectedHexColor,
      gardenStyle:          gardenStyle          ?? this.gardenStyle,
      yardType:             yardType             ?? this.yardType,
      currentStep:          currentStep          ?? this.currentStep,
      totalSteps:           totalSteps           ?? this.totalSteps,
      isLoading:            isLoading            ?? this.isLoading,
      isUploading:          isUploading          ?? this.isUploading,
      generatedImageUrl:    clearGeneratedImage  ? null : (generatedImageUrl ?? this.generatedImageUrl),
      error:                clearError           ? null : (error             ?? this.error),
    );
  }

  /// Collects all non-null configuration data for saving/displaying.
  Map<String, dynamic> get metadata {
    return {
      if (designStyle     != null) 'designStyle':    designStyle,
      if (roomType        != null) 'roomType':       roomType,
      if (colorScheme     != null) 'colorScheme':    colorScheme,
      if (selectedHexColor!= null) 'hexColor':       selectedHexColor,
      if (specialityDecor != null) 'specialityDecor': specialityDecor,
      if (gardenStyle     != null) 'gardenStyle':    gardenStyle,
      if (prompt          != null) 'prompt':         prompt,
      if (styleHint       != null) 'styleHint':      styleHint,
      if (inspirationImageUrl != null)
        'inspirationImageUrl': inspirationImageUrl,
    };
  }

  bool get canProceed {
    switch (feature) {
      case FeatureType.wallPaint:
      case FeatureType.cabinetColor:
        return inputImageUrl != null && selectedHexColor != null;
      case FeatureType.styleTransfer:
        return inputImageUrl != null && inspirationImageUrl != null;
      case FeatureType.customPrompt:
        return inputImageUrl != null &&
            prompt != null &&
            prompt!.trim().length >= 20;
      case FeatureType.frontYard:
      case FeatureType.backYard:
      case FeatureType.sideYard:
        return inputImageUrl != null && gardenStyle != null;
      default:
        return inputImageUrl != null;
    }
  }

  WizardState get initial => const WizardState();
}
