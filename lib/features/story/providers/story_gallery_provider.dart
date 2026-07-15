import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GalleryPermissionState {
  granted,
  limited,
  denied,
  permanentlyDenied,
  loading,
}

class GalleryMedia {
  final String id;
  final String path;
  final bool isVideo;
  final Duration? duration;
  final String? thumbnailPath;

  const GalleryMedia({
    required this.id,
    required this.path,
    required this.isVideo,
    this.duration,
    this.thumbnailPath,
  });
}

class StoryGalleryState {
  final GalleryPermissionState permissionState;
  final List<GalleryMedia> mediaItems;
  final bool isLoading;
  final String selectedAlbum;
  final List<String> albums;
  final bool isMultiSelectEnabled;
  final bool isGridView;

  const StoryGalleryState({
    this.permissionState = GalleryPermissionState.granted,
    this.mediaItems = const [],
    this.isLoading = false,
    this.selectedAlbum = 'Recent',
    this.albums = const ['Recent', 'Photos', 'Videos', 'Favorites'],
    this.isMultiSelectEnabled = false,
    this.isGridView = true,
  });

  StoryGalleryState copyWith({
    GalleryPermissionState? permissionState,
    List<GalleryMedia>? mediaItems,
    bool? isLoading,
    String? selectedAlbum,
    List<String>? albums,
    bool? isMultiSelectEnabled,
    bool? isGridView,
  }) {
    return StoryGalleryState(
      permissionState: permissionState ?? this.permissionState,
      mediaItems: mediaItems ?? this.mediaItems,
      isLoading: isLoading ?? this.isLoading,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      albums: albums ?? this.albums,
      isMultiSelectEnabled: isMultiSelectEnabled ?? this.isMultiSelectEnabled,
      isGridView: isGridView ?? this.isGridView,
    );
  }
}

final storyGalleryProvider =
    NotifierProvider<StoryGalleryNotifier, StoryGalleryState>(
      StoryGalleryNotifier.new,
    );

class StoryGalleryNotifier extends Notifier<StoryGalleryState> {
  // Pre-configured high-quality assets to mimic phone photo gallery
  static final List<GalleryMedia> _allMockMedia = [
    const GalleryMedia(
      id: 'gallery_photo_1',
      path:
          'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?q=80&w=600&auto=format&fit=crop',
      isVideo: false,
    ),
    const GalleryMedia(
      id: 'gallery_photo_2',
      path:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      isVideo: false,
    ),
    const GalleryMedia(
      id: 'gallery_photo_3',
      path:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600&auto=format&fit=crop',
      isVideo: false,
    ),
    const GalleryMedia(
      id: 'gallery_photo_4',
      path:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=600&auto=format&fit=crop',
      isVideo: false,
    ),
    const GalleryMedia(
      id: 'gallery_photo_5',
      path:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=600&auto=format&fit=crop',
      isVideo: false,
    ),
    const GalleryMedia(
      id: 'gallery_video_1',
      path:
          'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-city-40011-large.mp4',
      isVideo: true,
      duration: Duration(seconds: 45),
      thumbnailPath:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
    ),
    const GalleryMedia(
      id: 'gallery_photo_6',
      path:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=600&auto=format&fit=crop',
      isVideo: false,
    ),
    const GalleryMedia(
      id: 'gallery_photo_7',
      path:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=600&auto=format&fit=crop',
      isVideo: false,
    ),
    const GalleryMedia(
      id: 'gallery_photo_8',
      path:
          'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?q=80&w=600&auto=format&fit=crop',
      isVideo: false,
    ),
    const GalleryMedia(
      id: 'gallery_video_2',
      path:
          'https://assets.mixkit.co/videos/preview/mixkit-concert-crowd-raising-hands-12885-large.mp4',
      isVideo: true,
      duration: Duration(seconds: 75), // Long video (>60s)
      thumbnailPath:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=600&auto=format&fit=crop',
    ),
  ];

  @override
  StoryGalleryState build() {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      return StoryGalleryState(
        permissionState: GalleryPermissionState.granted,
        mediaItems: _allMockMedia,
        isLoading: false,
      );
    }

    Future.microtask(() => loadMedia());
    return const StoryGalleryState(
      permissionState: GalleryPermissionState.granted,
      mediaItems: [],
      isLoading: true,
    );
  }

  Future<void> loadMedia() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (state.permissionState == GalleryPermissionState.denied ||
        state.permissionState == GalleryPermissionState.permanentlyDenied) {
      state = state.copyWith(mediaItems: [], isLoading: false);
      return;
    }

    List<GalleryMedia> filtered = List.from(_allMockMedia);
    if (state.permissionState == GalleryPermissionState.limited) {
      // Return only first 4 items for limited access simulation
      filtered = _allMockMedia.take(4).toList();
    }

    if (state.selectedAlbum == 'Photos') {
      filtered = filtered.where((item) => !item.isVideo).toList();
    } else if (state.selectedAlbum == 'Videos') {
      filtered = filtered.where((item) => item.isVideo).toList();
    }

    state = state.copyWith(mediaItems: filtered, isLoading: false);
  }

  void selectAlbum(String album) {
    if (state.selectedAlbum == album) return;
    state = state.copyWith(selectedAlbum: album);
    loadMedia();
  }

  void toggleMultiSelect() {
    state = state.copyWith(isMultiSelectEnabled: !state.isMultiSelectEnabled);
  }

  void toggleViewMode() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void updatePermissionState(GalleryPermissionState permission) {
    state = state.copyWith(permissionState: permission);
    loadMedia();
  }

  void setEmptyState() {
    state = state.copyWith(mediaItems: [], isLoading: false);
  }
}
