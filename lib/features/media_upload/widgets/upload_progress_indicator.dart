import 'package:flutter/material.dart';

class UploadProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool visible;

  const UploadProgressIndicator({
    super.key,
    required this.progress,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? const Color(0xFF121216)
        : const Color(0xFFE0E0E0);
    const neonLime = Color(0xFFD2FF27);
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Uploading post...',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: neonLime,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: constraints.maxWidth * progress,
                        height: 6,
                        decoration: BoxDecoration(
                          color: neonLime,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: neonLime.withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      );
                    },
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
