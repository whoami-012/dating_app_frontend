import 'package:flutter/material.dart';
import '../models/story.dart';
import 'story_item.dart';

class StoriesList extends StatelessWidget {
  final List<Story> stories;
  final bool isLoading;
  final Function(Story) onStoryTap;

  const StoriesList({
    super.key,
    required this.stories,
    required this.isLoading,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 18.0, right: 18.0),
        itemCount: isLoading ? 6 : stories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (isLoading) {
            return const _StorySkeleton();
          }
          final story = stories[index];
          return StoryItem(story: story, onTap: () => onStoryTap(story));
        },
      ),
    );
  }
}

class _StorySkeleton extends StatefulWidget {
  const _StorySkeleton();

  @override
  State<_StorySkeleton> createState() => _StorySkeletonState();
}

class _StorySkeletonState extends State<_StorySkeleton>
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
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: baseColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 12,
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
