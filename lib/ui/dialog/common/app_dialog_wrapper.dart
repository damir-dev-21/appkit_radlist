import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppDialogWrapper extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? insetPadding;
  final bool? isCancelable;

  /// If true, then the width of the dialog is constrained to be at most 400
  final bool constrainWidth;
  final BorderRadius? borderRadius;

  const AppDialogWrapper({
    Key? key,
    this.child,
    this.insetPadding = const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
    this.isCancelable = true,
    this.constrainWidth = true,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Backdrop.
        GestureDetector(
          onTap: () {
            if (isCancelable == true) {
              Navigator.pop(context);
            }
          },
          child: Container(color: Colors.black.withAlpha(100)),
        ),
        Dialog(
          elevation: 24,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          insetPadding: insetPadding,
          backgroundColor: Colors.transparent,
          child: Material(
            borderRadius: borderRadius,
            color: theme(context).surfaceColor,
            child: constrainWidth
                ? ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ),
                    child: child,
                  )
                : child,
          ),
        ),
      ],
    );
  }
}
