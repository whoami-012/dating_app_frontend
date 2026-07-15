import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/feed_post.dart';

class PostCaption extends StatelessWidget {
  final FeedPost? post;
  final bool isLoading;
  final VoidCallback onTap;

  const PostCaption({
    super.key,
    required this.post,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || post == null) {
      return const _PostCaptionSkeleton();
    }

    final p = post!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 18.0,
        top: 18.0,
        bottom: 12.0,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Avatar with a subtle border
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                  width: 1.5,
                ),
                image: DecorationImage(
                  image: NetworkImage(p.authorAvatarUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Text block (username + caption)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: AppTypography.getCaption(
                      secondaryColor,
                    ).copyWith(fontSize: 15, height: 1.33),
                    children: [
                      TextSpan(
                        text: '${p.author} ',
                        style: AppTypography.getUsername(
                          primaryColor,
                        ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: p.caption),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCaptionSkeleton extends StatefulWidget {
  const _PostCaptionSkeleton();

  @override
  State<_PostCaptionSkeleton> createState() => _PostCaptionSkeletonState();
}

class _PostCaptionSkeletonState extends State<_PostCaptionSkeleton>
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
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 18.0,
          bottom: 12.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: baseColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 180,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
