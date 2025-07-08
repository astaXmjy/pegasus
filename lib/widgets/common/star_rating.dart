import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color color;
  final Function(int)? onRatingChanged;
  final bool allowHalfRating;

  const StarRating({
    Key? key,
    required this.rating,
    this.starCount = 5,
    this.size = 16,
    this.color = AppColors.primaryPurple,
    this.onRatingChanged,
    this.allowHalfRating = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(index + 1)
              : null,
          child: Icon(
            _getStarIcon(index),
            color: color,
            size: size,
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int index) {
    if (rating >= index + 1) {
      return Icons.star;
    } else if (allowHalfRating && rating >= index + 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }
}
