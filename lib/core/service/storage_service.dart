// lib/storage_service.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class StorageService {
  static const String folderName = "CapturedMedia";

  /// Base directory for saving images/videos
  static Future<Directory> _baseDir() async {
    Directory? dir;
    try {
      dir = await getExternalStorageDirectory();
    } catch (_) {
      dir = null;
    }
    dir ??= await getApplicationDocumentsDirectory();

    final target = Directory(p.join(dir.path, folderName));
    if (!await target.exists()) await target.create(recursive: true);
    return target;
  }

  /// Save image or video file
  static Future<File> saveMedia(XFile file, {bool isImage = true}) async {
    final base = await _baseDir();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

    final ext = p.extension(file.path).isNotEmpty
        ? p.extension(file.path)
        : (isImage ? '.jpg' : '.mp4');

    final fileName = "${isImage ? 'IMG' : 'VID'}_$timestamp$ext";
    final savedPath = p.join(base.path, fileName);

    return File(file.path).copy(savedPath);
  }

  /// Delete a saved image/video file
  static Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore delete failure silently
    }
  }

  /// Get all saved images sorted by latest
  static Future<List<File>> listSavedImages() async {
    final base = await _baseDir();
    if (!await base.exists()) return [];

    final files = base.listSync().whereType<File>().toList();

    final images = files.where((f) {
      final ext = p.extension(f.path).toLowerCase();
      return ext == '.jpg' ||
          ext == '.jpeg' ||
          ext == '.png' ||
          ext == '.heic' ||
          ext == '.webp';
    }).toList();

    images.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return images;
  }
}
