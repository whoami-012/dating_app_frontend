import 'story_media_item.dart';

class StoryDraft {
  final String id;
  final List<StoryMediaItem> mediaItems;
  final DateTime updatedAt;
  final String visibility;

  const StoryDraft({
    required this.id,
    required this.mediaItems,
    required this.updatedAt,
    this.visibility = 'Everyone',
  });

  StoryDraft copyWith({
    String? id,
    List<StoryMediaItem>? mediaItems,
    DateTime? updatedAt,
    String? visibility,
  }) {
    return StoryDraft(
      id: id ?? this.id,
      mediaItems: mediaItems ?? this.mediaItems,
      updatedAt: updatedAt ?? this.updatedAt,
      visibility: visibility ?? this.visibility,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaItems': mediaItems.map((item) => item.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
      'visibility': visibility,
    };
  }

  factory StoryDraft.fromJson(Map<String, dynamic> json) {
    return StoryDraft(
      id: json['id'] as String,
      mediaItems: (json['mediaItems'] as List<dynamic>)
          .map((item) => StoryMediaItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      visibility: json['visibility'] as String? ?? 'Everyone',
    );
  }
}
