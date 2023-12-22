import 'dart:async';

import 'package:flutter/material.dart';

class CountDownTimer with ChangeNotifier {
  late int _value;

  int get value => _value;

  late int _initialStartFrom;
  late Timer _timer;

  CountDownTimer({int startFrom = 10}) {
    _value = startFrom;
    _initialStartFrom = startFrom;
  }

  void start() {
    _timer.cancel();
    _timer = new Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_value < 1) {
        timer.cancel();
      } else {
        _value--;
      }
      notifyListeners();
    });
  }

  void pause() {
    _timer.cancel();
  }

  void reset({int startFrom = 10}) {
    _value = startFrom;
    notifyListeners();
    start();
  }

  void stop() {
    _timer.cancel();
    _value = _initialStartFrom;
    notifyListeners();
  }
}
