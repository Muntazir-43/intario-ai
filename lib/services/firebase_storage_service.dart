import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('user_uploads/$timestamp.jpg');

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      if (uploadTask.state != TaskState.success) {
        throw const FirebaseUploadException(
          message: 'Upload did not complete successfully. Please try again.',
        );
      }

      final downloadUrl = await ref.getDownloadURL();

      if (downloadUrl.isEmpty) {
        throw const FirebaseUploadException(
          message: 'Failed to retrieve image URL. Please try again.',
        );
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'storage/unauthorized':
          throw const FirebaseUploadException(
            message: 'Upload permission denied. Please try again later.',
          );
        case 'storage/canceled':
          throw const FirebaseUploadException(
            message: 'Upload was cancelled.',
          );
        case 'storage/object-not-found':
          throw const FirebaseUploadException(
            message: 'Upload reference not found. Please try again.',
          );
        case 'storage/quota-exceeded':
          throw const FirebaseUploadException(
            message: 'Storage quota exceeded. Please contact support.',
          );
        case 'storage/invalid-checksum':
          throw const FirebaseUploadException(
            message: 'File corrupted during upload. Please try again.',
          );
        case 'storage/retry-limit-exceeded':
          throw const FirebaseUploadException(
            message: 'Upload failed after multiple attempts. Check your connection.',
          );
        default:
          throw FirebaseUploadException(
            message: 'Upload failed: ${e.message ?? 'Unknown error'}. Please try again.',
          );
      }
    } on FirebaseUploadException {
      rethrow;
    } catch (e) {
      throw const FirebaseUploadException(
        message: 'An unexpected error occurred during upload. Please try again.',
      );
    }
  }
}

class FirebaseUploadException implements Exception {
  final String message;

  const FirebaseUploadException({required this.message});

  @override
  String toString() => 'FirebaseUploadException: $message';
}