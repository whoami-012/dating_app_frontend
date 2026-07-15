import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/story_draft.dart';
import '../models/story_media_item.dart';
import '../models/story_overlay.dart';
import 'story_gallery_provider.dart';

enum StoryTool { text, stickers, draw, crop, music }

class StoryComposerState {
  final List<StoryMediaItem> selectedItems;
  final int activeItemIndex;
  final StoryTool? activeTool;
  final String? errorMessage;
  final bool isLoading;
  final List<StoryDraft> savedDrafts;

  const StoryComposerState({
    this.selectedItems = const [],
    this.activeItemIndex = 0,
    this.activeTool,
    this.errorMessage,
    this.isLoading = false,
    this.savedDrafts = const [],
  });

  StoryMediaItem? get activeItem =>
      selectedItems.isNotEmpty && activeItemIndex < selectedItems.length
      ? selectedItems[activeItemIndex]
      : null;

  StoryComposerState copyWith({
    List<StoryMediaItem>? selectedItems,
    int? activeItemIndex,
    StoryTool? activeTool,
    String? errorMessage,
    bool? isLoading,
    List<StoryDraft>? savedDrafts,
    bool clearError = false,
    bool clearTool = false,
  }) {
    return StoryComposerState(
      selectedItems: selectedItems ?? this.selectedItems,
      activeItemIndex: activeItemIndex ?? this.activeItemIndex,
      activeTool: clearTool ? null : (activeTool ?? this.activeTool),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
      savedDrafts: savedDrafts ?? this.savedDrafts,
    );
  }
}

final storyComposerProvider =
    NotifierProvider<StoryComposerNotifier, StoryComposerState>(
      StoryComposerNotifier.new,
    );

class StoryComposerNotifier extends Notifier<StoryComposerState> {
  late SharedPreferences _prefs;
  static const String _draftsKey = 'dating_app_story_drafts';

  @override
  StoryComposerState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final drafts = _readDraftsFromPrefs();
    return StoryComposerState(savedDrafts: drafts);
  }

  List<StoryDraft> _readDraftsFromPrefs() {
    try {
      final list = _prefs.getStringList(_draftsKey);
      if (list != null) {
        return list
            .map((item) => StoryDraft.fromJson(json.decode(item)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> saveDraft() async {
    if (state.selectedItems.isEmpty) return;

    final newDraft = StoryDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mediaItems: state.selectedItems,
      updatedAt: DateTime.now(),
    );

    final updatedDrafts = [newDraft, ...state.savedDrafts];
    state = state.copyWith(savedDrafts: updatedDrafts);
    await _syncDraftsToPrefs();
  }

  Future<void> deleteDraft(String id) async {
    final updatedDrafts = state.savedDrafts.where((d) => d.id != id).toList();
    state = state.copyWith(savedDrafts: updatedDrafts);
    await _syncDraftsToPrefs();
  }

  Future<void> _syncDraftsToPrefs() async {
    try {
      final list = state.savedDrafts
          .map((d) => json.encode(d.toJson()))
          .toList();
      await _prefs.setStringList(_draftsKey, list);
    } catch (_) {}
  }

  void restoreDraft(StoryDraft draft) {
    state = state.copyWith(
      selectedItems: draft.mediaItems,
      activeItemIndex: 0,
      clearTool: true,
      clearError: true,
    );
  }

  void addGalleryMedia(GalleryMedia media) {
    // Check if item is already selected
    if (state.selectedItems.any((item) => item.path == media.path)) {
      // Remove it (toggle selection)
      removeMediaItem(
        state.selectedItems.firstWhere((item) => item.path == media.path).id,
      );
      return;
    }

    // Limit count (max 10 stories)
    if (state.selectedItems.length >= 10) {
      state = state.copyWith(
        errorMessage: 'You can select a maximum of 10 items.',
      );
      return;
    }

    // Video duration limit check
    if (media.isVideo &&
        media.duration != null &&
        media.duration!.inSeconds > 60) {
      state = state.copyWith(
        errorMessage: 'Video exceeds maximum duration of 60 seconds.',
      );
      return;
    }

    final newItem = StoryMediaItem(
      id: 'story_item_${DateTime.now().millisecondsSinceEpoch}_${state.selectedItems.length}',
      path: media.path,
      isVideo: media.isVideo,
      duration: media.duration,
      thumbnailPath: media.thumbnailPath,
    );

    state = state.copyWith(
      selectedItems: [...state.selectedItems, newItem],
      activeItemIndex: state.selectedItems.length, // switch to newly added item
      clearError: true,
    );
  }

  void removeMediaItem(String id) {
    final index = state.selectedItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final newList = state.selectedItems.where((item) => item.id != id).toList();
    int newActiveIndex = state.activeItemIndex;
    if (newActiveIndex >= newList.length) {
      newActiveIndex = newList.isEmpty ? 0 : newList.length - 1;
    }

    state = state.copyWith(
      selectedItems: newList,
      activeItemIndex: newActiveIndex,
      clearError: true,
    );
  }

  void reorderMedia(int oldIndex, int newIndex) {
    if (newIndex < 0 || newIndex > state.selectedItems.length) return;
    final list = List<StoryMediaItem>.from(state.selectedItems);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    int newActive = state.activeItemIndex;
    if (state.activeItemIndex == oldIndex) {
      newActive = newIndex;
    } else if (state.activeItemIndex > oldIndex &&
        state.activeItemIndex <= newIndex) {
      newActive--;
    } else if (state.activeItemIndex < oldIndex &&
        state.activeItemIndex >= newIndex) {
      newActive++;
    }

    state = state.copyWith(selectedItems: list, activeItemIndex: newActive);
  }

  void selectItemIndex(int index) {
    if (index < 0 || index >= state.selectedItems.length) return;
    state = state.copyWith(activeItemIndex: index, clearTool: true);
  }

  void setActiveTool(StoryTool? tool) {
    state = state.copyWith(activeTool: tool, clearTool: tool == null);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // --- Overlay operations for active item ---

  void addOverlay(StoryOverlay overlay) {
    final active = state.activeItem;
    if (active == null) return;

    final updatedItem = active.copyWith(
      overlays: [...active.overlays, overlay],
    );

    final updatedItems = List<StoryMediaItem>.from(state.selectedItems);
    updatedItems[state.activeItemIndex] = updatedItem;

    state = state.copyWith(selectedItems: updatedItems);
  }

  void updateOverlay(StoryOverlay overlay) {
    final active = state.activeItem;
    if (active == null) return;

    final updatedOverlays = active.overlays.map((o) {
      return o.id == overlay.id ? overlay : o;
    }).toList();

    final updatedItem = active.copyWith(overlays: updatedOverlays);

    final updatedItems = List<StoryMediaItem>.from(state.selectedItems);
    updatedItems[state.activeItemIndex] = updatedItem;

    state = state.copyWith(selectedItems: updatedItems);
  }

  void removeOverlay(String id) {
    final active = state.activeItem;
    if (active == null) return;

    final updatedOverlays = active.overlays.where((o) => o.id != id).toList();
    final updatedItem = active.copyWith(overlays: updatedOverlays);

    final updatedItems = List<StoryMediaItem>.from(state.selectedItems);
    updatedItems[state.activeItemIndex] = updatedItem;

    state = state.copyWith(selectedItems: updatedItems);
  }

  // --- Music attachment for active item ---

  void attachMusic(StoryMusic music) {
    final active = state.activeItem;
    if (active == null) return;

    final updatedItem = active.copyWith(music: music);

    final updatedItems = List<StoryMediaItem>.from(state.selectedItems);
    updatedItems[state.activeItemIndex] = updatedItem;

    state = state.copyWith(selectedItems: updatedItems);
  }

  void removeMusic() {
    final active = state.activeItem;
    if (active == null) return;

    // To remove, we copy with a null music, but copyWith doesn't support nulling fields directly
    // Let's modify the copyWith in StoryMediaItem or write a custom copy
    final updatedItem = StoryMediaItem(
      id: active.id,
      path: active.path,
      isVideo: active.isVideo,
      duration: active.duration,
      thumbnailPath: active.thumbnailPath,
      overlays: active.overlays,
      music: null, // explicitly null
      rotation: active.rotation,
      scale: active.scale,
      filter: active.filter,
      drawingData: active.drawingData,
      isMuted: active.isMuted,
    );

    final updatedItems = List<StoryMediaItem>.from(state.selectedItems);
    updatedItems[state.activeItemIndex] = updatedItem;

    state = state.copyWith(selectedItems: updatedItems);
  }

  // --- Crop/Drawing/Mute for active item ---

  void updateDrawing(String? drawingData) {
    final active = state.activeItem;
    if (active == null) return;

    final updatedItem = active.copyWith(drawingData: drawingData);
    final updatedItems = List<StoryMediaItem>.from(state.selectedItems);
    updatedItems[state.activeItemIndex] = updatedItem;

    state = state.copyWith(selectedItems: updatedItems);
  }

  void toggleMute() {
    final active = state.activeItem;
    if (active == null) return;

    final updatedItem = active.copyWith(isMuted: !active.isMuted);
    final updatedItems = List<StoryMediaItem>.from(state.selectedItems);
    updatedItems[state.activeItemIndex] = updatedItem;

    state = state.copyWith(selectedItems: updatedItems);
  }

  void applyFilter(String? filter) {
    final active = state.activeItem;
    if (active == null) return;

    final updatedItem = active.copyWith(filter: filter);
    final updatedItems = List<StoryMediaItem>.from(state.selectedItems);
    updatedItems[state.activeItemIndex] = updatedItem;

    state = state.copyWith(selectedItems: updatedItems);
  }

  void applyCropAndTransform({
    required double rotation,
    required double scale,
  }) {
    final active = state.activeItem;
    if (active == null) return;

    final updatedItem = active.copyWith(rotation: rotation, scale: scale);
    final updatedItems = List<StoryMediaItem>.from(state.selectedItems);
    updatedItems[state.activeItemIndex] = updatedItem;

    state = state.copyWith(selectedItems: updatedItems);
  }

  void reset() {
    final drafts = _readDraftsFromPrefs();
    state = StoryComposerState(savedDrafts: drafts);
  }
}
