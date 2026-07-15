import 'story_overlay.dart';

class StoryMusic {
  final String id;
  final String title;
  final String artist;
  final String? previewUrl;
  final int durationSeconds;
  final int startPointSeconds;

  const StoryMusic({
    required this.id,
    required this.title,
    required this.artist,
    this.previewUrl,
    required this.durationSeconds,
    required this.startPointSeconds,
  });

  StoryMusic copyWith({
    String? id,
    String? title,
    String? artist,
    String? previewUrl,
    int? durationSeconds,
    int? startPointSeconds,
  }) {
    return StoryMusic(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      previewUrl: previewUrl ?? this.previewUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startPointSeconds: startPointSeconds ?? this.startPointSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      if (previewUrl != null) 'previewUrl': previewUrl,
      'durationSeconds': durationSeconds,
      'startPointSeconds': startPointSeconds,
    };
  }

  factory StoryMusic.fromJson(Map<String, dynamic> json) {
    return StoryMusic(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      previewUrl: json['previewUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int,
      startPointSeconds: json['startPointSeconds'] as int,
    );
  }
}

class StoryMediaItem {
  final String id;
  final String path;
  final bool isVideo;
  final Duration? duration;
  final String? thumbnailPath;
  final List<StoryOverlay> overlays;
  final StoryMusic? music;
  final double rotation; // In degrees
  final double scale;
  final String? filter;
  final String? drawingData; // Can hold drawn path SVG path or lines
  final bool isMuted;

  const StoryMediaItem({
    required this.id,
    required this.path,
    required this.isVideo,
    this.duration,
    this.thumbnailPath,
    this.overlays = const [],
    this.music,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.filter,
    this.drawingData,
    this.isMuted = false,
  });

  StoryMediaItem copyWith({
    String? id,
    String? path,
    bool? isVideo,
    Duration? duration,
    String? thumbnailPath,
    List<StoryOverlay>? overlays,
    StoryMusic? music,
    double? rotation,
    double? scale,
    String? filter,
    String? drawingData,
    bool? isMuted,
  }) {
    return StoryMediaItem(
      id: id ?? this.id,
      path: path ?? this.path,
      isVideo: isVideo ?? this.isVideo,
      duration: duration ?? this.duration,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      overlays: overlays ?? this.overlays,
      music: music ?? this.music,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      filter: filter ?? this.filter,
      drawingData: drawingData ?? this.drawingData,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'isVideo': isVideo,
      if (duration != null) 'durationMs': duration!.inMilliseconds,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      'overlays': overlays.map((o) => o.toJson()).toList(),
      if (music != null) 'music': music!.toJson(),
      'rotation': rotation,
      'scale': scale,
      if (filter != null) 'filter': filter,
      if (drawingData != null) 'drawingData': drawingData,
      'isMuted': isMuted,
    };
  }

  factory StoryMediaItem.fromJson(Map<String, dynamic> json) {
    return StoryMediaItem(
      id: json['id'] as String,
      path: json['path'] as String,
      isVideo: json['isVideo'] as bool,
      duration: json['durationMs'] != null
          ? Duration(milliseconds: json['durationMs'] as int)
          : null,
      thumbnailPath: json['thumbnailPath'] as String?,
      overlays: (json['overlays'] as List<dynamic>?)
              ?.map((o) => StoryOverlay.fromJson(o as Map<String, dynamic>))
              .toList() ??
          const [],
      music: json['music'] != null
          ? StoryMusic.fromJson(json['music'] as Map<String, dynamic>)
          : null,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      filter: json['filter'] as String?,
      drawingData: json['drawingData'] as String?,
      isMuted: json['isMuted'] as bool? ?? false,
    );
  }
}
