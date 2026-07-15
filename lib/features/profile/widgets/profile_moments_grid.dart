import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/profile_moment.dart';

class ProfileMomentsGrid extends StatelessWidget {
  final List<ProfileMoment> moments;
  final bool isOwnProfile;
  final Function(ProfileMoment)? onMomentTap;
  final VoidCallback? onViewAllTap;

  const ProfileMomentsGrid({
    super.key,
    required this.moments,
    required this.isOwnProfile,
    this.onMomentTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? const Color(0xFFF5F5F6) : const Color(0xFF111216);
    final purpleColor = const Color(0xFFA96BFF);
    final limeColor = const Color(0xFFBFFF27);
    final actionColor = isOwnProfile ? limeColor : purpleColor;

    if (moments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Moments Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Moments',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onViewAllTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      color: actionColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: actionColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Moments List/Grid Layout
        if (isOwnProfile)
          // 3-Column Grid for Alex
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moments.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75, // Aspect ratio between 0.72-0.78
            ),
            itemBuilder: (context, index) {
              final moment = moments[index];
              return _buildMomentThumbnail(context, moment, 10.0);
            },
          )
        else
          // Horizontal scrolling ListView for Arjun
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: moments.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final moment = moments[index];
                return SizedBox(
                  width: 115,
                  child: _buildMomentThumbnail(context, moment, 12.0),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMomentThumbnail(
    BuildContext context,
    ProfileMoment moment,
    double radius,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'Moments thumbnail',
      child: GestureDetector(
        onTap: () => onMomentTap?.call(moment),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CachedNetworkImage(
            imageUrl: moment.imageUrl,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 200), // restrained fade-in
            placeholder: (context, url) => Container(
              color: isDark ? const Color(0xFF18191C) : const Color(0xFFF0F1F3),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: isOwnProfile ? const Color(0xFFBFFF27) : const Color(0xFFA96BFF),
                    strokeWidth: 1.5,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: isDark ? const Color(0xFF18191C) : const Color(0xFFF0F1F3),
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
