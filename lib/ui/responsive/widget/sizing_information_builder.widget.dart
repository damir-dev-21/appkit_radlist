import 'package:appkit/ui/responsive/model/sizing_information.dart';
import 'package:appkit/ui/responsive/responsive.dart';
import 'package:flutter/material.dart';

/// Provides [SizingInformation] to [builder].
class SizingInformationBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, SizingInformation sizingInformation) builder;

  SizingInformationBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      final mediaQuery = MediaQuery.of(context);
      final sizingInformation = SizingInformation(
        deviceScreenType: Responsive.deviceTypeFromSize(mediaQuery.size),
        screenSize: mediaQuery.size,
        localWidgetSize: boxConstraints.biggest,
      );
      return builder(context, sizingInformation);
    });
  }
}
