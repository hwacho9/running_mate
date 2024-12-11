// region_converter.dart
import 'package:running_mate/data/regionJapanMapping.dart';

/// 일본어 지역명을 한국어로 변환
String convertJapaneseToKorean(String japaneseRegion) {
  return regionMapping[japaneseRegion] ?? japaneseRegion;
}

/// 한국어 지역명을 일본어로 변환
String convertKoreanToJapanese(String koreanRegion) {
  final reversedMapping =
      regionMapping.map((key, value) => MapEntry(value, key));
  return reversedMapping[koreanRegion] ?? koreanRegion;
}
