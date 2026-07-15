import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/story.dart';

class StoryItem extends StatefulWidget {
  final Story story;
  final VoidCallback onTap;

  const StoryItem({super.key, required this.story, required this.onTap});

  @override
  State<StoryItem> createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.96;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final mutedText = isDark
        ? AppColors.darkMutedText
        : AppColors.lightMutedText;
    final surfaceColor = isDark
        ? AppColors.darkSecondarySurface
        : AppColors.lightSecondarySurface;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.story.isCurrentUser) ...[
                    // Current user - Empty circular surface with neon lime add button
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: surfaceColor,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.08),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          widget.story.avatarUrl,
                          fit: BoxFit.cover,
                          opacity: const AlwaysStoppedAnimation(0.35),
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 30),
                        ),
                      ),
                    ),
                    // Plus sign badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: AppColors.neonLime,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 18,
                            semanticLabel: 'Add to Story',
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Other User Story - Gradient Border Ring
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.story.hasUnseenStory
                            ? const SweepGradient(
                                colors: AppColors.storyGradientRing,
                              )
                            : null,
                        border: widget.story.hasUnseenStory
                            ? null
                            : Border.all(
                                color: isDark ? Colors.white24 : Colors.black12,
                                width: 3,
                              ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          3.0,
                        ), // 3 px gradient ring thickness
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.scaffoldBackgroundColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              2.0,
                            ), // 2 px inner gap
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(widget.story.avatarUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Active dot (Teal) if online
                    if (widget.story.isOnline)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 9.5,
                          height: 9.5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676), // Teal active dot
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Story user name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  widget.story.username,
                  style: AppTypography.getStoryLabel(
                    widget.story.isCurrentUser ? mutedText : secondaryText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
