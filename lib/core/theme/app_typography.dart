import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily =
      'SF ProText'; // Use system typography fallback

  static TextStyle getBrandTitle(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.5,
    );
  }

  static TextStyle getBalance(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle getStoryLabel(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle getEngagementCount(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle getUsername(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle getCaption(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.3,
    );
  }

  static TextStyle getNavigationLabel(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle getBadgeText(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: 0.5,
    );
  }

  // Premium Auth Typography
  static TextStyle getAuthBrand(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: color,
    );
  }

  static TextStyle getAuthTagline(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 19,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.25,
    );
  }

  static TextStyle getAuthWelcome(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 40,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.5,
    );
  }

  static TextStyle getAuthSubtitle(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle getAuthTab(Color color, {required bool isActive}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      color: color,
    );
  }

  static TextStyle getAuthFieldText(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 19,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle getAuthForgotPassword(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle getAuthCTA(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 21,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle getAuthDividerText(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle getAuthLegalText(Color color) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.35,
    );
  }
}
