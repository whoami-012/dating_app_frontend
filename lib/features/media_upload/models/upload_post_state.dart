import 'selected_media.dart';

enum UploadStatus { idle, uploading, success, failure }

class UploadPostState {
  final List<SelectedMedia> selectedMedia;
  final String caption;
  final List<String> tags;
  final String visibility;
  final String? location;

  // Advanced settings
  final bool allowComments;
  final bool allowSharing;
  final bool allowSaving;
  final bool showLikeCount;
  final bool hideLocation;
  final bool contentWarning;
  final bool disableRemix;

  // Upload progress/status
  final UploadStatus status;
  final double progress; // 0.0 to 1.0
  final String? errorMessage;

  const UploadPostState({
    this.selectedMedia = const [],
    this.caption = '',
    this.tags = const [],
    this.visibility = 'Only your followers',
    this.location,
    this.allowComments = true,
    this.allowSharing = true,
    this.allowSaving = true,
    this.showLikeCount = true,
    this.hideLocation = false,
    this.contentWarning = false,
    this.disableRemix = false,
    this.status = UploadStatus.idle,
    this.progress = 0.0,
    this.errorMessage,
  });

  UploadPostState copyWith({
    List<SelectedMedia>? selectedMedia,
    String? caption,
    List<String>? tags,
    String? visibility,
    String? location,
    bool? allowComments,
    bool? allowSharing,
    bool? allowSaving,
    bool? showLikeCount,
    bool? hideLocation,
    bool? contentWarning,
    bool? disableRemix,
    UploadStatus? status,
    double? progress,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UploadPostState(
      selectedMedia: selectedMedia ?? this.selectedMedia,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      location: location == null
          ? this.location
          : (location.isEmpty ? null : location),
      allowComments: allowComments ?? this.allowComments,
      allowSharing: allowSharing ?? this.allowSharing,
      allowSaving: allowSaving ?? this.allowSaving,
      showLikeCount: showLikeCount ?? this.showLikeCount,
      hideLocation: hideLocation ?? this.hideLocation,
      contentWarning: contentWarning ?? this.contentWarning,
      disableRemix: disableRemix ?? this.disableRemix,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
