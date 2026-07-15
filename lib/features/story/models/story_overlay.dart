import 'dart:convert';

enum StoryOverlayType {
  text,
  sticker,
  music,
}

class StoryOverlay {
  final String id;
  final StoryOverlayType type;
  final double x;
  final double y;
  final double scale;
  final double rotation;

  // Text fields
  final String? text;
  final String? colorHex;
  final String? fontStyle;
  final double? fontSize;
  final String? textStyle; // 'normal', 'background', 'outline'

  // Sticker fields
  final String? stickerPath; // asset path, network URL, or Emoji string
  final String? stickerType; // 'emoji', 'gif', 'poll', 'location', 'hashtag'

  const StoryOverlay({
    required this.id,
    required this.type,
    this.x = 150.0,
    this.y = 250.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.text,
    this.colorHex,
    this.fontStyle,
    this.fontSize,
    this.textStyle,
    this.stickerPath,
    this.stickerType,
  });

  StoryOverlay copyWith({
    String? id,
    StoryOverlayType? type,
    double? x,
    double? y,
    double? scale,
    double? rotation,
    String? text,
    String? colorHex,
    String? fontStyle,
    double? fontSize,
    String? textStyle,
    String? stickerPath,
    String? stickerType,
  }) {
    return StoryOverlay(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      text: text ?? this.text,
      colorHex: colorHex ?? this.colorHex,
      fontStyle: fontStyle ?? this.fontStyle,
      fontSize: fontSize ?? this.fontSize,
      textStyle: textStyle ?? this.textStyle,
      stickerPath: stickerPath ?? this.stickerPath,
      stickerType: stickerType ?? this.stickerType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'x': x,
      'y': y,
      'scale': scale,
      'rotation': rotation,
      if (text != null) 'text': text,
      if (colorHex != null) 'colorHex': colorHex,
      if (fontStyle != null) 'fontStyle': fontStyle,
      if (fontSize != null) 'fontSize': fontSize,
      if (textStyle != null) 'textStyle': textStyle,
      if (stickerPath != null) 'stickerPath': stickerPath,
      if (stickerType != null) 'stickerType': stickerType,
    };
  }

  factory StoryOverlay.fromJson(Map<String, dynamic> json) {
    return StoryOverlay(
      id: json['id'] as String,
      type: StoryOverlayType.values.byName(json['type'] as String),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      scale: (json['scale'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
      text: json['text'] as String?,
      colorHex: json['colorHex'] as String?,
      fontStyle: json['fontStyle'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      textStyle: json['textStyle'] as String?,
      stickerPath: json['stickerPath'] as String?,
      stickerType: json['stickerType'] as String?,
    );
  }
}
