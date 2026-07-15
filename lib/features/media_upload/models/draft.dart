import 'selected_media.dart';

class UploadDraft {
  final String id;
  final List<SelectedMedia> selectedMedia;
  final String caption;
  final List<String> tags;
  final String visibility;
  final String? location;
  final DateTime updatedAt;

  // Advanced settings
  final bool allowComments;
  final bool allowSharing;
  final bool allowSaving;
  final bool showLikeCount;
  final bool hideLocation;
  final bool contentWarning;
  final bool disableRemix;

  const UploadDraft({
    required this.id,
    required this.selectedMedia,
    required this.caption,
    required this.tags,
    required this.visibility,
    this.location,
    required this.updatedAt,
    this.allowComments = true,
    this.allowSharing = true,
    this.allowSaving = true,
    this.showLikeCount = true,
    this.hideLocation = false,
    this.contentWarning = false,
    this.disableRemix = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'selectedMedia': selectedMedia
          .map(
            (m) => {
              'id': m.id,
              'path': m.path,
              'isVideo': m.isVideo,
              'durationMs': m.duration?.inMilliseconds,
              'thumbnailPath': m.thumbnailPath,
            },
          )
          .toList(),
      'caption': caption,
      'tags': tags,
      'visibility': visibility,
      'location': location,
      'updatedAt': updatedAt.toIso8601String(),
      'allowComments': allowComments,
      'allowSharing': allowSharing,
      'allowSaving': allowSaving,
      'showLikeCount': showLikeCount,
      'hideLocation': hideLocation,
      'contentWarning': contentWarning,
      'disableRemix': disableRemix,
    };
  }

  factory UploadDraft.fromJson(Map<String, dynamic> json) {
    return UploadDraft(
      id: json['id'] as String,
      selectedMedia: (json['selectedMedia'] as List<dynamic>)
          .map(
            (m) => SelectedMedia(
              id: m['id'] as String,
              path: m['path'] as String,
              isVideo: m['isVideo'] as bool,
              duration: m['durationMs'] != null
                  ? Duration(milliseconds: m['durationMs'] as int)
                  : null,
              thumbnailPath: m['thumbnailPath'] as String?,
            ),
          )
          .toList(),
      caption: json['caption'] as String,
      tags: List<String>.from(json['tags'] as List<dynamic>),
      visibility: json['visibility'] as String,
      location: json['location'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      allowComments: json['allowComments'] as bool? ?? true,
      allowSharing: json['allowSharing'] as bool? ?? true,
      allowSaving: json['allowSaving'] as bool? ?? true,
      showLikeCount: json['showLikeCount'] as bool? ?? true,
      hideLocation: json['hideLocation'] as bool? ?? false,
      contentWarning: json['contentWarning'] as bool? ?? false,
      disableRemix: json['disableRemix'] as bool? ?? false,
    );
  }
}
