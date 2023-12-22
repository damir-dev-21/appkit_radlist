import 'package:flutter/material.dart';

/// Ignores the text scaling settings on user's device, enforces default font size.
class AppIgnoreTextScale extends StatelessWidget {
  final Widget child;

  const AppIgnoreTextScale({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
      child: child,
    );
  }
}
