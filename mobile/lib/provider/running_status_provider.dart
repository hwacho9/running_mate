import 'package:flutter/foundation.dart';

class RunningStatusProvider extends ChangeNotifier {
  bool _isRunning = false; // 런닝 진행 여부
  bool _isPaused = false; // 일시정지 여부

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  void startRunning() {
    _isRunning = true;
    _isPaused = false;
    notifyListeners();
  }

  void pauseRunning() {
    _isPaused = true;
    notifyListeners();
  }

  void resumeRunning() {
    _isPaused = false;
    notifyListeners();
  }

  void stopRunning() {
    _isRunning = false;
    _isPaused = false;
    notifyListeners();
  }
}
