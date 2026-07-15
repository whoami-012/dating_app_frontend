import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/story_gallery_provider.dart';
import '../models/story_media_item.dart';
import 'story_selection_badge.dart';

class StoryMediaGrid extends StatelessWidget {
  final List<GalleryMedia> mediaItems;
  final List<StoryMediaItem> selectedItems;
  final bool isGridView;
  final bool isLoading;
  final VoidCallback onCameraTap;
  final ValueChanged<GalleryMedia> onMediaTap;

  const StoryMediaGrid({
    super.key,
    required this.mediaItems,
    required this.selectedItems,
    required this.isGridView,
    required this.isLoading,
    required this.onCameraTap,
    required this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeletonGrid();
    }

    final totalCount = mediaItems.length + 1; // +1 for Camera tile

    if (isGridView) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 9 / 16,
        ),
        itemCount: totalCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCameraTile();
          }
          final media = mediaItems[index - 1];
          return _buildMediaTile(media);
        },
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalCount,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return SizedBox(height: 70, child: _buildCameraTile());
          }
          final media = mediaItems[index - 1];
          return SizedBox(height: 70, child: _buildMediaTile(media));
        },
      );
    }
  }

  Widget _buildCameraTile() {
    return Semantics(
      label: 'Camera Button',
      button: true,
      child: GestureDetector(
        onTap: onCameraTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF18191D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFFD1FF2F),
                size: 28,
              ),
              SizedBox(height: 8),
              Text(
                'Camera',
                style: TextStyle(
                  color: Color(0xFFA3A4AA),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaTile(GalleryMedia media) {
    final selectedIndex = selectedItems.indexWhere(
      (item) => item.path == media.path,
    );
    final isSelected = selectedIndex >= 0;

    return Semantics(
      label: 'Gallery item ${media.isVideo ? "video" : "photo"}',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () => onMediaTap(media),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFD1FF2F) : Colors.transparent,
              width: isSelected ? 2.5 : 0.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image background
                _buildThumbnailImage(media),

                // Selection dark overlay
                if (isSelected)
                  Container(color: Colors.black.withOpacity(0.35)),

                // Video indicators
                if (media.isVideo) ...[
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _formatDuration(media.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Selection Number Badge
                if (isSelected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: StorySelectionBadge(index: selectedIndex + 1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(GalleryMedia media) {
    final path = media.isVideo
        ? (media.thumbnailPath ?? media.path)
        : media.path;
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    if (isNetwork) {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return Container(
          color: const Color(0xFF18191D),
          child: const Center(
            child: Icon(Icons.image, color: Colors.grey, size: 24),
          ),
        );
      }

      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFF18191D),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Color(0xFFD1FF2F),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFF18191D),
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 16),
        ),
      );
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
    }
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 9 / 16,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF18191D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final secs = duration.inSeconds % 60;
    final mins = duration.inMinutes;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
