import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerControllerFactory {
  const VideoPlayerControllerFactory();

  VideoPlayerController file(File file) {
    return VideoPlayerController.file(file);
  }

  VideoPlayerController networkUrl(Uri url) {
    return VideoPlayerController.networkUrl(url);
  }
}

final videoPlayerControllerFactoryProvider =
    Provider<VideoPlayerControllerFactory>(
      (ref) => const VideoPlayerControllerFactory(),
    );

enum PlaybackState { initializing, ready, playing, paused, completed, failed }

class UploadVideoPreview extends ConsumerStatefulWidget {
  final String videoPathOrUrl;
  final String? thumbnailPath;
  final VoidCallback? onReplace;

  const UploadVideoPreview({
    super.key,
    required this.videoPathOrUrl,
    this.thumbnailPath,
    this.onReplace,
  });

  @override
  ConsumerState<UploadVideoPreview> createState() => _UploadVideoPreviewState();
}

class _UploadVideoPreviewState extends ConsumerState<UploadVideoPreview> {
  VideoPlayerController? _controller;
  PlaybackState _state = PlaybackState.initializing;
  String? _errorDescription;
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant UploadVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPathOrUrl != widget.videoPathOrUrl) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    // 1. Pause and dispose old controller if it exists
    if (_controller != null) {
      if (_listener != null) {
        _controller!.removeListener(_listener!);
      }
      try {
        await _controller!.pause();
      } catch (_) {}
      await _controller!.dispose();
      _controller = null;
    }

    if (mounted) {
      setState(() {
        _state = PlaybackState.initializing;
        _errorDescription = null;
      });
    }

    final isNetwork =
        widget.videoPathOrUrl.startsWith('http://') ||
        widget.videoPathOrUrl.startsWith('https://');

    final factory = ref.read(videoPlayerControllerFactoryProvider);
    VideoPlayerController controller;
    if (isNetwork) {
      controller = factory.networkUrl(Uri.parse(widget.videoPathOrUrl));
    } else {
      controller = factory.file(File(widget.videoPathOrUrl));
    }

    _controller = controller;

    _listener = () {
      if (!mounted || _controller != controller) return;

      final value = _controller!.value;
      if (value.hasError) {
        _handleError(value.errorDescription ?? 'Unknown playback error');
        return;
      }

      if (!value.isInitialized) {
        if (_state != PlaybackState.initializing) {
          setState(() {
            _state = PlaybackState.initializing;
          });
        }
        return;
      }

      PlaybackState newState;
      if (value.position >= value.duration && value.duration > Duration.zero) {
        newState = PlaybackState.completed;
      } else if (value.isPlaying) {
        newState = PlaybackState.playing;
      } else {
        newState = PlaybackState.paused;
      }

      if (_state != newState) {
        setState(() {
          _state = newState;
        });
      }
    };

    controller.addListener(_listener!);

    try {
      if (!isNetwork) {
        final file = File(widget.videoPathOrUrl);
        if (!file.existsSync()) {
          throw Exception('Local file does not exist');
        }
        final size = file.lengthSync();
        if (size == 0) {
          throw Exception('Local file is empty (0 bytes)');
        }
      }

      await controller.initialize();
      if (!mounted || _controller != controller) {
        return;
      }

      // Muted by default
      await controller.setVolume(0.0);

      setState(() {
        _state = PlaybackState.ready;
      });
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _handleError(String description) {
    if (!mounted) return;

    final isNetwork =
        widget.videoPathOrUrl.startsWith('http://') ||
        widget.videoPathOrUrl.startsWith('https://');

    String sanitizedPath = widget.videoPathOrUrl;
    if (isNetwork) {
      try {
        final uri = Uri.parse(widget.videoPathOrUrl);
        sanitizedPath = uri.replace(queryParameters: {}).toString();
      } catch (_) {}
    }

    bool fileExists = false;
    int fileSize = 0;
    if (!isNetwork) {
      try {
        final file = File(widget.videoPathOrUrl);
        fileExists = file.existsSync();
        if (fileExists) {
          fileSize = file.lengthSync();
        }
      } catch (_) {}
    }

    final isInitialized = _controller?.value.isInitialized ?? false;
    final duration = _controller?.value.duration ?? Duration.zero;
    final size = _controller?.value.size ?? Size.zero;

    debugPrint('--- Video Playback Error ---');
    debugPrint('Source Type: ${isNetwork ? 'Network' : 'Local'}');
    debugPrint('Sanitized Path: $sanitizedPath');
    debugPrint('File Existence: $fileExists');
    debugPrint('File Size: $fileSize bytes');
    debugPrint('Initialization State: $isInitialized');
    debugPrint('Duration: $duration');
    debugPrint('Video Dimensions: ${size.width}x${size.height}');
    debugPrint('Playback Error Description: $description');
    debugPrint('----------------------------');

    setState(() {
      _state = PlaybackState.failed;
      _errorDescription = description;
    });
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      if (_state == PlaybackState.completed) {
        await _controller!.seekTo(Duration.zero);
      }
      await _controller!.play();
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      if (_listener != null) {
        _controller!.removeListener(_listener!);
      }
      try {
        _controller!.pause();
      } catch (_) {}
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(color: const Color(0xFF121216), child: _buildContent()),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case PlaybackState.initializing:
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildThumbnailOrPlaceholder(),
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD2FF27),
                strokeWidth: 2,
              ),
            ),
          ],
        );
      case PlaybackState.failed:
        return _buildErrorUI();
      case PlaybackState.ready:
      case PlaybackState.playing:
      case PlaybackState.paused:
      case PlaybackState.completed:
        if (_controller == null || !_controller!.value.isInitialized) {
          return _buildThumbnailOrPlaceholder();
        }
        return GestureDetector(
          onTap: _togglePlayPause,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio > 0
                      ? _controller!.value.aspectRatio
                      : 9 / 16,
                  child: VideoPlayer(_controller!),
                ),
              ),
              _buildOverlayControls(),
            ],
          ),
        );
    }
  }

  Widget _buildThumbnailOrPlaceholder() {
    if (widget.thumbnailPath != null) {
      final isNetwork =
          widget.thumbnailPath!.startsWith('http://') ||
          widget.thumbnailPath!.startsWith('https://');
      if (isNetwork) {
        return Image.network(widget.thumbnailPath!, fit: BoxFit.cover);
      } else {
        final file = File(widget.thumbnailPath!);
        if (file.existsSync()) {
          return Image.file(file, fit: BoxFit.cover);
        }
      }
    }
    return Container(
      color: const Color(0xFF121216),
      child: const Center(
        child: Icon(
          Icons.video_collection_outlined,
          color: Color(0xFFD2FF27),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black.withOpacity(0.85),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
          const SizedBox(height: 6),
          const Text(
            'Unable to play this video',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: _initializePlayer,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
              if (widget.onReplace != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: widget.onReplace,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2FF27).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Replace',
                      style: TextStyle(color: Color(0xFFD2FF27), fontSize: 10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayControls() {
    final showPlayIcon =
        _state == PlaybackState.paused || _state == PlaybackState.ready;
    final showReplayIcon = _state == PlaybackState.completed;
    final showPauseIcon = _state == PlaybackState.playing;

    return Stack(
      children: [
        if (showPlayIcon || showReplayIcon)
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 1),
              ),
              child: Icon(
                showReplayIcon ? Icons.replay : Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        if (_controller != null && _controller!.value.isInitialized)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    showPauseIcon ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 10,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatDuration(_controller!.value.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds % 60;
    final minutes = duration.inMinutes;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
