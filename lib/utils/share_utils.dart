import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intario_ai/utils/enum_normalizer.dart';

class ShareUtils {
  static const String shareSubject = 'AI Interior Design by Intario AI';

  /// Generates a premium, high-variety share message based on design metadata.
  static String buildShareText({
    required String? feature,
    required Map<String, dynamic> metadata,
    String? seed,
  }) {
    final String cRoom = EnumNormalizer.formatDisplayValue('roomType', metadata['roomType'] as String?);
    final String cStyle = EnumNormalizer.formatDisplayValue('designStyle', metadata['designStyle'] as String?);
    final String cGarden = EnumNormalizer.formatDisplayValue('gardenStyle', metadata['gardenStyle'] as String?);
    final String cTheme = EnumNormalizer.formatDisplayValue('specialityDecor', metadata['specialityDecor'] as String?);

    // Use seed (image URL) for deterministic variety
    final int variationIndex = (seed?.hashCode ?? 0).abs();

    // ── Headline Logic ──
    String headline = '✨ AI Interior Transformation';
    final List<String> traits = ['Transformation', 'Concept', 'Makeover', 'Redesign', 'Visualization'];
    final String trait = traits[variationIndex % traits.length];

    if (feature != null) {
      switch (feature) {
        case 'roomRedesign':
          if (cStyle.isNotEmpty && cRoom.isNotEmpty) {
            headline = '✨ $cStyle $cRoom $trait';
          } else if (cRoom.isNotEmpty) {
            headline = '✨ $cRoom $trait';
          }
          break;
        case 'virtualStaging':
          headline = '🛋️ ${cRoom.isNotEmpty ? cRoom : "Room"} Staging Concept';
          break;
        case 'bathroomRemodel':
          headline = '✨ Luxury Bathroom Makeover';
          break;
        case 'kitchenRemodel':
          headline = '🍳 Modern Kitchen Transformation';
          break;
        case 'wallPaint':
        case 'cabinetColor':
          final target = feature == 'wallPaint' ? 'Wall' : 'Cabinet';
          headline = '🎨 $target Color Visualization';
          break;
        case 'frontYard':
        case 'backYard':
        case 'sideYard':
          if (cGarden.toLowerCase().contains('zen')) {
            headline = '🌿 Zen Garden Transformation';
          } else if (cGarden.isNotEmpty) {
            headline = '🌿 $cGarden Exterior Redesign';
          } else {
            headline = '🏡 Contemporary Exterior Transformation';
          }
          break;
        case 'seasonalDecor':
          headline = '🎄 ${cTheme.isNotEmpty ? cTheme : "Seasonal"} Interior Concept';
          break;
        case 'styleTransfer':
          headline = '✨ Artistic Style Transformation';
          break;
        default:
          headline = '✨ AI Design Concept';
      }
    }

    // ── Description Logic (Deterministic Rotating Variations) ──
    final List<String> descriptions = [
      'Reimagined through cinematic AI design visualization.',
      'A refined transformation concept for modern living.',
      'Crafted with premium AI-enhanced interior styling.',
      'Brought to life with intelligent design creativity.',
      'A sophisticated redesign concept for an elevated space.',
      'Professionally visualized using advanced AI design tools.',
      'A cinematic transformation reimagined into a luxurious space.',
    ];

    String description = descriptions[variationIndex % descriptions.length];

    return '$headline\n\n$description\n\nDesigned with Intario AI 🏡';
  }

  /// Shares the design. If [imageUrl] is provided, it attempts to download and share the image file.
  /// Falls back to text-only premium sharing if image download fails or URL is empty.
  static Future<void> shareDesign({
    required String? imageUrl,
    String? feature,
    Map<String, dynamic> metadata = const {},
  }) async {
    // Generate text with variety seed
    final text = buildShareText(
      feature: feature, 
      metadata: metadata, 
      seed: imageUrl
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      await Share.share(text, subject: shareSubject);
      return;
    }

    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Download the image to a temporary file for sharing
      await dio.download(
        imageUrl,
        filePath,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: text,
          subject: shareSubject,
        );
      } else {
        throw Exception('File not found after download');
      }
    } catch (e) {
      debugPrint('Premium Share Error: $e');
      // Fallback to text-only premium experience if image sharing fails
      await Share.share(text, subject: shareSubject);
    }
  }
}
