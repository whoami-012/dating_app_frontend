import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/selected_media.dart';
import '../models/upload_post_state.dart';
import '../models/draft.dart';
import '../../home/providers/home_provider.dart';
import '../../home/models/feed_post.dart';
import '../utils/media_helper.dart';

final uploadPostProvider =
    NotifierProvider<UploadPostNotifier, UploadPostState>(
      UploadPostNotifier.new,
    );

final uploadDraftsProvider =
    NotifierProvider<UploadDraftsNotifier, List<UploadDraft>>(
      UploadDraftsNotifier.new,
    );

class UploadDraftsNotifier extends Notifier<List<UploadDraft>> {
  late SharedPreferences _prefs;
  static const String _draftsKey = 'dating_app_upload_drafts';

  @override
  List<UploadDraft> build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    // Return initial list from loading
    try {
      final list = _prefs.getStringList(_draftsKey);
      if (list != null) {
        return list
            .map((item) => UploadDraft.fromJson(json.decode(item)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  void _loadDrafts() {
    try {
      final list = _prefs.getStringList(_draftsKey);
      if (list != null) {
        state = list
            .map((item) => UploadDraft.fromJson(json.decode(item)))
            .toList();
      }
    } catch (e) {
      state = [];
    }
  }

  Future<void> saveDraft(UploadDraft draft) async {
    // Check if draft already exists
    final index = state.indexWhere((d) => d.id == draft.id);
    List<UploadDraft> newState;
    if (index >= 0) {
      newState = List.from(state)..[index] = draft;
    } else {
      newState = [draft, ...state];
    }
    state = newState;
    await _syncToPrefs();
  }

  Future<void> deleteDraft(String id) async {
    final draftIndex = state.indexWhere((d) => d.id == id);
    if (draftIndex >= 0) {
      final draft = state[draftIndex];
      for (final media in draft.selectedMedia) {
        MediaHelper.deleteMediaFiles(media);
      }
    }
    state = state.where((d) => d.id != id).toList();
    await _syncToPrefs();
  }

  Future<void> _syncToPrefs() async {
    try {
      final list = state.map((d) => json.encode(d.toJson())).toList();
      await _prefs.setStringList(_draftsKey, list);
    } catch (_) {}
  }
}

class UploadPostNotifier extends Notifier<UploadPostState> {
  // Pre-defined set of beautiful mock files to simulate gallery selections
  static final List<SelectedMedia> mockPhotos = List.generate(
    10,
    (index) => SelectedMedia(
      id: 'mock_photo_${index + 1}',
      path: [
        'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=600&auto=format&fit=crop',
      ][index],
      isVideo: false,
    ),
  );

  static final SelectedMedia mockShortVideo = SelectedMedia(
    id: 'mock_video_short',
    path:
        'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-city-40011-large.mp4',
    isVideo: true,
    duration: const Duration(seconds: 45),
    thumbnailPath:
        'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
  );

  static final SelectedMedia mockLongVideo = SelectedMedia(
    id: 'mock_video_long',
    path:
        'https://assets.mixkit.co/videos/preview/mixkit-concert-crowd-raising-hands-12885-large.mp4',
    isVideo: true,
    duration: const Duration(
      seconds: 75,
    ), // > 60s, will trigger validation error
    thumbnailPath:
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=600&auto=format&fit=crop',
  );

  @override
  UploadPostState build() {
    return const UploadPostState();
  }

  void addMedia(SelectedMedia media) {
    if (state.status == UploadStatus.uploading) return;

    // 1. Validation: Prevent mixing
    if (media.isVideo) {
      if (state.selectedMedia.any((m) => !m.isVideo)) {
        state = state.copyWith(
          errorMessage: 'Cannot mix photos and videos. Remove photos first.',
        );
        return;
      }
      if (state.selectedMedia.length >= 1) {
        state = state.copyWith(
          errorMessage: 'Only 1 video can be uploaded at a time.',
        );
        return;
      }
      // 2. Validation: Video duration maximum 60 seconds
      if (media.duration != null && media.duration!.inSeconds > 60) {
        state = state.copyWith(
          errorMessage: 'Video exceeds maximum duration of 60 seconds.',
        );
        return;
      }
    } else {
      if (state.selectedMedia.any((m) => m.isVideo)) {
        state = state.copyWith(
          errorMessage: 'Cannot mix photos and videos. Remove the video first.',
        );
        return;
      }
      // 3. Validation: Maximum 10 photos
      if (state.selectedMedia.length >= 10) {
        state = state.copyWith(errorMessage: 'Maximum of 10 photos allowed.');
        return;
      }
    }

    state = state.copyWith(
      selectedMedia: [...state.selectedMedia, media],
      errorMessage: null, // Clear error on success
    );
    _triggerAutosave();
  }

  void removeMedia(String id) {
    if (state.status == UploadStatus.uploading) return;

    final mediaToRemove = state.selectedMedia.firstWhere((m) => m.id == id);
    MediaHelper.deleteMediaFiles(mediaToRemove);

    state = state.copyWith(
      selectedMedia: state.selectedMedia.where((m) => m.id != id).toList(),
      errorMessage: null,
    );
    _triggerAutosave();
  }

  void reorderMedia(int oldIndex, int newIndex) {
    if (state.status == UploadStatus.uploading) return;

    final mediaList = List<SelectedMedia>.from(state.selectedMedia);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = mediaList.removeAt(oldIndex);
    mediaList.insert(newIndex, item);

    state = state.copyWith(selectedMedia: mediaList);
    _triggerAutosave();
  }

  void updateCaption(String val) {
    if (state.status == UploadStatus.uploading) return;

    // Counter updates in real time, but enforce 300 characters limit
    final truncated = val.length > 300 ? val.substring(0, 300) : val;
    state = state.copyWith(caption: truncated);
    _triggerAutosave();
  }

  void toggleTag(String tag) {
    if (state.status == UploadStatus.uploading) return;

    final tags = List<String>.from(state.tags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(tags: tags);
  }

  void setTags(List<String> tags) {
    if (state.status == UploadStatus.uploading) return;
    state = state.copyWith(tags: tags);
  }

  void setVisibility(String visibility) {
    if (state.status == UploadStatus.uploading) return;
    state = state.copyWith(visibility: visibility);
    _triggerAutosave();
  }

  void setLocation(String? location) {
    if (state.status == UploadStatus.uploading) return;
    state = state.copyWith(location: location ?? '');
    _triggerAutosave();
  }

  void setAdvancedSettings({
    bool? allowComments,
    bool? allowSharing,
    bool? allowSaving,
    bool? showLikeCount,
    bool? hideLocation,
    bool? contentWarning,
    bool? disableRemix,
  }) {
    if (state.status == UploadStatus.uploading) return;
    state = state.copyWith(
      allowComments: allowComments,
      allowSharing: allowSharing,
      allowSaving: allowSaving,
      showLikeCount: showLikeCount,
      hideLocation: hideLocation,
      contentWarning: contentWarning,
      disableRemix: disableRemix,
    );
  }

  void clearErrorMessage() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    for (final media in state.selectedMedia) {
      MediaHelper.deleteMediaFiles(media);
    }
    state = const UploadPostState();
  }

  // Drafts save and restore
  void saveAsDraft() {
    if (state.selectedMedia.isEmpty && state.caption.isEmpty)
      return; // Do not save empty drafts

    final draft = UploadDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      selectedMedia: state.selectedMedia,
      caption: state.caption,
      tags: state.tags,
      visibility: state.visibility,
      location: state.location,
      updatedAt: DateTime.now(),
      allowComments: state.allowComments,
      allowSharing: state.allowSharing,
      allowSaving: state.allowSaving,
      showLikeCount: state.showLikeCount,
      hideLocation: state.hideLocation,
      contentWarning: state.contentWarning,
      disableRemix: state.disableRemix,
    );

    ref.read(uploadDraftsProvider.notifier).saveDraft(draft);
  }

  void restoreDraft(UploadDraft draft) {
    for (final media in state.selectedMedia) {
      MediaHelper.deleteMediaFiles(media);
    }
    state = UploadPostState(
      selectedMedia: draft.selectedMedia,
      caption: draft.caption,
      tags: draft.tags,
      visibility: draft.visibility,
      location: draft.location,
      allowComments: draft.allowComments,
      allowSharing: draft.allowSharing,
      allowSaving: draft.allowSaving,
      showLikeCount: draft.showLikeCount,
      hideLocation: draft.hideLocation,
      contentWarning: draft.contentWarning,
      disableRemix: draft.disableRemix,
      status: UploadStatus.idle,
      progress: 0.0,
      errorMessage: null,
    );
  }

  void _triggerAutosave() {
    if (state.selectedMedia.isEmpty && state.caption.isEmpty) return;
    // Debounce or just save directly since SharedPreferences is fast enough
    saveAsDraft();
  }

  Future<bool> uploadPost() async {
    if (state.selectedMedia.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please select at least one media file.',
      );
      return false;
    }
    if (state.status == UploadStatus.uploading) return false;

    state = state.copyWith(
      status: UploadStatus.uploading,
      progress: 0.0,
      clearError: true,
    );

    try {
      // Simulate network request progress
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 150));

        // Safety check if user cleared state or cancelled
        if (state.status != UploadStatus.uploading) return false;

        // Custom fail condition to test failures and retries
        if (state.caption.toLowerCase() == 'trigger failure' && i == 5) {
          throw Exception('Network connection timed out. Please try again.');
        }

        state = state.copyWith(progress: i * 0.1);
      }

      final firstMedia = state.selectedMedia.first;
      final newPost = FeedPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        author: 'vianjgd',
        authorAvatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
        mediaUrl: firstMedia.isVideo && firstMedia.thumbnailPath != null
            ? firstMedia.thumbnailPath!
            : firstMedia.path,
        videoUrl: firstMedia.isVideo ? firstMedia.path : null,
        isVideo: firstMedia.isVideo,
        isLive: false,
        viewerCount: '0',
        likeCount: 0,
        commentCount: 0,
        shareCount: 0,
        bookmarkCount: 0,
        caption: state.caption,
        isLiked: false,
        isBookmarked: false,
      );

      state = state.copyWith(status: UploadStatus.success, progress: 1.0);

      ref.read(homeProvider.notifier).addPost(newPost);

      // Post succeeded: clear form
      reset();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: UploadStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}
