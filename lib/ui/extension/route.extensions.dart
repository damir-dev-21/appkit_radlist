import 'package:flutter/material.dart';

extension RouteExtensions on Route<dynamic> {
  bool get isTransparentPopup {
    if (this is PopupRoute) {
      return !(this as PopupRoute).opaque;
    } else if (this is PageRouteBuilder) {
      return !(this as PageRouteBuilder).opaque;
    }
    return false;
  }
}
