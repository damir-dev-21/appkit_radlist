import 'package:flutter/material.dart';

/// Displays an indicator that shows the current item ([index]) from a number
/// of items ([itemCount]), which is usually used in carousel-type user interfaces.
class AppDotIndicator extends StatelessWidget {
  final int itemCount;
  final int index;
  final Color activeColor;
  final Color inactiveColor;
  final bool scalable;

  AppDotIndicator({
    Key? key,
    required this.itemCount,
    required this.index,
    Color? activeColor,
    Color? inactiveColor,
    this.scalable = true,
  })  : this.activeColor = activeColor ?? Colors.white,
        this.inactiveColor = inactiveColor ?? Colors.white.withAlpha(127),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(itemCount, (i) {
          final size = i == index ? 12.0 : 6.0;
          final color = i == index ? activeColor : inactiveColor;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: scalable ? size : 8,
            height: scalable ? size : 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size / 2),
            ),
          );
        }),
      ),
    );
  }
}
