// =============================================================================
// wishlist_entry.dart — 희망 목록 (§6-2). 독립 애그리게이트 루트.
//   album/work 이중: 특정 릴리스 희망 vs 작품 자체 희망(연주 무관).
//
// 표현 수단 두 가지가 공존한다(마이그레이션 20260804120000_wishlist_free_text):
//   · composer / title  = 자유 텍스트. 지금 위시를 표현하는 주 수단.
//                         compositions.title(§3-1a)과 동일 성격 — FK 없이도 성립.
//   · albumId / workId  = 확정 연결. Works 시드(대 1-A)·자동 해소 감지가 붙는
//                         이후 작업에서 채운다(§17 부채). 지금은 보통 null.
// =============================================================================

/// 희망 목록 대상 유형 (§6-2)
enum WishType {
  album,
  work;

  static WishType fromString(String s) =>
      s == 'work' ? WishType.work : WishType.album;

  String get value => name;

  /// 목록 카드 배지 문구.
  String get label => switch (this) {
        WishType.album => '음반 단위',
        WishType.work => '작품 단위',
      };
}

class WishItem {
  final String id;
  final WishType type;
  final String? albumId; // 확정 연결 (type=album일 때만)
  final String? workId; // 확정 연결 (type=work일 때만)
  final String? composer; // 자유 텍스트
  final String? title; // 자유 텍스트 — 작품명 또는 음반명
  final int? priority;
  final String? note;
  final DateTime? createdAt; // 서버/로컬 기본값. 신규 생성 시 null(=DB가 채움).

  const WishItem({
    required this.id,
    required this.type,
    this.albumId,
    this.workId,
    this.composer,
    this.title,
    this.priority,
    this.note,
    this.createdAt,
  });

  /// CHECK 제약(§6-2, 완화판)과 동일한 정합. 리포지토리 저장 전 가드로 사용.
  ///   · 유형과 어긋난 FK 금지 — type=album에 workId가 붙으면 위반(그 반대도).
  ///   · 유형에 맞는 FK / composer / title 중 최소 하나는 채워져야 한다.
  bool get isValid {
    final hasFreeText = (composer != null && composer!.isNotEmpty) ||
        (title != null && title!.isNotEmpty);
    return switch (type) {
      WishType.album => workId == null && (albumId != null || hasFreeText),
      WishType.work => albumId == null && (workId != null || hasFreeText),
    };
  }

  /// 카드 제목 — 자유 텍스트 우선, 없으면 대체 문구.
  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (composer != null && composer!.isNotEmpty) return composer!;
    return '(제목 없음)';
  }

  /// 카드 부제 — displayTitle이 title을 쓴 경우에만 composer를 따로 보인다.
  String? get displaySubtitle {
    if (composer == null || composer!.isEmpty) return null;
    if (title == null || title!.isEmpty) return null; // 이미 제목 자리에 나옴
    return composer;
  }

  factory WishItem.album({
    required String id,
    String? albumId,
    String? composer,
    String? title,
    int? priority,
    String? note,
  }) =>
      WishItem(
        id: id,
        type: WishType.album,
        albumId: albumId,
        composer: composer,
        title: title,
        priority: priority,
        note: note,
      );

  factory WishItem.work({
    required String id,
    String? workId,
    String? composer,
    String? title,
    int? priority,
    String? note,
  }) =>
      WishItem(
        id: id,
        type: WishType.work,
        workId: workId,
        composer: composer,
        title: title,
        priority: priority,
        note: note,
      );

  factory WishItem.fromJson(Map<String, dynamic> j) => WishItem(
        id: j['id'] as String,
        type: WishType.fromString(j['type'] as String),
        albumId: j['album_id'] as String?,
        workId: j['work_id'] as String?,
        composer: j['composer'] as String?,
        title: j['title'] as String?,
        priority: j['priority'] as int?,
        note: j['note'] as String?,
        createdAt: j['created_at'] == null
            ? null
            : DateTime.parse(j['created_at'] as String),
      );

  /// wishlist 행. user_id는 리포지토리가 덧붙인다.
  /// created_at은 보내지 않는다 — 서버 기본값(now())에 맡긴다.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.value,
        'album_id': albumId,
        'work_id': workId,
        'composer': composer,
        'title': title,
        'priority': priority,
        'note': note,
      };
}
