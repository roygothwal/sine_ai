import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchController extends ChangeNotifier {
  Timer? _timer;
  int _milliseconds = 0;
  bool _isRunning = false;
  final List<int> _laps = [];

  int get milliseconds => _milliseconds;
  bool get isRunning => _isRunning;
  List<int> get laps => _laps;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _milliseconds += 10;
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    pause();
    _milliseconds = 0;
    _laps.clear();
    notifyListeners();
  }

  void lap() {
    _laps.insert(0, _milliseconds);
    notifyListeners();
  }

  String formatTime(int ms) {
    int hundredths = (ms / 10).truncate() % 100;
    int seconds = (ms / 1000).truncate() % 60;
    int minutes = (ms / 60000).truncate() % 60;
    int hours = (ms / 3600000).truncate();

    String h = hours.toString().padLeft(2, '0');
    String m = minutes.toString().padLeft(2, '0');
    String s = seconds.toString().padLeft(2, '0');
    String msStr = hundredths.toString().padLeft(2, '0');

    if (hours > 0) {
      return "$h:$m:$s.$msStr";
    } else {
      return "$m:$s.$msStr";
    }
  }
}
