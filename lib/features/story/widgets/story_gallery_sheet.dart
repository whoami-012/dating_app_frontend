import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/story_gallery_provider.dart';
import '../providers/story_composer_provider.dart';
import '../models/story_media_item.dart';
import 'story_media_grid.dart';

class StoryGallerySheet extends ConsumerWidget {
  final ScrollController scrollController;
  final VoidCallback onCameraTap;

  const StoryGallerySheet({
    super.key,
    required this.scrollController,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryState = ref.watch(storyGalleryProvider);
    final composerState = ref.watch(storyComposerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    final backgroundColor = isDark ? const Color(0xFF111214) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          // 1. Sheet Handle
          Center(
            child: Container(
              width: 36,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // 2. Gallery Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Album selector drop down
                _buildAlbumSelector(context, ref, galleryState, isSmallScreen: isSmallScreen),

                // Right: View toggles
                Row(
                  children: [
                    _buildTextToggleButton(
                      label: isSmallScreen ? 'Multiple' : 'Select Multiple',
                      isActive: galleryState.isMultiSelectEnabled,
                      horizontalPadding: isSmallScreen ? 8 : 12,
                      onTap: () {
                        ref.read(storyGalleryProvider.notifier).toggleMultiSelect();
                      },
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 8),
                    _buildIconButton(
                      icon: galleryState.isGridView
                          ? Icons.grid_view_rounded
                          : Icons.view_list_rounded,
                      isActive: true,
                      onTap: () {
                        ref.read(storyGalleryProvider.notifier).toggleViewMode();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Selected Media Reorder Strip (horizontal)
          if (composerState.selectedItems.isNotEmpty && galleryState.isMultiSelectEnabled)
            _buildSelectedMediaStrip(context, ref, composerState.selectedItems),

          const SizedBox(height: 8),

          // 4. Media Grid / Scrollable area
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                StoryMediaGrid(
                  mediaItems: galleryState.mediaItems,
                  selectedItems: composerState.selectedItems,
                  isGridView: galleryState.isGridView,
                  isLoading: galleryState.isLoading,
                  onCameraTap: onCameraTap,
                  onMediaTap: (media) {
                    if (galleryState.isMultiSelectEnabled) {
                      ref.read(storyComposerProvider.notifier).addGalleryMedia(media);
                    } else {
                      // Single selection: reset and add
                      ref.read(storyComposerProvider.notifier).reset();
                      ref.read(storyComposerProvider.notifier).addGalleryMedia(media);
                    }
                  },
                ),
                const SizedBox(height: 80), // bottom space for share button
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumSelector(
      BuildContext context, WidgetRef ref, StoryGalleryState state, {bool isSmallScreen = false}) {
    return PopupMenuButton<String>(
      onSelected: (album) {
        ref.read(storyGalleryProvider.notifier).selectAlbum(album);
      },
      itemBuilder: (context) {
        return state.albums.map((album) {
          final isSelected = state.selectedAlbum == album;
          return PopupMenuItem(
            value: album,
            child: Text(
              album,
              style: TextStyle(
                color: isSelected ? const Color(0xFFD1FF2F) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList();
      },
      offset: const Offset(0, 48),
      color: const Color(0xFF18191D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 38,
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
        decoration: BoxDecoration(
          color: const Color(0xFF18191D),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.selectedAlbum,
              style: const TextStyle(
                color: Color(0xFFD1FF2F),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFD1FF2F),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    double horizontalPadding = 12.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD1FF2F) : const Color(0xFF18191D),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF050506) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF18191D),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildSelectedMediaStrip(
      BuildContext context, WidgetRef ref, List<StoryMediaItem> items) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        onReorder: (oldIndex, newIndex) {
          ref.read(storyComposerProvider.notifier).reorderMedia(oldIndex, newIndex);
        },
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final path = item.isVideo ? (item.thumbnailPath ?? item.path) : item.path;
          final isNetwork = path.startsWith('http://') || path.startsWith('https://');

          return Container(
            key: ValueKey(item.id),
            margin: const EdgeInsets.only(right: 12),
            width: 52,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1FF2F), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  isNetwork
                      ? CachedNetworkImage(imageUrl: path, fit: BoxFit.cover)
                      : Image.file(File(path), fit: BoxFit.cover),

                  // Remove button overlay
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(storyComposerProvider.notifier).removeMediaItem(item.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ),

                  // Order tag
                  Positioned(
                    bottom: 2,
                    left: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FF2F),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF050506),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
