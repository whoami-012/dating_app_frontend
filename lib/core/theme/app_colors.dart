import 'package:flutter/material.dart';

class AppColors {
  // Common Accents
  static const Color neonLime = Color(0xFFC8FF3D);
  static const Color liveOrange = Color(0xFFFF5030);
  static const Color liveRed = Color(0xFFFF2A54);
  static const Color gemBlue = Color(0xFF3B82F6);
  static const Color gemPurple = Color(0xFF8B5CF6);

  // Live Gradient Colors
  static const List<Color> liveGradient = [
    Color(0xFFFF3B30),
    Color(0xFFFF6B2B),
  ];

  // Gem Gradient Colors
  static const List<Color> gemGradient = [Color(0xFF3B82F6), Color(0xFF8B5CF6)];

  // Story Gradient Ring Colors (multi-color gradient)
  static const List<Color> storyGradientRing = [
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEF4444), // Orange/Red
    Color(0xFFF59E0B), // Yellow
    Color(0xFF10B981), // Green/Cyan
    Color(0xFFC8FF3D), // Lime
  ];

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF050505);
  static const Color darkSurface = Color(0xFF101010);
  static const Color darkSecondarySurface = Color(0xFF171717);
  static const Color darkSelectedNavTile = Color(0xFF222222);
  static const Color darkPrimaryText = Color(0xFFF7F7F7);
  static const Color darkSecondaryText = Color(0xFFA4A4A8);
  static const Color darkMutedText = Color(0xFF747478);
  static final Color darkBorder = Colors.white.withOpacity(0.08);
  static const Color darkIcon = Color(0xFFE5E5E5);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F6F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSecondarySurface = Color(0xFFF0F1F3);
  static const Color lightSelectedNavTile = Color(0xFFE8EAED);
  static const Color lightPrimaryText = Color(0xFF111216);
  static const Color lightSecondaryText = Color(0xFF666971);
  static const Color lightMutedText = Color(0xFF92959D);
  static final Color lightBorder = Colors.black.withOpacity(0.08);
  static const Color lightIcon = Color(0xFF4B5563);

  // Premium Auth Specific Colors
  static const Color authBackground = Color(0xFF050506);
  static const Color authSurface = Color(0xFF111116);
  static final Color authSurfaceGlassDark = Colors.black.withOpacity(0.58);
  static final Color authSurfaceGlassLight = Colors.white.withOpacity(0.65);
  static const Color authPrimaryTextDark = Color(0xFFF7F7F8);
  static const Color authSecondaryTextDark = Color(0xFF8D8D96);
  static const Color authMutedTextDark = Color(0xFF6F7078);
  static const Color authNeonLime = Color(0xFFCCFF29);
  static const Color authNeonLimeBright = Color(0xFFD9FF39);
  static const Color authPurpleHeart = Color(0xFFA832F5);
  static final Color authBorderDark = Colors.white.withOpacity(0.10);
  static final Color authBorderLight = Colors.black.withOpacity(0.10);
  static const Color authError = Color(0xFFFF5A52);
}
