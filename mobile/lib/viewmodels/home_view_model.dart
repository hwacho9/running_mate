import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:running_mate/models/user_stats_model.dart';
import 'package:running_mate/services/user_stats_service.dart';

class HomeViewModel extends ChangeNotifier {
  final UserStatsService _statsService;
  UserStats? _userStats;
  bool _isLoading = false;
  StreamSubscription? _userStatsSubscription;
  HomeViewModel(this._statsService);

  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;

  // UserStats 데이터 불러오기
  void loadUserStats(String userId) {
    // 기존의 데이터를 클리어하고 로딩 상태로 설정
    _isLoading = true;
    notifyListeners();

    // 이전 구독이 있으면 취소
    _userStatsSubscription?.cancel();

    // Firebase의 스트림 구독 시작
    _userStatsSubscription = _statsService.getUserStats(userId).listen(
      (userStats) {
        _userStats = userStats;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Failed to load user stats: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // 구독 취소 메서드 (뷰모델이 dispose될 때 호출)
  void dispose() {
    _userStatsSubscription?.cancel();
    super.dispose();
  }
}
