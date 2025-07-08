import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const CustomCard({
    Key? key,
    required this.child,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      child: Material(
        color: backgroundColor ?? AppColors.cardDark,
        borderRadius:
            BorderRadius.circular(borderRadius ?? AppStyles.cardBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(borderRadius ?? AppStyles.cardBorderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppStyles.defaultPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  borderRadius ?? AppStyles.cardBorderRadius),
              boxShadow: boxShadow ?? AppStyles.cardShadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
