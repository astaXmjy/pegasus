import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 50,
            height: size ?? 50,
            child: const CircularProgressIndicator(
              color: AppColors.primaryPurple,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
