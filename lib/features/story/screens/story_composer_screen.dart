import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/story_composer_provider.dart';
import '../providers/story_gallery_provider.dart';
import '../models/story_overlay.dart';
import '../models/story_media_item.dart';
import '../widgets/story_top_bar.dart';
import '../widgets/story_canvas.dart';
import '../widgets/story_gallery_sheet.dart';
import 'story_preview_screen.dart';
import '../../media_upload/utils/media_helper.dart';

class StoryComposerScreen extends ConsumerStatefulWidget {
  const StoryComposerScreen({super.key});

  @override
  ConsumerState<StoryComposerScreen> createState() =>
      _StoryComposerScreenState();
}

class _StoryComposerScreenState extends ConsumerState<StoryComposerScreen> {
  final ImagePicker _cameraPicker = ImagePicker();
  bool _isLeftHanded = false;

  @override
  void initState() {
    super.initState();
    // Reset composer state on enter
    Future.microtask(() {
      ref.read(storyComposerProvider.notifier).reset();
    });
  }

  Future<void> _handleCameraCapture() async {
    try {
      final XFile? file = await _cameraPicker.pickImage(
        source: ImageSource.camera,
      );
      if (file != null) {
        final persistentPath = await MediaHelper.handleSelectedPath(file.path);
        // Simulate adding to gallery and selection
        final mediaItem = GalleryMedia(
          id: 'camera_${DateTime.now().millisecondsSinceEpoch}',
          path: persistentPath,
          isVideo: false,
        );
        ref.read(storyComposerProvider.notifier).addGalleryMedia(mediaItem);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Camera capture failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final composerState = ref.watch(composerProvider);
    final galleryState = ref.watch(storyGalleryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050506),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Navigation Bar
            StoryTopBar(
              title: 'Add to Story',
              hasSelection: composerState.selectedItems.isNotEmpty,
              onBack: () => Navigator.pop(context),
              onNext: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StoryPreviewScreen(items: composerState.selectedItems),
                  ),
                );
              },
            ),

            // 2. Composer Error Banner
            if (composerState.errorMessage != null)
              Container(
                color: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        composerState.errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(storyComposerProvider.notifier).clearError();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),

            // 3. Permission State Banner (if permission is limited or denied)
            if (galleryState.permissionState == GalleryPermissionState.denied ||
                galleryState.permissionState ==
                    GalleryPermissionState.permanentlyDenied)
              _buildPermissionPanel()
            else
              // 4. Main Canvas Editor Area
              Expanded(
                child: composerState.selectedItems.isEmpty
                    ? _buildEmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final hasIndicator =
                              composerState.selectedItems.length > 1;
                          final double indicatorHeight = hasIndicator
                              ? 30.0
                              : 0.0;

                          // Leave a 16px safety padding
                          final double availableHeight =
                              constraints.maxHeight - indicatorHeight - 16;
                          final double availableWidth =
                              constraints.maxWidth - 32;

                          // Fit 9:16 aspect ratio in available height/width
                          double canvasHeight = availableHeight;
                          double canvasWidth = canvasHeight * 9 / 16;
                          if (canvasWidth > availableWidth) {
                            canvasWidth = availableWidth;
                            canvasHeight = canvasWidth * 16 / 9;
                          }

                          return Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StoryCanvas(
                                    item: composerState.activeItem!,
                                    isLeftHanded: _isLeftHanded,
                                    canvasWidth: canvasWidth,
                                    canvasHeight: canvasHeight,
                                  ),
                                  if (hasIndicator) ...[
                                    const SizedBox(height: 12),
                                    _buildPageIndicator(composerState),
                                  ],
                                ],
                              ),

                              // Listening for active tool sheets
                              if (composerState.activeTool != null)
                                _buildToolOverlaySheet(
                                  composerState.activeTool!,
                                ),
                            ],
                          );
                        },
                      ),
              ),

            // 5. Gallery Sheet
            if (galleryState.permissionState != GalleryPermissionState.denied &&
                galleryState.permissionState !=
                    GalleryPermissionState.permanentlyDenied)
              SizedBox(
                height: composerState.selectedItems.isEmpty
                    ? MediaQuery.of(context).size.height * 0.7
                    : MediaQuery.of(context).size.height * 0.35,
                child: StoryGallerySheet(
                  scrollController: ScrollController(),
                  onCameraTap: _handleCameraCapture,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFFD1FF2F),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select media to start your story',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose from the gallery below or capture with camera',
              style: TextStyle(color: Color(0xFFA3A4AA), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionPanel() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gallery Permission Denied',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We need access to your gallery and photos to let you compose stories. Please grant permissions in System Settings.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFA3A4AA), fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1FF2F),
                  foregroundColor: const Color(0xFF050506),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // Simulate granting permissions
                  ref
                      .read(storyGalleryProvider.notifier)
                      .updatePermissionState(GalleryPermissionState.granted);
                },
                child: const Text(
                  'Grant Access (Simulated)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(StoryComposerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(state.selectedItems.length, (index) {
        final isActive = state.activeItemIndex == index;
        return GestureDetector(
          onTap: () {
            ref.read(storyComposerProvider.notifier).selectItemIndex(index);
          },
          child: Container(
            width: isActive ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFD1FF2F) : Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToolOverlaySheet(StoryTool tool) {
    switch (tool) {
      case StoryTool.text:
        return _buildTextSheet();
      case StoryTool.stickers:
        return _buildStickersSheet();
      case StoryTool.music:
        return _buildMusicSheet();
      case StoryTool.crop:
        return _buildCropSheet();
      default:
        return const SizedBox.shrink();
    }
  }

  // Text overlay editor sheet
  Widget _buildTextSheet() {
    final textController = TextEditingController();
    String colorHex = '0xFFD1FF2F';
    String textStyle = 'background'; // or normal

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => ref
                      .read(storyComposerProvider.notifier)
                      .setActiveTool(null),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (textController.text.isNotEmpty) {
                      final newOverlay = StoryOverlay(
                        id: 'text_${DateTime.now().millisecondsSinceEpoch}',
                        type: StoryOverlayType.text,
                        text: textController.text,
                        colorHex: colorHex,
                        textStyle: textStyle,
                      );
                      ref
                          .read(storyComposerProvider.notifier)
                          .addOverlay(newOverlay);
                    }
                    ref
                        .read(storyComposerProvider.notifier)
                        .setActiveTool(null);
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Color(0xFFD1FF2F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            TextField(
              controller: textController,
              autofocus: true,
              style: TextStyle(
                color: textStyle == 'background'
                    ? Colors.black
                    : Color(int.parse(colorHex)),
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: textStyle == 'background',
                fillColor: textStyle == 'background'
                    ? Color(int.parse(colorHex))
                    : Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Type text...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // Colors list
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  [
                        '0xFFD1FF2F',
                        '0xFFFFFFFF',
                        '0xFFFF3B30',
                        '0xFF34C759',
                        '0xFF007AFF',
                      ]
                      .map(
                        (cHex) => GestureDetector(
                          onTap: () {
                            setState(() {
                              colorHex = cHex;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(int.parse(cHex)),
                              border: Border.all(
                                color: Colors.white,
                                width: colorHex == cHex ? 2.0 : 0.0,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextStyleButton(
                  'Background',
                  textStyle == 'background',
                  () {
                    setState(() {
                      textStyle = 'background';
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildTextStyleButton('Normal', textStyle == 'normal', () {
                  setState(() {
                    textStyle = 'normal';
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextStyleButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD1FF2F) : Colors.white10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Sticker selection sheet
  Widget _buildStickersSheet() {
    final stickers = ['😀', '😍', '🔥', '✨', '⚡', '🎉', '💯', '❤️', '📍', '❓'];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 280,
        decoration: const BoxDecoration(
          color: Color(0xFF111214),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Emojis & Stickers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => ref
                      .read(storyComposerProvider.notifier)
                      .setActiveTool(null),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: stickers.length,
                itemBuilder: (context, index) {
                  final sticker = stickers[index];
                  return GestureDetector(
                    onTap: () {
                      final newOverlay = StoryOverlay(
                        id: 'sticker_${DateTime.now().millisecondsSinceEpoch}',
                        type: StoryOverlayType.sticker,
                        stickerPath: sticker,
                        stickerType: 'emoji',
                      );
                      ref
                          .read(storyComposerProvider.notifier)
                          .addOverlay(newOverlay);
                      ref
                          .read(storyComposerProvider.notifier)
                          .setActiveTool(null);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        sticker,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Music attachment picker
  Widget _buildMusicSheet() {
    final tracks = [
      {'title': 'Blinding Lights', 'artist': 'The Weeknd'},
      {'title': 'Stay', 'artist': 'The Kid LAROI & Justin Bieber'},
      {'title': 'Industry Baby', 'artist': 'Lil Nas X & Jack Harlow'},
      {'title': 'Bad Habits', 'artist': 'Ed Sheeran'},
      {'title': 'Good 4 U', 'artist': 'Olivia Rodrigo'},
    ];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 320,
        decoration: const BoxDecoration(
          color: Color(0xFF111214),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attach Music',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => ref
                      .read(storyComposerProvider.notifier)
                      .setActiveTool(null),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.music_note,
                      color: Color(0xFFD1FF2F),
                    ),
                    title: Text(
                      track['title']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      track['artist']!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white54,
                    ),
                    onTap: () {
                      final music = StoryMusic(
                        id: 'music_${DateTime.now().millisecondsSinceEpoch}',
                        title: track['title']!,
                        artist: track['artist']!,
                        durationSeconds: 15,
                        startPointSeconds: 0,
                      );
                      ref
                          .read(storyComposerProvider.notifier)
                          .attachMusic(music);
                      ref
                          .read(storyComposerProvider.notifier)
                          .setActiveTool(null);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Crop & rotate tool controls
  Widget _buildCropSheet() {
    double scale = 1.0;
    double rotation = 0.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 180,
        decoration: const BoxDecoration(
          color: Color(0xFF111214),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Crop & Transform',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref
                        .read(storyComposerProvider.notifier)
                        .applyCropAndTransform(
                          rotation: rotation,
                          scale: scale,
                        );
                    ref
                        .read(storyComposerProvider.notifier)
                        .setActiveTool(null);
                  },
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Color(0xFFD1FF2F),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.rotate_right_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          rotation += 0.5 * 3.14159 / 2; // ~45 deg
                        });
                        ref
                            .read(storyComposerProvider.notifier)
                            .applyCropAndTransform(
                              rotation: rotation,
                              scale: scale,
                            );
                      },
                    ),
                    const Text(
                      'Rotate 90°',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 48),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.restart_alt_rounded,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          rotation = 0.0;
                          scale = 1.0;
                        });
                        ref
                            .read(storyComposerProvider.notifier)
                            .applyCropAndTransform(rotation: 0.0, scale: 1.0);
                      },
                    ),
                    const Text(
                      'Reset',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// Simple provider extension for cleaner riverpod reads
final composerProvider = Provider.autoDispose<StoryComposerState>((ref) {
  return ref.watch(storyComposerProvider);
});
