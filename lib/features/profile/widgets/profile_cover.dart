import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileCover extends StatelessWidget {
  final String imageUrl;
  final double height;
  final bool showGradient;

  const ProfileCover({
    super.key,
    required this.imageUrl,
    required this.height,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover Image
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.15), // Slightly shift up to center face
            placeholder: (context, url) => Container(
              color: isDark ? const Color(0xFF111214) : const Color(0xFFE5E5E5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFBFFF27), // Neon Lime
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: isDark ? const Color(0xFF111214) : const Color(0xFFE5E5E5),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
                size: 40,
              ),
            ),
          ),

          // Vertical Cinematic Gradient Overlay
          if (showGradient)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.48, 0.78, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.08),
                      Colors.black.withOpacity(0.62),
                      Colors.black.withOpacity(0.96),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
