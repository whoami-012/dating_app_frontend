import 'package:flutter/material.dart';

class AuthGradientOverlay extends StatelessWidget {
  final bool isDark;

  const AuthGradientOverlay({super.key, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Primary vertical gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.42, 0.62, 1.0],
                colors: isDark
                    ? [
                        Colors.black.withOpacity(0.08),
                        Colors.black.withOpacity(0.12),
                        Colors.black.withOpacity(0.72),
                        Colors.black.withOpacity(0.98),
                      ]
                    : [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.10),
                        const Color(0xFFF5F6F8).withOpacity(0.75),
                        const Color(0xFFF5F6F8),
                      ],
              ),
            ),
          ),

          // 2. Side vignette (horizontal gradient)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.0, 0.5, 1.0],
                colors: [
                  (isDark ? Colors.black : const Color(0xFFF5F6F8)).withOpacity(
                    0.25,
                  ),
                  Colors.transparent,
                  (isDark ? Colors.black : const Color(0xFFF5F6F8)).withOpacity(
                    0.25,
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom readability layer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.sizeOf(context).height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    (isDark ? Colors.black : const Color(0xFFF5F6F8))
                        .withOpacity(0.35),
                    isDark ? Colors.black : const Color(0xFFF5F6F8),
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
