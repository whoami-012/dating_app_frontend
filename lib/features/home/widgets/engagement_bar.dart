import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/feed_post.dart';

class EngagementBar extends StatelessWidget {
  final FeedPost? post;
  final bool isLoading;
  final VoidCallback onLikeTap;
  final VoidCallback? onNotInterestedTap;
  final EdgeInsetsGeometry? padding;

  const EngagementBar({
    super.key,
    required this.post,
    required this.isLoading,
    required this.onLikeTap,
    this.onNotInterestedTap,
    this.padding,
    // Add unused parameters for compatibility
    VoidCallback? onBookmarkTap,
    VoidCallback? onCommentTap,
    VoidCallback? onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return PostActionRow(
      post: post,
      isLoading: isLoading,
      onLikeTap: onLikeTap,
      padding: padding,
    );
  }
}

class PostActionRow extends StatelessWidget {
  final FeedPost? post;
  final bool isLoading;
  final VoidCallback onLikeTap;
  final EdgeInsetsGeometry? padding;

  const PostActionRow({
    super.key,
    required this.post,
    required this.isLoading,
    required this.onLikeTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || post == null) {
      return _PostActionRowSkeleton(padding: padding);
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
        top: 12.0,
        bottom: 0.0,
      ),
      child: LikeActionButton(post: post!, onTap: onLikeTap),
    );
  }
}

class LikeActionButton extends StatefulWidget {
  final FeedPost post;
  final VoidCallback onTap;

  const LikeActionButton({super.key, required this.post, required this.onTap});

  @override
  State<LikeActionButton> createState() => _LikeActionButtonState();
}

class _LikeActionButtonState extends State<LikeActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LikeActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.isLiked != oldWidget.post.isLiked && widget.post.isLiked) {
      _controller.forward(from: 0.0);
    }
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      double formatted = count / 1000.0;
      return '${formatted.toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.isLiked;
    final limeColor = AppColors.neonLime;

    return Semantics(
      label: 'Like post',
      selected: isLiked,
      button: true,
      child: GestureDetector(
        onTap: () {
          _controller.forward(from: 0.0);
          widget.onTap();
        },
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: isLiked
                ? limeColor.withOpacity(0.05)
                : const Color(0xFF121212),
            borderRadius: BorderRadius.circular(29),
            border: Border.all(color: limeColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: limeColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                _formatCount(widget.post.likeCount),
                style: AppTypography.getEngagementCount(
                  Colors.white,
                ).copyWith(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotInterestedButton extends StatefulWidget {
  final VoidCallback onTap;

  const NotInterestedButton({super.key, required this.onTap});

  @override
  State<NotInterestedButton> createState() => _NotInterestedButtonState();
}

class _NotInterestedButtonState extends State<NotInterestedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Not interested',
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          _controller.reverse();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(29),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.block_rounded,
                  color: AppColors.darkSecondaryText,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Not interested',
                    style: AppTypography.getNotInterested(
                      AppColors.darkSecondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostActionRowSkeleton extends StatefulWidget {
  final EdgeInsetsGeometry? padding;

  const _PostActionRowSkeleton({this.padding});

  @override
  State<_PostActionRowSkeleton> createState() => _PostActionRowSkeletonState();
}

class _PostActionRowSkeletonState extends State<_PostActionRowSkeleton>
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
      child: Padding(
        padding:
            widget.padding ??
            const EdgeInsets.only(
              left: 18.0,
              right: 18.0,
              top: 12.0,
              bottom: 0.0,
            ),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(29),
          ),
        ),
      ),
    );
  }
}
