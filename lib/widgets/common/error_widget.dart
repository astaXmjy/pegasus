import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import 'custom_button.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorDisplayWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: AppStyles.titleTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppStyles.subtitleTextStyle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Try Again',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
