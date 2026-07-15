import 'package:flutter/material.dart';

class StorySelectionBadge extends StatelessWidget {
  final int index; // 1-based index, or <= 0 for unselected

  const StorySelectionBadge({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    if (index <= 0) return const SizedBox.shrink();

    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Color(0xFFD1FF2F),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: const TextStyle(
          color: Color(0xFF050506),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
