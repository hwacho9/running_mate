import 'package:flutter/foundation.dart';

class RunningStatusProvider extends ChangeNotifier {
  bool _isRunning = false;
  bool _isPaused = false;

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  void startRunning(Function(bool) updateCallback) {
    _isRunning = true;
    _isPaused = false;
    notifyListeners();
    updateCallback(_isRunning); // Firebase 업데이트
  }

  void pauseRunning() {
    _isPaused = true;
    notifyListeners();
  }

  void resumeRunning() {
    _isPaused = false;
    notifyListeners();
  }

  void stopRunning(Function(bool) updateCallback) {
    _isRunning = false;
    _isPaused = false;
    notifyListeners();
    updateCallback(_isRunning); // Firebase 업데이트
  }
}
