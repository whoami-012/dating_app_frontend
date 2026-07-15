import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/selected_media.dart';
import 'upload_video_preview.dart';

class MediaPreviewCard extends StatelessWidget {
  final SelectedMedia media;
  final VoidCallback onRemove;
  final int index;
  final int totalCount;

  const MediaPreviewCard({
    super.key,
    required this.media,
    required this.onRemove,
    required this.index,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        media.path.startsWith('http://') || media.path.startsWith('https://');

    Widget imageWidget;
    if (media.isVideo) {
      imageWidget = UploadVideoPreview(
        videoPathOrUrl: media.path,
        thumbnailPath: media.thumbnailPath,
        onReplace: onRemove,
      );
    } else if (isNetwork) {
      // Use cached network image to avoid raw network image loads
      imageWidget = CachedNetworkImage(
        imageUrl: media.path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: const Color(0xFF121216),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFF121216),
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
        ),
      );
    } else {
      final file = File(media.path);
      imageWidget = Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF121216),
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
        ),
      );
    }

    return Container(
      width: 98,
      height: 198,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media Image
            imageWidget,

            // Video Overlay / Duration indicator
            if (media.isVideo)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatDuration(media.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Remove Button Top-Right
            Positioned(
              top: 6,
              right: 6,
              child: Semantics(
                label:
                    '${media.isVideo ? 'Video' : 'Photo'} ${index + 1} of $totalCount, double tap to remove',
                button: true,
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final seconds = duration.inSeconds % 60;
    final minutes = duration.inMinutes;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
