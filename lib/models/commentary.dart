// =============================================================================
// commentary.dart — AI 해설 캐시 (§7). 읽기 전용(생성은 Edge Function).
//   캐시 키 = (workId, language). version/cachedAt으로 무효화.
// =============================================================================

import 'model_utils.dart';

class Commentary {
  final String workId;
  final String language; // 캐시 키에 언어 필수(§7)
  final String body;
  final int version;
  final DateTime? cachedAt;

  const Commentary({
    required this.workId,
    required this.language,
    required this.body,
    this.version = 1,
    this.cachedAt,
  });

  factory Commentary.fromJson(Map<String, dynamic> j) => Commentary(
        workId: j['work_id'] as String,
        language: j['language'] as String,
        body: j['body'] as String,
        version: (j['version'] as int?) ?? 1,
        cachedAt: parseDate(j['cached_at']),
      );

  Map<String, dynamic> toJson() => {
        'work_id': workId,
        'language': language,
        'body': body,
        'version': version,
      };
}
