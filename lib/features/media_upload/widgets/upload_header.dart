import 'package:flutter/material.dart';

class UploadMediaHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onDraftsPressed;
  final int draftCount;

  const UploadMediaHeader({
    super.key,
    required this.onBack,
    required this.onDraftsPressed,
    this.draftCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme colors matching style spec
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);
    final mutedTextColor = isDark
        ? const Color(0xFF6F7078)
        : const Color(0xFF92959D);
    final surfaceColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);
    const neonLime = Color(0xFFD2FF27);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Circular Back Button
          Semantics(
            label: 'Go back',
            button: true,
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: primaryTextColor,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title & Subtitle block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Media',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share your moment',
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Drafts Button Pill
          Semantics(
            label: 'Open drafts, $draftCount drafts available',
            button: true,
            child: InkWell(
              onTap: onDraftsPressed,
              borderRadius: BorderRadius.circular(26),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome, // Neon sparkle icon
                      color: neonLime,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Drafts',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (draftCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: neonLime,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$draftCount',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
