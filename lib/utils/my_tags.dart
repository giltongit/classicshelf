/// "내 분류" — genre 컬럼에 쉼표로 구분해 저장하는 사용자 세부 라벨 (결정 #29, §26).
///
/// §24가 genre 컬럼을 자유 태그로 재정의했고, §26이 이를 "장르에 종속된 짧은
/// 재사용 라벨"로 다시 규정했다. 메모(review, 산문형 코멘트)와는 성격이 다르다.
///
/// 저장 형식은 `SF,디스토피아`. 쉼표를 구분자로 쓰지만 CSV 내보내기는 csv 패키지가
/// 쉼표 포함 필드를 자동 인용하므로 라운드트립에 문제가 없다.
library;

/// genre 컬럼 원문을 태그 목록으로 파싱한다. 쉼표 split → trim → 빈 값 제거.
List<String> parseMyTags(String? raw) {
  if (raw == null) return const [];
  return raw
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();
}

/// 태그 목록을 genre 컬럼에 저장할 문자열로 만든다. 비면 null(컬럼 비우기).
String? joinMyTags(Iterable<String> tags) {
  final cleaned =
      tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  return cleaned.isEmpty ? null : cleaned.join(',');
}
