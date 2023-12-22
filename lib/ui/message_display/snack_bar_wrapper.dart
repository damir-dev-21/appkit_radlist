import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class SnackBarWrapper<T> {
  final Flushbar<T> _flushBar;

  SnackBarWrapper.wrapFlushBar(this._flushBar);

  Future<T?> show(BuildContext context) {
    return _flushBar.show(context);
  }

  Future<T?> dismiss([dynamic result]) {
    return _flushBar.dismiss(result);
  }
}
