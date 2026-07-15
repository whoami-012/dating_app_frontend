import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../models/selected_media.dart';
import '../models/upload_post_state.dart';
import '../models/draft.dart';
import '../providers/upload_post_provider.dart';
import '../widgets/upload_header.dart';
import '../widgets/media_preview_strip.dart';
import '../widgets/upload_limit_text.dart';
import '../widgets/caption_input.dart';
import '../widgets/tag_selector.dart';
import '../widgets/upload_setting_tile.dart';
import '../widgets/upload_primary_button.dart';
import '../widgets/upload_progress_indicator.dart';
import '../widgets/upload_error_banner.dart';
import '../utils/media_helper.dart';
import '../widgets/upload_video_preview.dart';

class UploadMediaScreen extends ConsumerStatefulWidget {
  const UploadMediaScreen({super.key});

  @override
  ConsumerState<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends ConsumerState<UploadMediaScreen> {
  bool _hasLocationPermission = false;
  bool _askedLocationPermission = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia(
    BuildContext context,
    ImageSource source,
    bool isVideo,
  ) async {
    try {
      if (isVideo) {
        final XFile? file = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(seconds: 45),
        );
        if (file != null) {
          final fileObject = File(file.path);
          if (!await fileObject.exists()) {
            throw Exception('Selected file does not exist.');
          }

          final lowerPath = file.path.toLowerCase();
          if (!lowerPath.endsWith('.mp4') && !lowerPath.endsWith('.mov')) {
            throw Exception('Unsupported video format. Please select an MP4 or MOV video.');
          }

          final persistentPath = await MediaHelper.handleSelectedPath(file.path);

          final factory = ref.read(videoPlayerControllerFactoryProvider);
          final tempController = factory.file(File(persistentPath));
          await tempController.initialize();
          final duration = tempController.value.duration;
          await tempController.dispose();

          if (duration.inSeconds > 60) {
            // Delete persistent copy first since validation failed
            await MediaHelper.deleteFile(persistentPath);
            throw Exception('Video exceeds maximum duration of 60 seconds.');
          }

          // Generate a mock/placeholder thumbnail file in drafts
          final tempDir = Directory.systemTemp;
          final draftsDir = Directory('${tempDir.path}/dating_app_drafts');
          final thumbnailPath = '${draftsDir.path}/draft_thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final thumbFile = File(thumbnailPath);
          await thumbFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00]);

          final media = SelectedMedia(
            id: 'video_${DateTime.now().millisecondsSinceEpoch}',
            path: persistentPath,
            isVideo: true,
            duration: duration,
            thumbnailPath: thumbnailPath,
          );
          ref.read(uploadPostProvider.notifier).addMedia(media);
        }
      } else {
        final XFile? file = await _picker.pickImage(source: source);
        if (file != null) {
          final fileObject = File(file.path);
          if (!await fileObject.exists()) {
            throw Exception('Selected file does not exist.');
          }

          final persistentPath = await MediaHelper.handleSelectedPath(file.path);
          final media = SelectedMedia(
            id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
            path: persistentPath,
            isVideo: false,
          );
          ref.read(uploadPostProvider.notifier).addMedia(media);
        }
      }
    } catch (e) {
      if (context.mounted) {
        String msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick media: $msg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) {
      _checkAndShowErrorMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadPostProvider);
    final drafts = ref.watch(uploadDraftsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // AMOLED black in dark mode
    final backgroundColor = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF5F6F8);
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 1. Header Row
                UploadMediaHeader(
                  draftCount: drafts.length,
                  onBack: () => _handleBackPress(context),
                  onDraftsPressed: () => _showDraftsSheet(context),
                ),

                const SizedBox(height: 24),

                // 2. Media Preview Horizontal Strip
                MediaPreviewStrip(
                  mediaList: uploadState.selectedMedia,
                  onAddPressed: () => _showMediaPickerSheet(context),
                  onRemovePressed: (id) {
                    ref.read(uploadPostProvider.notifier).removeMedia(id);
                  },
                ),

                // 3. Media limits helper text
                const UploadLimitText(),

                // 4. Caption Area
                CaptionInputCard(
                  initialValue: uploadState.caption,
                  onChanged: (text) {
                    ref.read(uploadPostProvider.notifier).updateCaption(text);
                  },
                ),

                // 5. Add Tags Area
                TagSelector(
                  selectedTags: uploadState.tags,
                  onTagsChanged: (tags) {
                    ref.read(uploadPostProvider.notifier).setTags(tags);
                  },
                ),

                const SizedBox(height: 28),

                // 6. Privacy Setting Tile
                UploadSettingTile(
                  key: const ValueKey('visibility_tile'),
                  icon: Icons.visibility_outlined,
                  title: 'Who can see this?',
                  subtitle: uploadState.visibility,
                  onTap: () =>
                      _showVisibilitySheet(context, uploadState.visibility),
                ),

                const SizedBox(height: 14),

                // 7. Location Setting Tile
                UploadSettingTile(
                  key: const ValueKey('location_tile'),
                  icon: Icons.location_on_outlined,
                  title: 'Add Location',
                  subtitle:
                      uploadState.location == null ||
                          uploadState.location!.isEmpty
                      ? 'Add location'
                      : uploadState.location!,
                  onTap: () => _handleLocationPress(context),
                ),

                const SizedBox(height: 14),

                // 8. Advanced Settings Tile
                UploadSettingTile(
                  key: const ValueKey('advanced_tile'),
                  icon: Icons.settings_outlined,
                  title: 'Advanced Settings',
                  subtitle: 'Comments, permissions and more',
                  onTap: () => _showAdvancedSettingsSheet(context, uploadState),
                ),

                // 9. Error banner if upload failed
                UploadErrorBanner(
                  message: uploadState.errorMessage,
                  onDismiss: () {
                    ref.read(uploadPostProvider.notifier).clearErrorMessage();
                  },
                  onRetry: () {
                    ref.read(uploadPostProvider.notifier).uploadPost();
                  },
                ),

                // 10. Progress bar if uploading
                UploadProgressIndicator(
                  progress: uploadState.progress,
                  visible: uploadState.status == UploadStatus.uploading,
                ),

                const SizedBox(height: 28),

                // 11. Large Gradient Upload CTA
                UploadPrimaryButton(
                  isLoading: uploadState.status == UploadStatus.uploading,
                  progress: uploadState.progress,
                  isEnabled: uploadState.selectedMedia.isNotEmpty,
                  onPressed: () async {
                    final success = await ref
                        .read(uploadPostProvider.notifier)
                        .uploadPost();
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Upload successful!'),
                          backgroundColor: Color(0xFFD2FF27),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleBackPress(BuildContext context) {
    final uploadState = ref.read(uploadPostProvider);
    if (uploadState.selectedMedia.isNotEmpty ||
        uploadState.caption.isNotEmpty) {
      ref.read(uploadPostProvider.notifier).saveAsDraft();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft saved automatically'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    Navigator.pop(context);
  }

  // 12. Location selection with manual search and permissions
  void _handleLocationPress(BuildContext context) {
    if (!_askedLocationPermission) {
      _showLocationPermissionDialog(context);
    } else if (!_hasLocationPermission) {
      _showManualLocationSearch(context);
    } else {
      _showManualLocationSearch(context);
    }
  }

  void _showLocationPermissionDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0C0C0F) : Colors.white,
        title: Text(
          'Allow Location Access?',
          style: TextStyle(color: primaryColor),
        ),
        content: Text(
          'We use your location to help tag where this moment happened. You can search manually if denied.',
          style: TextStyle(
            color: isDark ? const Color(0xFF92929B) : const Color(0xFF666971),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _askedLocationPermission = true;
                _hasLocationPermission = false;
              });
              Navigator.pop(context);
              _showManualLocationSearch(context);
            },
            child: const Text('Deny', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _askedLocationPermission = true;
                _hasLocationPermission = true;
              });
              Navigator.pop(context);
              _showManualLocationSearch(context);
            },
            child: const Text(
              'Allow',
              style: TextStyle(color: Color(0xFFD2FF27)),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualLocationSearch(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);
    final surfaceColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFFFFFFF);
    final dialogBorder = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    final locations = [
      'Los Angeles, CA',
      'New York, NY',
      'London, UK',
      'Tokyo, Japan',
      'Paris, France',
      'Sydney, Australia',
      'Bali, Indonesia',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Search Location',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    style: TextStyle(color: primaryTextColor),
                    decoration: InputDecoration(
                      hintText: 'Search city, state, or country...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF121216)
                          : const Color(0xFFF0F1F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      // Filter location suggestions dynamically (simulate)
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount:
                          locations.length + 1, // +1 for "Clear Location"
                      separatorBuilder: (context, index) =>
                          Divider(color: dialogBorder, height: 1),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            leading: const Icon(
                              Icons.location_off,
                              color: Colors.red,
                            ),
                            title: const Text(
                              'Remove Location',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              ref
                                  .read(uploadPostProvider.notifier)
                                  .setLocation(null);
                              Navigator.pop(context);
                            },
                          );
                        }
                        final loc = locations[index - 1];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Color(0xFFD2FF27),
                          ),
                          title: Text(
                            loc,
                            style: TextStyle(color: primaryTextColor),
                          ),
                          onTap: () {
                            ref
                                .read(uploadPostProvider.notifier)
                                .setLocation(loc);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 13. Visibility selector bottom sheet
  void _showVisibilitySheet(BuildContext context, String current) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);
    final surfaceColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFFFFFFF);

    final options = [
      {'title': 'Everyone', 'subtitle': 'Anyone on Social Tree can see this'},
      {
        'title': 'Only your followers',
        'subtitle': 'Only accounts that follow you',
      },
      {
        'title': 'Matches only',
        'subtitle': 'Only people you have a bidirectional match with',
      },
      {'title': 'Private / Only me', 'subtitle': 'Visible only to you'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Who can see this?',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isSelected = opt['title'] == current;
                return ListTile(
                  title: Text(
                    opt['title']!,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    opt['subtitle']!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFFD2FF27))
                      : null,
                  onTap: () {
                    ref
                        .read(uploadPostProvider.notifier)
                        .setVisibility(opt['title']!);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // 14. Advanced settings toggles sheet
  void _showAdvancedSettingsSheet(BuildContext context, UploadPostState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);
    final surfaceColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFFFFFFF);

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final uploadState = ref.watch(uploadPostProvider);
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Advanced Settings',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(
                      'Allow Comments',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    subtitle: const Text(
                      'Let others comment on your post',
                      style: TextStyle(color: Colors.grey),
                    ),
                    value: uploadState.allowComments,
                    activeColor: const Color(0xFFD2FF27),
                    onChanged: (val) {
                      ref
                          .read(uploadPostProvider.notifier)
                          .setAdvancedSettings(allowComments: val);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      'Allow Sharing',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    subtitle: const Text(
                      'Enable share button for this post',
                      style: TextStyle(color: Colors.grey),
                    ),
                    value: uploadState.allowSharing,
                    activeColor: const Color(0xFFD2FF27),
                    onChanged: (val) {
                      ref
                          .read(uploadPostProvider.notifier)
                          .setAdvancedSettings(allowSharing: val);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      'Allow Saving',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    subtitle: const Text(
                      'Let others save this to their device',
                      style: TextStyle(color: Colors.grey),
                    ),
                    value: uploadState.allowSaving,
                    activeColor: const Color(0xFFD2FF27),
                    onChanged: (val) {
                      ref
                          .read(uploadPostProvider.notifier)
                          .setAdvancedSettings(allowSaving: val);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      'Show Like Count',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    subtitle: const Text(
                      'Display total likes on post details',
                      style: TextStyle(color: Colors.grey),
                    ),
                    value: uploadState.showLikeCount,
                    activeColor: const Color(0xFFD2FF27),
                    onChanged: (val) {
                      ref
                          .read(uploadPostProvider.notifier)
                          .setAdvancedSettings(showLikeCount: val);
                      setModalState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 15. Media Selection Bottom Sheet (Offering Gallery/Camera and Mock Simulation options)
  void _showMediaPickerSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);
    final surfaceColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFFFFFFF);

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Upload Media',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Device Source Options
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: Color(0xFFD2FF27),
                    ),
                    title: Text(
                      'Choose Photo from Gallery',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickMedia(context, ImageSource.gallery, false);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFFD2FF27),
                    ),
                    title: Text(
                      'Take Photo with Camera',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickMedia(context, ImageSource.camera, false);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.video_collection,
                      color: Color(0xFFD2FF27),
                    ),
                    title: Text(
                      'Choose Video from Gallery',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickMedia(context, ImageSource.gallery, true);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.videocam,
                      color: Color(0xFFD2FF27),
                    ),
                    title: Text(
                      'Record Video with Camera',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickMedia(context, ImageSource.camera, true);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.grey),
                  ),

                  Text(
                    'Simulate Media Picker (Mock Data)',
                    style: TextStyle(
                      color: primaryTextColor.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ListTile(
                    leading: const Icon(Icons.photo, color: Colors.grey),
                    title: Text(
                      'Add Mock Photo',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    onTap: () {
                      final activePhotosCount = ref
                          .read(uploadPostProvider)
                          .selectedMedia
                          .length;
                      if (activePhotosCount < 10) {
                        final newPhoto = UploadPostNotifier
                            .mockPhotos[activePhotosCount % 10];
                        ref
                            .read(uploadPostProvider.notifier)
                            .addMedia(
                              newPhoto.copyWith(
                                id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
                              ),
                            );
                      } else {
                        ref
                            .read(uploadPostProvider.notifier)
                            .addMedia(UploadPostNotifier.mockPhotos[0]);
                      }
                      Navigator.pop(context);
                      _checkAndShowErrorMessage();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.video_library,
                      color: Colors.grey,
                    ),
                    title: Text(
                      'Add Mock Video (45s - Valid)',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    onTap: () {
                      ref
                          .read(uploadPostProvider.notifier)
                          .addMedia(UploadPostNotifier.mockShortVideo);
                      Navigator.pop(context);
                      _checkAndShowErrorMessage();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.video_library,
                      color: Colors.orange,
                    ),
                    title: Text(
                      'Add Mock Video (75s - Invalid duration)',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    onTap: () {
                      ref
                          .read(uploadPostProvider.notifier)
                          .addMedia(UploadPostNotifier.mockLongVideo);
                      Navigator.pop(context);
                      _checkAndShowErrorMessage();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.layers, color: Colors.grey),
                    title: Text(
                      'Add 10 Photos at once',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    onTap: () {
                      for (int i = 0; i < 10; i++) {
                        ref
                            .read(uploadPostProvider.notifier)
                            .addMedia(
                              UploadPostNotifier.mockPhotos[i].copyWith(
                                id: 'photo_batch_${i}_${DateTime.now().millisecondsSinceEpoch}',
                              ),
                            );
                      }
                      Navigator.pop(context);
                      _checkAndShowErrorMessage();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _checkAndShowErrorMessage() {
    final uploadState = ref.read(uploadPostProvider);
    if (uploadState.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(uploadState.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Clear error message in state so it doesn't repeat
      ref.read(uploadPostProvider.notifier).clearErrorMessage();
    }
  }

  // 16. Drafts bottom sheet list
  void _showDraftsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);
    final surfaceColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFFFFFFF);
    final cardBorder = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final list = ref.watch(uploadDraftsProvider);
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Saved Drafts',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (list.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          'No saved drafts yet',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF6F7078)
                                : const Color(0xFF92959D),
                          ),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: list.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: cardBorder, height: 1),
                        itemBuilder: (context, index) {
                          final draft = list[index];
                          final count = draft.selectedMedia.length;
                          final isVideo =
                              draft.selectedMedia.isNotEmpty &&
                              draft.selectedMedia.first.isVideo;
                          final previewUrl = draft.selectedMedia.isNotEmpty
                              ? (isVideo
                                    ? draft.selectedMedia.first.thumbnailPath
                                    : draft.selectedMedia.first.path)
                              : null;
                          final capPreview = draft.caption.isEmpty
                              ? 'No caption'
                              : draft.caption;
                          final updatedStr = _formatTimeAgo(draft.updatedAt);

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF121216)
                                    : const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    previewUrl != null &&
                                        previewUrl.startsWith('http')
                                    ? Image.network(
                                        previewUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            title: Text(
                              capPreview,
                              style: TextStyle(
                                color: primaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '$count media • Updated $updatedStr',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _confirmDeleteDraft(context, draft.id),
                            ),
                            onTap: () {
                              ref
                                  .read(uploadPostProvider.notifier)
                                  .restoreDraft(draft);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Draft restored successfully'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteDraft(BuildContext context, String id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0C0C0F) : Colors.white,
        title: Text(
          'Delete Draft',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: const Text(
          'Are you sure you want to delete this draft forever?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(uploadDraftsProvider.notifier).deleteDraft(id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drafts sheet to refresh
              _showDraftsSheet(context); // Reopen drafts sheet
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
