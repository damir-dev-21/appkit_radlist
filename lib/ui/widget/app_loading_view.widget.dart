import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

import 'app_frosted_blur.widget.dart';
import 'app_loading_indicator.dart';

class AppLoadingView extends StatelessWidget {
  final Widget? child;
  final bool loading;
  final double? size;
  final Color? color;

  AppLoadingView({
    required this.loading,
    this.child,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: loading,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (child != null) Opacity(opacity: loading ? 0.8 : 1, child: child),
          if (loading)
            Positioned.fill(
              child: AppFrostedFilter(
                opacity: 0.1,
                blurRadius: 3,
                color: theme(context).backgroundColor,
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: theme(context).borderRadius,
                    ),
                    alignment: Alignment.center,
                    child: AppLoadingIndicator(
                      size: size,
                      color: color ?? Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
