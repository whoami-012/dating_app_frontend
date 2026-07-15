import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/story_media_item.dart';
import '../models/story_overlay.dart';
import '../providers/story_upload_provider.dart';
import '../providers/story_composer_provider.dart';
import '../widgets/story_share_button.dart';
import '../widgets/story_upload_progress.dart';

class StoryPreviewScreen extends ConsumerStatefulWidget {
  final List<StoryMediaItem> items;

  const StoryPreviewScreen({
    super.key,
    required this.items,
  });

  @override
  ConsumerState<StoryPreviewScreen> createState() => _StoryPreviewScreenState();
}

class _StoryPreviewScreenState extends ConsumerState<StoryPreviewScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  String _selectedAudience = 'Everyone';
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideoForCurrentPage();
  }

  @override
  void dispose() {
    _disposeVideo();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initVideoForCurrentPage() async {
    await _disposeVideo();

    if (_currentPageIndex >= widget.items.length) return;
    final item = widget.items[_currentPageIndex];

    if (!item.isVideo) return;

    final isNetwork = item.path.startsWith('http://') || item.path.startsWith('https://');
    _videoController = isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(item.path))
        : VideoPlayerController.file(File(item.path));

    try {
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(item.isMuted ? 0.0 : 1.0);
      await _videoController!.play();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _disposeVideo() async {
    if (_videoController != null) {
      try {
        await _videoController!.pause();
      } catch (_) {}
      await _videoController!.dispose();
      _videoController = null;
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    _initVideoForCurrentPage();
  }

  Future<void> _handleShare() async {
    final success = await ref
        .read(storyUploadProvider.notifier)
        .uploadStories(widget.items, _selectedAudience);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story posted successfully!'),
          backgroundColor: Color(0xFFD1FF2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Reset composer and return to Home
      ref.read(storyComposerProvider.notifier).reset();
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(storyUploadProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050506),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top bar
            _buildTopBar(),

            // 2. Linear upload progress banner
            StoryUploadProgress(
              progress: uploadState.progress,
              visible: uploadState.status == StoryUploadStatus.uploading,
            ),

            // 3. Error Banner on Failure
            if (uploadState.errorMessage != null) _buildErrorBanner(),

            const SizedBox(height: 12),

            // 4. Centered Preview Canvas (using PageView for multi-selection preview)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double availableHeight = constraints.maxHeight - 16; // 16px safety margin
                  final double availableWidth = constraints.maxWidth - 32; // 16px horizontal margins

                  double previewHeight = availableHeight;
                  double previewWidth = previewHeight * 9 / 16;
                  if (previewWidth > availableWidth) {
                    previewWidth = availableWidth;
                    previewHeight = previewWidth * 16 / 9;
                  }

                  return Center(
                    child: SizedBox(
                      width: previewWidth,
                      height: previewHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              itemCount: widget.items.length,
                              itemBuilder: (context, index) {
                                final item = widget.items[index];
                                return _buildPreviewSlide(item);
                              },
                            ),

                            // Dots page indicator at bottom
                            if (widget.items.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    widget.items.length,
                                    (index) => Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentPageIndex == index
                                            ? const Color(0xFFD1FF2F)
                                            : Colors.white30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 5. Audience Selector Pill
            _buildAudienceSelector(),

            const SizedBox(height: 20),

            // 6. Share to Story CTA button
            StoryShareButton(
              text: 'Share to Story',
              isEnabled: uploadState.status != StoryUploadStatus.uploading,
              isLoading: uploadState.status == StoryUploadStatus.uploading,
              progress: uploadState.progress,
              onPressed: _handleShare,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Text(
            'Preview Story',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () async {
              await ref.read(storyComposerProvider.notifier).saveDraft();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Story Draft Saved!')),
                );
              }
            },
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: Colors.white24),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Save Draft',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSlide(StoryMediaItem item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Media content
        item.isVideo
            ? (_isVideoInitialized && _videoController != null
                ? VideoPlayer(_videoController!)
                : (item.thumbnailPath != null
                    ? Image.network(item.thumbnailPath!, fit: BoxFit.cover)
                    : const Center(child: CircularProgressIndicator(color: Color(0xFFD1FF2F)))))
            : (item.path.startsWith('http')
                ? Image.network(item.path, fit: BoxFit.cover)
                : Image.file(File(item.path), fit: BoxFit.cover)),

        // Filter color
        _buildAppliedFilter(item.filter),

        // Overlays
        ...item.overlays.map((o) => _buildOverlayStatic(o)),

        // Music chip
        if (item.music != null)
          Positioned(
            bottom: 32,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Color(0xFFD1FF2F), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${item.music!.title} - ${item.music!.artist}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAppliedFilter(String? filter) {
    if (filter == null) return const SizedBox.shrink();
    if (filter == 'grayscale') {
      return const ColorFiltered(
        colorFilter: ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: SizedBox.shrink(),
      );
    }
    Color c;
    BlendMode bm = BlendMode.color;
    if (filter == 'sepia') {
      c = const Color(0xFF704214).withOpacity(0.3);
    } else if (filter == 'vintage') {
      c = const Color(0xFFFFB300).withOpacity(0.15);
      bm = BlendMode.multiply;
    } else {
      c = const Color(0xFFFF0055).withOpacity(0.15);
      bm = BlendMode.colorBurn;
    }
    return Container(
      color: c,
      child: Center(
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildOverlayStatic(StoryOverlay o) {
    return Positioned(
      left: o.x,
      top: o.y,
      child: Transform.rotate(
        angle: o.rotation,
        child: Transform.scale(
          scale: o.scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: o.textStyle == 'background'
                  ? (o.colorHex != null ? Color(int.parse(o.colorHex!)) : Colors.black.withOpacity(0.8))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: o.type == StoryOverlayType.text
                ? Text(
                    o.text ?? '',
                    style: TextStyle(
                      color: o.textStyle == 'background'
                          ? Colors.white
                          : (o.colorHex != null ? Color(int.parse(o.colorHex!)) : Colors.white),
                      fontSize: o.fontSize ?? 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(o.stickerPath ?? '', style: const TextStyle(fontSize: 28)),
          ),
        ),
      ),
    );
  }

  Widget _buildAudienceSelector() {
    final audiences = ['Everyone', 'Followers', 'Close Friends', 'Custom'];

    return PopupMenuButton<String>(
      onSelected: (val) {
        setState(() {
          _selectedAudience = val;
        });
      },
      itemBuilder: (context) {
        return audiences.map((aud) {
          final isSelected = _selectedAudience == aud;
          return PopupMenuItem(
            value: aud,
            child: Text(
              aud,
              style: TextStyle(
                color: isSelected ? const Color(0xFFD1FF2F) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList();
      },
      color: const Color(0xFF18191D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF111214),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline_rounded, color: Color(0xFFD1FF2F), size: 18),
            const SizedBox(width: 8),
            Text(
              'Audience: $_selectedAudience',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    final uploadState = ref.read(storyUploadProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              uploadState.errorMessage ?? 'Upload failed.',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(storyUploadProvider.notifier).clearError();
              _handleShare();
            },
            child: const Text('Retry', style: TextStyle(color: Color(0xFFD1FF2F), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
