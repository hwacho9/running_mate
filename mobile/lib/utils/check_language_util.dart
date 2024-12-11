class CheckLanguageUtil {
  static bool isKoreanRegion(String region) {
    // 한국어 유니코드 범위 체크
    final koreanRegExp = RegExp(r'[\uac00-\ud7a3]');
    return koreanRegExp.hasMatch(region);
  }
}
