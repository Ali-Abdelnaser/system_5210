import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:system_5210/core/utils/image_compressor.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
    Function(double)? onProgress,
  }) async {
    try {
      // 1. Compress and convert to WebP
      final compressedFile = await ImageCompressor.compressToWebP(imageFile);
      final fileToUpload = compressedFile ?? imageFile;

      // Reference to 'profile/uid.webp'
      final ref = _storage.ref().child('profile').child('$uid.webp');

      // Upload file
      final uploadTask = ref.putFile(
        fileToUpload,
        SettableMetadata(contentType: 'image/webp'),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
