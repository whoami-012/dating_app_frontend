import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/story_media_item.dart';
import '../models/story_overlay.dart';
import '../providers/story_composer_provider.dart';
import '../providers/story_gallery_provider.dart';
import 'story_tool_rail.dart';

class DrawingLine {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  const DrawingLine({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': color.value,
      'strokeWidth': strokeWidth,
    };
  }

  factory DrawingLine.fromJson(Map<String, dynamic> json) {
    final list = json['points'] as List<dynamic>;
    return DrawingLine(
      points: list.map((p) => Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble())).toList(),
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
    );
  }
}

class StoryCanvas extends ConsumerStatefulWidget {
  final StoryMediaItem item;
  final bool isLeftHanded;
  final double? canvasWidth;
  final double? canvasHeight;

  const StoryCanvas({
    super.key,
    required this.item,
    this.isLeftHanded = false,
    this.canvasWidth,
    this.canvasHeight,
  });

  @override
  ConsumerState<StoryCanvas> createState() => _StoryCanvasState();
}

class _StoryCanvasState extends ConsumerState<StoryCanvas> {
  // Video player variables
  VideoPlayerController? _videoController;
  bool _isPlayerInitialized = false;

  // Drawing state
  List<DrawingLine> _drawingLines = [];
  DrawingLine? _currentLine;
  Color _brushColor = const Color(0xFFD1FF2F);
  double _brushSize = 6.0;

  // Gesture/Dragging variables
  String? _draggingOverlayId;
  bool _isHoveringTrash = false;
  bool _showSnappingGuides = false;
  bool _snappedX = false;
  bool _snappedY = false;

  // Scale/rotation gesture parameters
  Offset? _dragOffset;

  @override
  void initState() {
    super.initState();
    if (widget.item.isVideo) {
      _initVideo();
    }
    _loadDrawing();
  }

  @override
  void didUpdateWidget(covariant StoryCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.path != widget.item.path) {
      if (widget.item.isVideo) {
        _initVideo();
      } else {
        _disposeVideo();
      }
    }
    if (oldWidget.item.drawingData != widget.item.drawingData) {
      _loadDrawing();
    }
  }

  void _loadDrawing() {
    if (widget.item.drawingData != null) {
      try {
        final decoded = json.decode(widget.item.drawingData!) as List<dynamic>;
        setState(() {
          _drawingLines = decoded
              .map((line) => DrawingLine.fromJson(line as Map<String, dynamic>))
              .toList();
        });
      } catch (_) {}
    } else {
      setState(() {
        _drawingLines = [];
      });
    }
  }

  void _saveDrawing() {
    final encoded = json.encode(_drawingLines.map((l) => l.toJson()).toList());
    ref.read(storyComposerProvider.notifier).updateDrawing(encoded);
  }

  Future<void> _initVideo() async {
    await _disposeVideo();
    final isNetwork = widget.item.path.startsWith('http://') ||
        widget.item.path.startsWith('https://');

    _videoController = isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.item.path))
        : VideoPlayerController.file(File(widget.item.path));

    try {
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(widget.item.isMuted ? 0.0 : 1.0);
      await _videoController!.play();
      if (mounted) {
        setState(() {
          _isPlayerInitialized = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _disposeVideo() async {
    if (_videoController != null) {
      try {
        await _videoController!.pause();
      } catch (_) {}
      await _videoController!.dispose();
      _videoController = null;
      if (mounted) {
        setState(() {
          _isPlayerInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTool = ref.watch(storyComposerProvider).activeTool;
    final size = MediaQuery.of(context).size;

    // Responsive sizing constraints (use parameters if provided, else fallback)
    final double computedHeight = widget.canvasHeight ?? (size.height * 0.5);
    final double computedWidth = widget.canvasWidth ?? (computedHeight * 9 / 16);

    return Center(
      child: Container(
        width: computedWidth,
        height: computedHeight,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Media Background Layer
              _buildBackgroundMedia(),

              // 2. Filter Overlay Layer
              _buildFilterOverlay(),

              // 3. Drawing Painter Layer (under interactive widgets if not drawing)
              Semantics(
                label: 'Drawing Layer',
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: StoryDrawingPainter(
                      lines: _drawingLines,
                      currentLine: _currentLine,
                    ),
                    size: Size(computedWidth, computedHeight),
                  ),
                ),
              ),

              // 4. Overlays interactive layer
              ...widget.item.overlays.map((o) => _buildInteractiveOverlay(o, computedWidth, computedHeight)),

              // 5. Drawing Gesture capture (visible only in drawing mode)
              if (activeTool == StoryTool.draw) _buildDrawingGestureOverlay(),

              // 6. Snapping Guides
              if (_showSnappingGuides) ...[
                if (_snappedX)
                  Center(
                    child: Container(
                      width: 1,
                      color: const Color(0xFFD1FF2F).withOpacity(0.8),
                    ),
                  ),
                if (_snappedY)
                  Center(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFD1FF2F).withOpacity(0.8),
                    ),
                  ),
              ],

              // 7. Drawing active controls bar
              if (activeTool == StoryTool.draw) _buildDrawingToolbar(),

              // 8. Music Attachment banner chip (if music attached)
              if (widget.item.music != null) _buildMusicChip(),

              // 9. Floating Tool Rail
              StoryToolRail(
                activeTool: activeTool,
                isLeftHanded: widget.isLeftHanded,
                onToolSelected: (tool) {
                  ref.read(storyComposerProvider.notifier).setActiveTool(tool);
                },
              ),

              // 10. Trash area visible while dragging overlays
              if (_draggingOverlayId != null) _buildTrashArea(computedWidth, computedHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundMedia() {
    if (widget.item.isVideo) {
      if (_isPlayerInitialized && _videoController != null) {
        return GestureDetector(
          onTap: () {
            ref.read(storyComposerProvider.notifier).toggleMute();
            _videoController!.setVolume(widget.item.isMuted ? 0.0 : 1.0);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayer(_videoController!),
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.item.isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: const Color(0xFFD1FF2F),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // Thumbnail placeholder
        return widget.item.thumbnailPath != null
            ? Image.network(
                widget.item.thumbnailPath!,
                fit: BoxFit.cover,
              )
            : const Center(
                child: CircularProgressIndicator(color: Color(0xFFD1FF2F)),
              );
      }
    } else {
      final isNetwork = widget.item.path.startsWith('http://') ||
          widget.item.path.startsWith('https://');
      return isNetwork
          ? Image.network(
              widget.item.path,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(widget.item.path),
              fit: BoxFit.cover,
            );
    }
  }

  Widget _buildFilterOverlay() {
    if (widget.item.filter == null) return const SizedBox.shrink();

    Color filterColor;
    BlendMode blendMode = BlendMode.color;

    switch (widget.item.filter) {
      case 'grayscale':
        return const ColorFiltered(
          colorFilter: ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ]),
          child: SizedBox.shrink(),
        );
      case 'sepia':
        filterColor = const Color(0xFF704214).withOpacity(0.35);
        blendMode = BlendMode.color;
        break;
      case 'vintage':
        filterColor = const Color(0xFFFFB300).withOpacity(0.18);
        blendMode = BlendMode.multiply;
        break;
      case 'neon':
        filterColor = const Color(0xFFFF0055).withOpacity(0.2);
        blendMode = BlendMode.colorBurn;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      color: filterColor,
      child: Center(
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildInteractiveOverlay(
      StoryOverlay overlay, double canvasWidth, double canvasHeight) {
    final activeTool = ref.watch(storyComposerProvider).activeTool;
    final isEditingText = activeTool == StoryTool.text;

    return Positioned(
      left: overlay.x,
      top: overlay.y,
      child: GestureDetector(
        onScaleStart: (details) {
          setState(() {
            _draggingOverlayId = overlay.id;
            _showSnappingGuides = true;
          });
        },
        onScaleUpdate: (details) {
          final double newX = overlay.x + details.focalPointDelta.dx;
          final double newY = overlay.y + details.focalPointDelta.dy;

          // Snapping thresholds
          final bool isNearCenterX = (newX + 50 - canvasWidth / 2).abs() < 10;
          final bool isNearCenterY = (newY + 16 - canvasHeight / 2).abs() < 10;

          final finalX = isNearCenterX ? canvasWidth / 2 - 50 : newX;
          final finalY = isNearCenterY ? canvasHeight / 2 - 16 : newY;

          // Trash area overlap check
          final double trashTop = canvasHeight - 75;
          final double trashCenterX = canvasWidth / 2;
          final double overlayCenterX = finalX + 50;
          final double overlayCenterY = finalY + 16;
          final bool nearTrash = (overlayCenterX - trashCenterX).abs() < 40 &&
              (overlayCenterY - trashTop).abs() < 40;

          setState(() {
            _snappedX = isNearCenterX;
            _snappedY = isNearCenterY;
            _isHoveringTrash = nearTrash;
          });

          ref.read(storyComposerProvider.notifier).updateOverlay(
                overlay.copyWith(
                  x: finalX,
                  y: finalY,
                  scale: (overlay.scale * details.scale).clamp(0.5, 3.5),
                  rotation: overlay.rotation + details.rotation,
                ),
              );
        },
        onScaleEnd: (details) {
          setState(() {
            _showSnappingGuides = false;
            _draggingOverlayId = null;
          });

          if (_isHoveringTrash) {
            ref.read(storyComposerProvider.notifier).removeOverlay(overlay.id);
            setState(() {
              _isHoveringTrash = false;
            });
          }
        },
        onTap: () {
          if (overlay.type == StoryOverlayType.text) {
            // Re-edit text
            ref.read(storyComposerProvider.notifier).setActiveTool(StoryTool.text);
          }
        },
        child: Transform.rotate(
          angle: overlay.rotation,
          child: Transform.scale(
            scale: overlay.scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: overlay.textStyle == 'background'
                    ? (overlay.colorHex != null
                        ? Color(int.parse(overlay.colorHex!))
                        : Colors.black.withOpacity(0.7))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _draggingOverlayId == overlay.id
                      ? const Color(0xFFD1FF2F).withOpacity(0.5)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: overlay.type == StoryOverlayType.text
                  ? Text(
                      overlay.text ?? '',
                      style: TextStyle(
                        color: overlay.textStyle == 'background'
                            ? Colors.white
                            : (overlay.colorHex != null
                                ? Color(int.parse(overlay.colorHex!))
                                : Colors.white),
                        fontSize: overlay.fontSize ?? 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      overlay.stickerPath ?? '😀',
                      style: const TextStyle(fontSize: 32),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawingGestureOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onPanStart: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.globalPosition);

          setState(() {
            _currentLine = DrawingLine(
              points: [localPosition],
              color: _brushColor,
              strokeWidth: _brushSize,
            );
          });
        },
        onPanUpdate: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.globalPosition);

          if (_currentLine != null) {
            final List<Offset> points = List.from(_currentLine!.points)
              ..add(localPosition);
            setState(() {
              _currentLine = DrawingLine(
                points: points,
                color: _brushColor,
                strokeWidth: _brushSize,
              );
            });
          }
        },
        onPanEnd: (details) {
          if (_currentLine != null) {
            setState(() {
              _drawingLines = List.from(_drawingLines)..add(_currentLine!);
              _currentLine = null;
            });
            _saveDrawing();
          }
        },
      ),
    );
  }

  Widget _buildDrawingToolbar() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (_drawingLines.isNotEmpty) {
                  setState(() {
                    _drawingLines = List.from(_drawingLines)..removeLast();
                  });
                  _saveDrawing();
                }
              },
              child: const Icon(Icons.undo, color: Colors.white, size: 20),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _drawingLines = [];
                });
                _saveDrawing();
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            // Minimal color selectors
            ...[const Color(0xFFD1FF2F), Colors.white, Colors.redAccent, Colors.blueAccent]
                .map((color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _brushColor = color;
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: _brushColor == color ? Colors.white : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                      ),
                    )),
            GestureDetector(
              onTap: () {
                ref.read(storyComposerProvider.notifier).setActiveTool(null);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Color(0xFFD1FF2F),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicChip() {
    final music = widget.item.music!;
    return Positioned(
      bottom: 24,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD1FF2F).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_note, color: Color(0xFFD1FF2F), size: 14),
            const SizedBox(width: 6),
            Text(
              '${music.title} - ${music.artist}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrashArea(double canvasWidth, double canvasHeight) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: _isHoveringTrash ? 64 : 52,
          height: _isHoveringTrash ? 64 : 52,
          decoration: BoxDecoration(
            color: _isHoveringTrash ? Colors.redAccent : Colors.black.withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isHoveringTrash ? Colors.transparent : Colors.white.withOpacity(0.24),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.delete_outline_rounded,
            color: _isHoveringTrash ? Colors.white : Colors.redAccent,
            size: _isHoveringTrash ? 30 : 24,
          ),
        ),
      ),
    );
  }
}

class StoryDrawingPainter extends CustomPainter {
  final List<DrawingLine> lines;
  final DrawingLine? currentLine;

  const StoryDrawingPainter({
    required this.lines,
    this.currentLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round;

    for (final line in lines) {
      paint.color = line.color;
      paint.strokeWidth = line.strokeWidth;
      for (int i = 0; i < line.points.length - 1; i++) {
        canvas.drawLine(line.points[i], line.points[i + 1], paint);
      }
    }

    if (currentLine != null) {
      paint.color = currentLine!.color;
      paint.strokeWidth = currentLine!.strokeWidth;
      for (int i = 0; i < currentLine!.points.length - 1; i++) {
        canvas.drawLine(currentLine!.points[i], currentLine!.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StoryDrawingPainter oldDelegate) => true;
}
