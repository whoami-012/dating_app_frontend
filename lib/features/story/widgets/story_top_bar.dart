import 'package:flutter/material.dart';

class StoryTopBar extends StatelessWidget {
  final String title;
  final bool hasSelection;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const StoryTopBar({
    super.key,
    required this.title,
    required this.hasSelection,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left: Back button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Center: Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Right: Next contextual action
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: hasSelection ? onNext : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: hasSelection ? 1.0 : 0.4,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: hasSelection
                        ? const Color(0xFFD1FF2F)
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          color: hasSelection
                              ? const Color(0xFF050506)
                              : Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: hasSelection
                            ? const Color(0xFF050506)
                            : Colors.white.withOpacity(0.5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
