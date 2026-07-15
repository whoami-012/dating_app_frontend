import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/feed_post.dart';

class EngagementBar extends StatelessWidget {
  final FeedPost? post;
  final bool isLoading;
  final VoidCallback onLikeTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;

  const EngagementBar({
    super.key,
    required this.post,
    required this.isLoading,
    required this.onLikeTap,
    required this.onBookmarkTap,
    required this.onCommentTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || post == null) {
      return const _EngagementBarSkeleton();
    }

    final p = post!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pillBg = isDark ? const Color(0xFF151515) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);
    final textColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.lightIcon;

    final shadowList = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
        top: 12.0,
        bottom: 0.0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Left Pill: Like, Comment, Share
              Expanded(
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(29),
                    border: Border.all(color: borderColor),
                    boxShadow: shadowList,
                  ),
                  child: Row(
                    children: [
                      // Like Item
                      Expanded(
                        child: _AnimatedEngagementButton(
                          isActive: p.isLiked,
                          activeColor: AppColors.liveRed,
                          iconData: p.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: _formatCount(p.likeCount),
                          iconSize: 23,
                          textColor: textColor,
                          inactiveIconColor: iconColor,
                          onTap: onLikeTap,
                          semanticLabel: 'Like',
                          gap: 6,
                        ),
                      ),

                      // Comment Item
                      Expanded(
                        child: _AnimatedEngagementButton(
                          isActive: false,
                          activeColor: AppColors.neonLime,
                          iconData: Icons.chat_bubble_outline_rounded,
                          label: _formatCount(p.commentCount),
                          iconSize: 23,
                          textColor: textColor,
                          inactiveIconColor: iconColor,
                          onTap: onCommentTap,
                          semanticLabel: 'Comment',
                          gap: 6,
                        ),
                      ),

                      // Share Item
                      Expanded(
                        child: _AnimatedEngagementButton(
                          isActive: false,
                          activeColor: AppColors.neonLime,
                          iconData: Icons.reply,
                          label: _formatCount(p.shareCount),
                          iconSize: 23,
                          textColor: textColor,
                          inactiveIconColor: iconColor,
                          onTap: onShareTap,
                          semanticLabel: 'Share',
                          gap: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Right Pill: Bookmark
              SizedBox(
                width: 100,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(29),
                    border: Border.all(color: borderColor),
                    boxShadow: shadowList,
                  ),
                  child: _AnimatedEngagementButton(
                    isActive: p.isBookmarked,
                    activeColor: AppColors.neonLime,
                    iconData: p.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border_rounded,
                    label: _formatCount(p.bookmarkCount),
                    iconSize: 23,
                    textColor: textColor,
                    inactiveIconColor: iconColor,
                    onTap: onBookmarkTap,
                    semanticLabel: 'Bookmark',
                    gap: 7,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      double formatted = count / 1000.0;
      return '${formatted.toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;

  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 24, color: color);
  }
}

class _AnimatedEngagementButton extends StatefulWidget {
  final bool isActive;
  final Color activeColor;
  final IconData iconData;
  final String label;
  final double iconSize;
  final Color textColor;
  final Color inactiveIconColor;
  final VoidCallback onTap;
  final String semanticLabel;
  final double gap;

  const _AnimatedEngagementButton({
    required this.isActive,
    required this.activeColor,
    required this.iconData,
    required this.label,
    required this.iconSize,
    required this.textColor,
    required this.inactiveIconColor,
    required this.onTap,
    required this.semanticLabel,
    required this.gap,
  });

  @override
  State<_AnimatedEngagementButton> createState() =>
      _AnimatedEngagementButtonState();
}

class _AnimatedEngagementButtonState extends State<_AnimatedEngagementButton>
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
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.96), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AnimatedEngagementButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIconColor = widget.isActive
        ? widget.activeColor
        : widget.inactiveIconColor;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: InkWell(
        onTap: () {
          _controller.forward(from: 0.0);
          widget.onTap();
        },
        borderRadius: BorderRadius.circular(29),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: SizedBox(
            height: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.semanticLabel == 'Share'
                    ? Transform.flip(
                        flipX: true,
                        child: Icon(
                          widget.iconData,
                          color: currentIconColor,
                          size: widget.iconSize,
                        ),
                      )
                    : Icon(
                        widget.iconData,
                        color: currentIconColor,
                        size: widget.iconSize,
                      ),
                SizedBox(width: widget.gap),
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppTypography.getEngagementCount(
                      widget.textColor,
                    ).copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
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

class _EngagementBarSkeleton extends StatefulWidget {
  const _EngagementBarSkeleton();

  @override
  State<_EngagementBarSkeleton> createState() => _EngagementBarSkeletonState();
}

class _EngagementBarSkeletonState extends State<_EngagementBarSkeleton>
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
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(opacity: _opacity.value, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 12.0,
          bottom: 0.0,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(29),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(29),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
