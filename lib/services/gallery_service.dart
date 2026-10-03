import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart';

class GalleryService {
  final Dio _dio = Dio();

  Future<void> saveNetworkImage(String url) async {
    try {
      // 1. Check and request access
      final hasAccess = await Gal.requestAccess();
      if (!hasAccess) {
        throw 'Permission denied. Please allow gallery access in settings.';
      }

      // 2. Download to a temporary file WITH .jpg extension
      // This extension is critical for the gallery to recognize it
      final tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/intario_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _dio.download(
        url, 
        filePath,
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      // 3. Save to Gallery
      // Gal.putImage triggers the OS media scanner
      await Gal.putImage(filePath);

      // 4. Cleanup
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      debugPrint('GalleryService: Image saved successfully');
    } catch (e) {
      debugPrint('GalleryService Error: $e');
      rethrow;
    }
  }
}
