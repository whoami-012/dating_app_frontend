import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({
    super.key,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verified profile',
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFBFFF27), // Neon Lime
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.check,
            color: const Color(0xFF050506), // Near-black
            size: size * 0.65,
          ),
        ),
      ),
    );
  }
}
