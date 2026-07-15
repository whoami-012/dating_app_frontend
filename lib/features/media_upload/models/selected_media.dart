import 'dart:io';

class SelectedMedia {
  final String id;
  final String path;
  final bool isVideo;
  final Duration? duration;
  final String? thumbnailPath;

  const SelectedMedia({
    required this.id,
    required this.path,
    required this.isVideo,
    this.duration,
    this.thumbnailPath,
  });

  SelectedMedia copyWith({
    String? id,
    String? path,
    bool? isVideo,
    Duration? duration,
    String? thumbnailPath,
  }) {
    return SelectedMedia(
      id: id ?? this.id,
      path: path ?? this.path,
      isVideo: isVideo ?? this.isVideo,
      duration: duration ?? this.duration,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedMedia &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          path == other.path &&
          isVideo == other.isVideo &&
          duration == other.duration &&
          thumbnailPath == other.thumbnailPath;

  @override
  int get hashCode =>
      id.hashCode ^
      path.hashCode ^
      isVideo.hashCode ^
      duration.hashCode ^
      thumbnailPath.hashCode;
}
