import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/feed_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';

class LivePostCard extends ConsumerWidget {
  final FeedPost? post;
  final bool isLoading;
  final VoidCallback? onDoubleTap;

  const LivePostCard({
    super.key,
    required this.post,
    required this.isLoading,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading || post == null) {
      return const _LivePostCardSkeleton();
    }

    final p = post!;

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Media (Video or Image)
            if (p.mediaUrl.isEmpty)
              const _ImagePlaceholder(showDefaultIcon: true)
            else if (p.isVideo && p.videoUrl != null)
              VideoPostPlayer(
                videoUrl: p.videoUrl!,
                thumbnailUrl: p.mediaUrl,
                mediaAlignmentX: p.mediaAlignmentX,
                mediaAlignmentY: p.mediaAlignmentY,
                mediaId: p.mediaId,
              )
            else if (p.mediaUrl.startsWith('http://') ||
                p.mediaUrl.startsWith('https://'))
              CachedNetworkImage(
                imageUrl: p.mediaUrl,
                cacheKey: p.mediaId,
                fit: BoxFit.cover,
                alignment: Alignment(
                  p.mediaAlignmentX ?? 0.08,
                  p.mediaAlignmentY ?? -0.05,
                ),
                placeholder: (context, url) => const _ImagePlaceholder(),
                errorWidget: (context, url, error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(homeProvider.notifier).refreshFeed();
                  });
                  return const _ImageErrorState();
                },
              )
            else
              Image.file(
                File(p.mediaUrl),
                fit: BoxFit.cover,
                alignment: Alignment(
                  p.mediaAlignmentX ?? 0.08,
                  p.mediaAlignmentY ?? -0.05,
                ),
                errorBuilder: (context, error, stackTrace) =>
                    const _ImageErrorState(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool showDefaultIcon;
  const _ImagePlaceholder({this.showDefaultIcon = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Center(
        child: showDefaultIcon
            ? Icon(
                Icons.image_outlined,
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                size: 48,
              )
            : const CircularProgressIndicator(
                color: AppColors.neonLime,
                strokeWidth: 2,
              ),
      ),
    );
  }
}

class _ImageErrorState extends StatelessWidget {
  const _ImageErrorState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePostCardSkeleton extends StatefulWidget {
  const _LivePostCardSkeleton();

  @override
  State<_LivePostCardSkeleton> createState() => _LivePostCardSkeletonState();
}

class _LivePostCardSkeletonState extends State<_LivePostCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(opacity: _opacity.value, child: child);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(29),
        ),
      ),
    );
  }
}

class VideoPostPlayer extends ConsumerStatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final double? mediaAlignmentX;
  final double? mediaAlignmentY;
  final String? mediaId;

  const VideoPostPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.mediaAlignmentX,
    this.mediaAlignmentY,
    this.mediaId,
  });

  @override
  ConsumerState<VideoPostPlayer> createState() => _VideoPostPlayerState();
}

class _VideoPostPlayerState extends ConsumerState<VideoPostPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(widget.videoUrl);
    final isNetwork = uri.scheme == 'http' || uri.scheme == 'https';
    if (isNetwork) {
      _controller = VideoPlayerController.networkUrl(uri);
    } else {
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    }
    _controller
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
            _controller.setLooping(true);
            _controller.play();
          }
        })
        .catchError((_) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildThumbnail();
    }

    if (!_isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildThumbnail(),
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.neonLime,
              strokeWidth: 2,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
          if (!_controller.value.isPlaying)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    final isNetwork =
        widget.thumbnailUrl.startsWith('http://') ||
        widget.thumbnailUrl.startsWith('https://');
    if (isNetwork) {
      return CachedNetworkImage(
        imageUrl: widget.thumbnailUrl,
        cacheKey: widget.mediaId,
        fit: BoxFit.cover,
        alignment: Alignment(
          widget.mediaAlignmentX ?? 0.0,
          widget.mediaAlignmentY ?? 0.0,
        ),
        placeholder: (context, url) => const _ImagePlaceholder(),
        errorWidget: (context, url, error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(homeProvider.notifier).refreshFeed();
          });
          return const _ImageErrorState();
        },
      );
    } else {
      return Image.file(
        File(widget.thumbnailUrl),
        fit: BoxFit.cover,
        alignment: Alignment(
          widget.mediaAlignmentX ?? 0.0,
          widget.mediaAlignmentY ?? 0.0,
        ),
        errorBuilder: (context, error, stackTrace) => const _ImageErrorState(),
      );
    }
  }
}
