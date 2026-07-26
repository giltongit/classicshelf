// =============================================================================
// model_utils.dart — 모델 공용 유틸 (날짜 변환 등)
//   여러 모델 파일이 공유하므로 분리.
// =============================================================================

/// Postgres date/timestamptz 문자열 또는 DateTime → DateTime?
DateTime? parseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v as String);
}

/// date 컬럼(acquired_at/disposed_at 등)은 날짜만 의미. ISO 날짜 문자열로 직렬화.
String? dateToJson(DateTime? d) {
  if (d == null) return null;
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
