import 'package:intario_ai/constants/room_types.dart';
import 'package:intario_ai/constants/design_styles.dart';
import 'package:intario_ai/constants/garden_styles.dart';
import 'package:intario_ai/constants/color_schemes.dart';
import 'package:intario_ai/constants/themes.dart';

class EnumNormalizer {
  EnumNormalizer._();

  // ── Display Label Resolution ────────────────────────────────────────────────

  /// Converts an API value back to a user-friendly label.
  /// Used in Confirm and Preview screens for consistent premium UX.
  static String formatDisplayValue(String key, String? value) {
    if (value == null || value.isEmpty) return '';

    switch (key) {
      case 'roomType':
        return RoomTypes.label(value) ?? bestEffortLabel(value);
      case 'designStyle':
        return DesignStyles.label(value) ?? bestEffortLabel(value);
      case 'colorScheme':
        return ColorSchemes.label(value) ?? value;
      case 'specialityDecor':
        return SeasonalThemes.label(value) ?? value;
      case 'gardenStyle':
        return GardenStyles.label(value) ?? value;
      case 'hexColor':
        return value.toUpperCase();
      case 'prompt':
      case 'styleHint':
        return value; // Passthrough natural language fields
      default:
        return bestEffortLabel(value);
    }
  }

  /// Normalizes machine strings (camelCase, PascalCase, ALL_CAPS, underscores)
  /// into premium display text.
  static String bestEffortLabel(String? text) {
    if (text == null || text.isEmpty) return '';

    // Try Seasonal Theme lookup as a smart fallback
    final seasonalLabel = SeasonalThemes.label(text);
    if (seasonalLabel != null) return seasonalLabel;

    // 1. Insert spaces before capital letters (camelCase/PascalCase)
    // 2. Replace underscores with spaces
    String result = text
        .replaceAllMapped(
          RegExp(r'(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])'),
          (Match m) => ' ',
        )
        .replaceAll('_', ' ');

    // 3. Trim and capitalize each word
    return result.trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // ── Room Type ────────────────────────────────────────────────────────────────
  /// Converts UI label → Decor8 room_type enum
  /// e.g. "Living Room" → "livingroom"
  static String normalizeRoomType(String label) {
    final value = RoomTypes.apiValue(label);
    assert(value != null, 'EnumNormalizer: unknown room type "$label"');
    return value ?? label.toLowerCase().replaceAll(' ', '');
  }

  // ── Design Style ─────────────────────────────────────────────────────────────
  /// Converts UI label → Decor8 design_style enum
  /// e.g. "Mid-Century Modern" → "midcenturymodern"
  static String normalizeStyle(String label) {
    final value = DesignStyles.apiValue(label);
    assert(value != null, 'EnumNormalizer: unknown design style "$label"');
    return value ?? label.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
  }

  // ── Color Scheme ─────────────────────────────────────────────────────────────
  /// Converts UI label → Decor8 color_scheme enum
  /// e.g. "Blue, Beige" → "COLOR_SCHEME_8"
  static String normalizeColorScheme(String label) {
    final value = ColorSchemes.apiValue(label);
    assert(value != null, 'EnumNormalizer: unknown color scheme "$label"');
    return value ?? label;
  }

  // ── Speciality Decor ─────────────────────────────────────────────────────────
  /// Converts UI label → Decor8 speciality_decor enum
  /// e.g. "Christmas" → "SPECIALITY_DECOR_2"
  /// e.g. "Fall Season" → "SPECIALITY_DECOR_4"
  static String normalizeSpecialityDecor(String label) {
    final value = SeasonalThemes.apiValue(label);
    assert(value != null, 'EnumNormalizer: unknown speciality decor "$label"');
    return value ?? label;
  }

  // ── Garden Style ─────────────────────────────────────────────────────────────
  /// Converts UI label → Decor8 garden_style string (Title Case with spaces)
  /// e.g. "Japanese Zen Garden" → "Japanese Zen Garden"
  /// API values match UI labels for garden styles — passthrough with validation.
  static String normalizeGardenStyle(String label) {
    final value = GardenStyles.apiValue(label);
    assert(value != null, 'EnumNormalizer: unknown garden style "$label"');
    return value ?? label;
  }

  // ── Yard Type ────────────────────────────────────────────────────────────────
  /// Hardcoded yard_type values — set by gateway, not user selection.
  /// "Front Yard" | "Backyard" | "Side Yard"
  /// Note: "Backyard" is one word per Decor8 API spec.
  static const String frontYard = 'Front Yard';
  static const String backYard  = 'Backyard';
  static const String sideYard  = 'Side Yard';

  // ── Hex Color ────────────────────────────────────────────────────────────────
  /// Ensures hex is uppercase with # prefix: "#a5b6d4" → "#A5B6D4"
  static String normalizeHexColor(String hex) {
    final trimmed = hex.trim();
    final withHash = trimmed.startsWith('#') ? trimmed : '#$trimmed';
    return withHash.toUpperCase();
  }

  // ── Batch builder helpers ─────────────────────────────────────────────────────
  /// Builds the complete Decor8 request body for /generate_designs_for_room
  /// Pass only the fields relevant to the feature; null fields are omitted.
  static Map<String, dynamic> buildRoomDesignBody({
    required String inputImageUrl,
    String? roomType,
    String? designStyle,
    String? colorScheme,
    String? prompt,
    String? designStyleImageUrl,
    String? specialityDecor,
  }) {
    return {
      'input_image_url': inputImageUrl,
      if (roomType           != null) 'room_type':               roomType,
      if (designStyle        != null) 'design_style':            designStyle,
      if (colorScheme        != null) 'color_scheme':            colorScheme,
      if (prompt             != null) 'prompt':                  prompt,
      if (designStyleImageUrl!= null) 'design_style_image_url':  designStyleImageUrl,
      if (specialityDecor    != null) 'speciality_decor':        specialityDecor,
      'num_images':  1,
      'scale_factor': 2,
    };
  }

  /// Builds the body for /remodel_bathroom or /remodel_kitchen
  static Map<String, dynamic> buildRemodelBody({
    required String inputImageUrl,
    required String designStyle,
    String? styleHint,
  }) {
    return {
      'input_image_url':            inputImageUrl,
      'design_style':               designStyle,
      if (styleHint != null && styleHint.trim().isNotEmpty)
        'style_augmentation_prompt': styleHint.trim(),
      'num_images':   1,
      'scale_factor': 2,
    };
  }

  /// Builds the body for /change_wall_color
  static Map<String, dynamic> buildWallColorBody({
    required String inputImageUrl,
    required String hexColor,
    String? roomType,
  }) {
    final normalizedHex = normalizeHexColor(hexColor);
    return {
      'input_image_url':     inputImageUrl,
      'wall_color_hex_code': normalizedHex,
      'color_hex':            normalizedHex,
      'room_type':            roomType ?? 'livingroom',
    };
  }

  /// Builds the body for /change_kitchen_cabinets_color
  static Map<String, dynamic> buildCabinetColorBody({
    required String inputImageUrl,
    required String hexColor,
  }) {
    final normalizedHex = normalizeHexColor(hexColor);
    return {
      'input_image_url':        inputImageUrl,
      'cabinet_color_hex_code': normalizedHex,
      'color_hex':               normalizedHex,
    };
  }

  /// Builds the body for /generate_landscaping_designs
  static Map<String, dynamic> buildLandscapingBody({
    required String inputImageUrl,
    required String yardType,
    required String gardenStyle,
  }) {
    return {
      'input_image_url': inputImageUrl,
      'yard_type':       yardType,
      'garden_style':    gardenStyle,
      'num_images':      1,
    };
  }
}
