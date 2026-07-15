import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/selected_media.dart';

class MediaHelper {
  static const MethodChannel _channel = MethodChannel(
    'com.socialtree.dating_app_mobile/media_helper',
  );

  /// Detects if a path is a local video path or a remote video URL
  static bool isRemoteUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  /// Copies a picked media file (including content:// URIs and temporary picker paths)
  /// to an app-controlled persistent drafts directory.
  static Future<String> handleSelectedPath(String path) async {
    if (isRemoteUrl(path)) {
      return path;
    }

    String localPath = path;

    // Handle content:// URIs on Android
    if (Platform.isAndroid && path.startsWith('content://')) {
      try {
        final String? copiedPath = await _channel.invokeMethod<String>(
          'copyContentUriToTemp',
          {'uri': path},
        );
        if (copiedPath != null) {
          localPath = copiedPath;
        }
      } catch (e) {
        debugPrint('Error copying content URI: $e');
      }
    }

    // Copy local file to drafts directory to make it persistent
    try {
      final file = File(localPath);
      if (await file.exists()) {
        final tempDir = Directory.systemTemp;
        final draftsDir = Directory('${tempDir.path}/dating_app_drafts');
        if (!await draftsDir.exists()) {
          await draftsDir.create(recursive: true);
        }

        final fileName = localPath.split(Platform.pathSeparator).last;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = fileName.contains('.')
            ? fileName.split('.').last
            : 'mp4';

        final targetPath =
            '${draftsDir.path}/draft_media_${timestamp}_$fileName';
        final copiedFile = await file.copy(targetPath);
        return copiedFile.path;
      }
    } catch (e) {
      debugPrint('Error copying local file to drafts: $e');
    }

    return localPath;
  }

  /// Delete a single file safely
  static Future<void> deleteFile(String? path) async {
    if (path == null || isRemoteUrl(path)) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file $path: $e');
    }
  }

  /// Delete all media files associated with a SelectedMedia item
  static Future<void> deleteMediaFiles(SelectedMedia media) async {
    await deleteFile(media.path);
    await deleteFile(media.thumbnailPath);
  }
}
