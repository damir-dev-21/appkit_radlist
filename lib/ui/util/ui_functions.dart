import 'package:appkit/ui/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

Widget horizontalSpace(double size) {
  return SizedBox(width: size);
}

Widget verticalSpace(double size) {
  return SizedBox(height: size);
}

BoxShadow topShadow() {
  return BoxShadow(
    color: Colors.black.withAlpha(15),
    offset: Offset(0, -2),
    blurRadius: 6,
  );
}

BoxShadow bottomShadow() {
  return BoxShadow(color: Colors.black.withAlpha(50), offset: Offset(0, 2), blurRadius: 4);
}

void nextFrame(void Function() fn) {
  SchedulerBinding.instance.addPostFrameCallback((_) => fn());
}

bool isPhone(BuildContext context) {
  return Responsive.isPhone(context);
}
