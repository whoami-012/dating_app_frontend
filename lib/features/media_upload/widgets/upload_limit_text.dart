import 'package:flutter/material.dart';

class UploadLimitText extends StatelessWidget {
  const UploadLimitText({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedTextColor = isDark
        ? const Color(0xFF6F7078)
        : const Color(0xFF92959D);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          'You can add up to 10 photos or 1 video (max 60s)',
          style: TextStyle(
            color: mutedTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
