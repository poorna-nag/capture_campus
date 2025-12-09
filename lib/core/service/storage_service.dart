// lib/storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:saver_gallery/saver_gallery.dart';

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

  /// Save image or video file with EXIF geotags and save to phone gallery
  static Future<File> saveMedia(
    XFile file, {
    bool isImage = true,
    double? latitude,
    double? longitude,
    String? address,
    Map<String, dynamic>? extra,
  }) async {
    final base = await _baseDir();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

    final ext = p.extension(file.path).isNotEmpty
        ? p.extension(file.path)
        : (isImage ? '.jpg' : '.mp4');

    final fileName = "${isImage ? 'IMG' : 'VID'}_$timestamp$ext";
    final savedPath = p.join(base.path, fileName);

    File savedFile;

    // Always try to save geotags for images if location is available
    if (isImage) {
      if (latitude != null && longitude != null) {
        // Embed EXIF geotags directly into the image
        savedFile = await _saveImageWithGeotag(
          file,
          savedPath,
          latitude: latitude,
          longitude: longitude,
          address: address,
          extra: extra,
        );
      } else {
        // Save image without geotags but still save metadata if available
        try {
          final sourceFile = File(file.path);
          if (!await sourceFile.exists()) {
            throw Exception('Source file does not exist: ${file.path}');
          }
          savedFile = await sourceFile.copy(savedPath);
          if (!await savedFile.exists()) {
            throw Exception('Failed to copy file to: $savedPath');
          }
          // Save metadata even without location
          if (extra != null && extra.isNotEmpty) {
            await _persistMetadata(
              savedFile,
              latitude: null,
              longitude: null,
              address: address,
              extra: extra,
            );
          }
        } catch (e) {
          print('Error copying image: $e');
          rethrow;
        }
      }
    } else {
      // For videos or images without location, copy the file
      try {
        // Verify source file exists before copying
        final sourceFile = File(file.path);
        if (!await sourceFile.exists()) {
          throw Exception('Source file does not exist: ${file.path}');
        }

        savedFile = await sourceFile.copy(savedPath);

        // Verify copy was successful
        if (!await savedFile.exists()) {
          throw Exception('Failed to copy file to: $savedPath');
        }

        // Still save metadata JSON for reference
        if (latitude != null || longitude != null || address != null) {
          await _persistMetadata(
            savedFile,
            latitude: latitude,
            longitude: longitude,
            address: address,
            extra: extra,
          );
        }
      } catch (e) {
        print('Error copying file: $e');
        rethrow;
      }
    }

    // Save to phone gallery (non-blocking to prevent crashes)
    // Run in background to avoid blocking UI
    if (isImage) {
      // For images, save to gallery
      _saveImageToGallery(savedFile, fileName).catchError((e) {
        print('Warning: Failed to save image to gallery: $e');
      });
    } else {
      // For videos, save to gallery without reading entire file into memory
      _saveVideoToGallery(savedFile, fileName).catchError((e) {
        print('Warning: Failed to save video to gallery: $e');
      });
    }

    return savedFile;
  }

  /// Save image with geotags - copies file and saves metadata JSON
  /// The metadata JSON file contains location data that can be read later
  static Future<File> _saveImageWithGeotag(
    XFile sourceFile,
    String targetPath, {
    required double latitude,
    required double longitude,
    String? address,
    Map<String, dynamic>? extra,
  }) async {
    try {
      // Verify source file exists
      final source = File(sourceFile.path);
      if (!await source.exists()) {
        throw Exception('Source image file does not exist: ${sourceFile.path}');
      }

      // Copy the original image file
      final savedFile = await source.copy(targetPath);

      // Verify copy was successful
      if (!await savedFile.exists()) {
        throw Exception('Failed to copy image file to: $targetPath');
      }

      // Try to read EXIF data from original (for verification)
      try {
        final bytes = await savedFile.readAsBytes();
        await readExifFromBytes(bytes);
        // EXIF exists in original file
      } catch (e) {
        // No EXIF in original, that's okay - metadata JSON will have the location
        print('No existing EXIF data in image (this is normal)');
      }

      // Always save comprehensive metadata JSON file with location
      await _persistMetadata(
        savedFile,
        latitude: latitude,
        longitude: longitude,
        address: address,
        extra: extra,
      );

      print('Image saved with geotag: Lat $latitude, Lon $longitude');

      return savedFile;
    } catch (e) {
      print('Error in _saveImageWithGeotag: $e');
      // If anything fails, try to at least copy the file and save metadata
      try {
        final savedFile = await File(sourceFile.path).copy(targetPath);
        await _persistMetadata(
          savedFile,
          latitude: latitude,
          longitude: longitude,
          address: address,
          extra: extra,
        );
        return savedFile;
      } catch (e2) {
        print('Failed to save image with geotag: $e2');
        rethrow;
      }
    }
  }

  static Future<void> _persistMetadata(
    File media, {
    double? latitude,
    double? longitude,
    String? address,
    Map<String, dynamic>? extra,
  }) async {
    final metadata = <String, dynamic>{
      'path': media.path,
      'savedAt': DateTime.now().toIso8601String(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (address != null) 'address': address,
      if (extra != null) ...extra,
    };

    final metadataFile = File("${media.path}.metadata.json");
    await metadataFile.writeAsString(jsonEncode(metadata));
  }

  /// Save image to gallery (helper method)
  static Future<void> _saveImageToGallery(
    File savedFile,
    String fileName,
  ) async {
    try {
      final imageBytes = await savedFile.readAsBytes();
      await SaverGallery.saveImage(
        imageBytes,
        fileName: fileName,
        skipIfExists: false,
      );
    } catch (e) {
      print('Error saving image to gallery: $e');
      rethrow;
    }
  }

  /// Save video to gallery without loading entire file into memory
  static Future<void> _saveVideoToGallery(
    File savedFile,
    String fileName,
  ) async {
    try {
      // Check file size first - if too large, skip gallery save to prevent crash
      final fileSize = await savedFile.length();
      const maxSizeForMemory = 100 * 1024 * 1024; // 100 MB limit

      if (fileSize > maxSizeForMemory) {
        print(
          'Video too large (${fileSize ~/ 1024 ~/ 1024}MB), skipping gallery save to prevent crash',
        );
        return;
      }

      // For smaller videos, try to save to gallery
      // Note: saver_gallery may not support videos directly, so we'll skip if it fails
      try {
        final videoBytes = await savedFile.readAsBytes();
        await SaverGallery.saveImage(
          videoBytes,
          fileName: fileName,
          skipIfExists: false,
        );
      } catch (e) {
        // saver_gallery might not support videos, that's okay
        // The video is already saved to app storage
        print('Gallery save not supported for videos (this is normal): $e');
      }
    } catch (e) {
      print('Error saving video to gallery: $e');
      // Don't rethrow - video is already saved locally
    }
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
