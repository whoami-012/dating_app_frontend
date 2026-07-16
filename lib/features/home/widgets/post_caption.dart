import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/feed_post.dart';

class PostCaption extends StatelessWidget {
  final FeedPost? post;
  final bool isLoading;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final double? creatorToCaptionGap;

  const PostCaption({
    super.key,
    required this.post,
    required this.isLoading,
    required this.onTap,
    this.padding,
    this.creatorToCaptionGap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || post == null) {
      return _PostCaptionSkeleton(
        padding: padding,
        creatorToCaptionGap: creatorToCaptionGap,
      );
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
    final mutedColor = isDark
        ? AppColors.darkMutedText
        : AppColors.lightMutedText;

    return Padding(
      padding:
          padding ??
          const EdgeInsets.only(
            left: 18.0,
            right: 18.0,
            top: 18.0,
            bottom: 12.0,
          ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. Creator information row
            Row(
              children: [
                // Circular creator avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    image: p.authorAvatarUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(p.authorAvatarUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: p.authorAvatarUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Username/Display Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.author,
                              style: AppTypography.getUsername(
                                primaryColor,
                              ).copyWith(fontSize: 16.5, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (p.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.blueAccent,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      if (p.username != null && p.username!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '@${p.username}',
                          style: AppTypography.getCaption(
                            mutedColor,
                          ).copyWith(fontSize: 14.0, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            SizedBox(height: creatorToCaptionGap ?? 12.0),

            // 4. Caption
            Text(
              p.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.getCaption(secondaryColor).copyWith(
                fontSize: 16.5,
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCaptionSkeleton extends StatefulWidget {
  final EdgeInsetsGeometry? padding;
  final double? creatorToCaptionGap;

  const _PostCaptionSkeleton({this.padding, this.creatorToCaptionGap});

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
        padding:
            widget.padding ??
            const EdgeInsets.only(
              left: 18.0,
              right: 18.0,
              top: 18.0,
              bottom: 12.0,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: baseColor,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 50,
                  height: 14,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.creatorToCaptionGap ?? 12.0),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 220,
              height: 16,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
