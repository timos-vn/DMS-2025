import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double percentage; // Giá trị từ 0.0 đến 1.0
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final Duration animationDuration;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;

  const CustomProgressBar({
    super.key,
    required this.percentage,
    this.height = 7.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = Colors.blue,
    this.animationDuration = const Duration(milliseconds: 500),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: percentage.clamp(0.0, 1.0)),
          duration: animationDuration,
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            );
          },
        ),
      ),
    );
  }
}
