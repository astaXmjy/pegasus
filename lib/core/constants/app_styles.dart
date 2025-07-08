import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static const cardBorderRadius = 16.0;
  static const buttonBorderRadius = 12.0;
  static const defaultPadding = 16.0;
  static const smallPadding = 8.0;
  static const largePadding = 24.0;

  static const titleTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const subtitleTextStyle = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static const bodyTextStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const captionTextStyle = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const cardShadow = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}
