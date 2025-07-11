import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionText,
    this.onAction,
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
              icon,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppStyles.titleTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppStyles.subtitleTextStyle,
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              CustomButton(
                text: actionText!,
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
