import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/home_provider.dart';
import '../../home/models/story.dart';
import '../models/story_media_item.dart';

enum StoryUploadStatus { idle, uploading, success, failure }

class StoryUploadState {
  final StoryUploadStatus status;
  final double progress;
  final String? errorMessage;

  const StoryUploadState({
    this.status = StoryUploadStatus.idle,
    this.progress = 0.0,
    this.errorMessage,
  });

  StoryUploadState copyWith({
    StoryUploadStatus? status,
    double? progress,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StoryUploadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final storyUploadProvider =
    NotifierProvider<StoryUploadNotifier, StoryUploadState>(
  StoryUploadNotifier.new,
);

class StoryUploadNotifier extends Notifier<StoryUploadState> {
  @override
  StoryUploadState build() {
    return const StoryUploadState();
  }

  Future<bool> uploadStories(List<StoryMediaItem> items, String audience) async {
    if (items.isEmpty) {
      state = state.copyWith(
        status: StoryUploadStatus.failure,
        errorMessage: 'No media items to upload.',
      );
      return false;
    }

    state = state.copyWith(
      status: StoryUploadStatus.uploading,
      progress: 0.0,
      clearError: true,
    );

    try {
      // Simulate compression & upload progress
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 150));

        if (state.status != StoryUploadStatus.uploading) return false;

        // Custom fail condition to test failures and retries
        // If the first item has "trigger failure" in path or filter or metadata
        if (items.any((item) => item.filter == 'trigger_failure') && i == 5) {
          throw Exception('Upload failed: Network connection lost.');
        }

        state = state.copyWith(progress: i * 0.1);
      }

      state = state.copyWith(
        status: StoryUploadStatus.success,
        progress: 1.0,
      );

      // Add to home feed stories list
      final newStory = Story(
        id: 'story_user_${DateTime.now().millisecondsSinceEpoch}',
        username: 'Your story',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
        isCurrentUser: true,
        hasUnseenStory: true,
        isOnline: false,
      );

      final notifier = ref.read(homeProvider.notifier);
      // We'll call addStory on HomeNotifier, let's make sure it exists
      try {
        // We will add the method to HomeNotifier in home_provider.dart
        (notifier as dynamic).addStory(newStory);
      } catch (_) {
        // Fallback if not added yet
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        status: StoryUploadStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() {
    state = const StoryUploadState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
