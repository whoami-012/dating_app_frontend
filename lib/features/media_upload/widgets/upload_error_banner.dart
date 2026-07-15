import 'package:flutter/material.dart';

class UploadErrorBanner extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const UploadErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Styling
    const errorColor = Color(0xFFFF5A52);
    final surfaceColor = isDark
        ? const Color(0xFF140D0D)
        : const Color(0xFFFFF5F5);
    final borderColor = isDark
        ? errorColor.withOpacity(0.2)
        : errorColor.withOpacity(0.15);
    final textStyle = TextStyle(
      color: isDark ? const Color(0xFFF7F7F8) : const Color(0xFF111216),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: errorColor, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Upload Failed',
                    style: TextStyle(
                      color: errorColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close,
                    color: isDark
                        ? const Color(0xFF6F7078)
                        : const Color(0xFF92959D),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message!, style: textStyle),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.replay, size: 16),
                  label: const Text(
                    'Retry Upload',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
