import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  final bool fullWidth;
  final Color? color;
  final double indent;

  const AppDivider({
    Key? key,
    this.color,
    this.fullWidth = false,
    this.indent = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: fullWidth ? 0 : indent,
      endIndent: fullWidth ? 0 : indent,
      color: color,
      thickness: .5,
    );
  }
}
