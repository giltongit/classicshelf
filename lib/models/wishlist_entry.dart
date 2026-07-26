// =============================================================================
// wishlist_entry.dart — 희망 목록 (§6-2). 독립 애그리게이트 루트.
//   album/work 이중: 특정 릴리스 희망 vs 작품 자체 희망(연주 무관).
// =============================================================================

/// 희망 목록 대상 유형 (§6-2)
enum WishType {
  album,
  work;

  static WishType fromString(String s) =>
      s == 'work' ? WishType.work : WishType.album;

  String get value => name;
}

class WishItem {
  final String id;
  final WishType type;
  final String? albumId; // type=album일 때
  final String? workId; // type=work일 때
  final int? priority;
  final String? note;

  const WishItem({
    required this.id,
    required this.type,
    this.albumId,
    this.workId,
    this.priority,
    this.note,
  });

  /// CHECK 제약(§6-2)과 동일한 정합. 리포지토리 저장 전 가드로 사용.
  bool get isValid => switch (type) {
        WishType.album => albumId != null && workId == null,
        WishType.work => workId != null && albumId == null,
      };

  factory WishItem.album({
    required String id,
    required String albumId,
    int? priority,
    String? note,
  }) =>
      WishItem(
          id: id,
          type: WishType.album,
          albumId: albumId,
          priority: priority,
          note: note);

  factory WishItem.work({
    required String id,
    required String workId,
    int? priority,
    String? note,
  }) =>
      WishItem(
          id: id,
          type: WishType.work,
          workId: workId,
          priority: priority,
          note: note);

  factory WishItem.fromJson(Map<String, dynamic> j) => WishItem(
        id: j['id'] as String,
        type: WishType.fromString(j['type'] as String),
        albumId: j['album_id'] as String?,
        workId: j['work_id'] as String?,
        priority: j['priority'] as int?,
        note: j['note'] as String?,
      );

  /// wishlist 행. user_id는 리포지토리가 덧붙인다.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.value,
        'album_id': albumId,
        'work_id': workId,
        'priority': priority,
        'note': note,
      };
}
