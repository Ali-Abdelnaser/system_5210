import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageCompressor {
  /// تحويل الملف إلى WebP وضغطه
  static Future<File?> compressToWebP(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String targetPath = p.join(
        tempDir.path,
        "${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(file.path)}.webp",
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        format: CompressFormat.webp,
        quality: 80,
      );

      if (result == null) return file;
      return File(result.path);
    } catch (e) {
      debugPrint("Image Compression Error: $e");
      return file;
    }
  }

  /// تحويل الـ Bytes إلى WebP وضغطها
  static Future<Uint8List> compressBytes(Uint8List bytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        format: CompressFormat.webp,
        quality: 80,
      );
      return result;
    } catch (e) {
      debugPrint("Bytes Compression Error: $e");
      return bytes;
    }
  }
}
