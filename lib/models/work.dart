// =============================================================================
// work.dart — 정규 작품 참조 데이터 (§3-7). 읽기 전용, 애그리게이트 아님.
//   구성: Work · WorkMovement · WorkAlias.
//   자동완성·악장 자동 로드(§4-3)·희망(work)·AI 해설 캐시 키가 참조.
// =============================================================================

import 'album.dart' show Movement;

/// 표준 악장 (WorkMovements 테이블)
class WorkMovement {
  final int seq;
  final String title;
  final String? tempoMark;

  const WorkMovement({required this.seq, required this.title, this.tempoMark});

  factory WorkMovement.fromJson(Map<String, dynamic> j) => WorkMovement(
        seq: j['seq'] as int,
        title: j['title'] as String,
        tempoMark: j['tempo_mark'] as String?,
      );
}

/// 표기 변형 별칭 (WorkAliases 테이블, §6-3)
class WorkAlias {
  final String id;
  final String? workId;
  final String? composerKey; // 작곡가 단위 별칭
  final String alias;
  final String? language;

  const WorkAlias({
    required this.id,
    this.workId,
    this.composerKey,
    required this.alias,
    this.language,
  });

  factory WorkAlias.fromJson(Map<String, dynamic> j) => WorkAlias(
        id: j['id'] as String,
        workId: j['work_id'] as String?,
        composerKey: j['composer_key'] as String?,
        alias: j['alias'] as String,
        language: j['language'] as String?,
      );
}

/// 시대(period)의 연대순. Open Opus의 epoch 값을 그대로 쓴다.
/// 정렬에만 쓰는 표시 순서다 — 가나다·알파벳순으로 두면 "20th Century, Baroque,
/// Classical, Early Romantic…"처럼 시대 감각과 어긋난 목록이 된다.
/// 여기 없는 값은 뒤에 붙인다(상류에서 새 epoch가 생겨도 누락되지 않게).
const kMusicalPeriodOrder = [
  'Medieval',
  'Renaissance',
  'Baroque',
  'Classical',
  'Early Romantic',
  'Romantic',
  'Late Romantic',
  '20th Century',
  'Post-War',
  '21st Century',
];

/// [kMusicalPeriodOrder] 기준 연대순 비교. 목록에 없는 값은 뒤로.
int compareMusicalPeriods(String a, String b) {
  final ia = kMusicalPeriodOrder.indexOf(a);
  final ib = kMusicalPeriodOrder.indexOf(b);
  if (ia == -1 && ib == -1) return a.compareTo(b);
  if (ia == -1) return 1;
  if (ib == -1) return -1;
  return ia.compareTo(ib);
}

/// 정규 작품
class Work {
  final String id; // Open Opus / MusicBrainz 식별자
  final String composer;
  final String title; // 원어 정규명
  final String? catalogNumber;
  final String? musicalKey;
  final String? genre;
  final String? period;
  final bool popular; // 자동완성 순위(§3-7)
  final bool recommended;
  final String source; // openopus / musicbrainz / user
  final List<WorkMovement> standardMovements; // 악장 자동 로드의 원본(§4-3)

  const Work({
    required this.id,
    required this.composer,
    required this.title,
    this.catalogNumber,
    this.musicalKey,
    this.genre,
    this.period,
    this.popular = false,
    this.recommended = false,
    this.source = 'openopus',
    this.standardMovements = const [],
  });

  /// 악장 자동 로드(§4-3): 표준 악장(WorkMovement)을 수록 악장(Movement)으로 복제.
  /// 복제 후 사용자가 편집한다. id는 클라이언트가 새로 부여(uuidGen 주입 →
  /// 도메인이 uuid 패키지를 직접 import하지 않는다).
  List<Movement> toMovements(String Function() uuidGen) => standardMovements
      .map((wm) => Movement(id: uuidGen(), seq: wm.seq, title: wm.title))
      .toList();

  factory Work.fromJson(
    Map<String, dynamic> j, {
    List<WorkMovement> standardMovements = const [],
  }) =>
      Work(
        id: j['id'] as String,
        composer: j['composer'] as String,
        title: j['title'] as String,
        catalogNumber: j['catalog_number'] as String?,
        musicalKey: j['musical_key'] as String?,
        genre: j['genre'] as String?,
        period: j['period'] as String?,
        popular: (j['popular'] as bool?) ?? false,
        recommended: (j['recommended'] as bool?) ?? false,
        source: (j['source'] as String?) ?? 'openopus',
        standardMovements: standardMovements,
      );
}
