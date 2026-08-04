// =============================================================================
// album.dart — Album 애그리게이트 (루트 + 내부 엔티티)
//   구성: Album(루트) · Composition · Movement · Performer + 관련 enum.
//   대응: 아키텍처 v03 §3-1, §3-2 / Supabase 20260725052147.
//
// 설계(합의):
//   · Album이 애그리게이트 루트. 저장·동기화 단위는 Album 통째(embed).
//   · 도메인 모델은 sync 관심사(syncState/updatedAt/cachedAt)를 갖지 않는다.
//   · 연주자 상속(§3-2)은 Composition.effectivePerformers(album) 한 곳에 갇힌다.
//   · 목록 화면은 이 애그리게이트 대신 경량 AlbumSummary(album_summary.dart)를 쓴다.
//
// 애그리게이트가 한 파일에 묶인 이유: Album→Composition→Movement/Performer가
//   강하게 결합돼 상호 참조하므로, 분리하면 상호 import만 늘어난다.
// =============================================================================

import 'model_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// enum
// ─────────────────────────────────────────────────────────────────────────────

/// 연주자 역할 (§3-2)
enum PerformerRole {
  conductor,
  orchestra,
  soloist,
  ensemble,
  vocalist,
  unknown; // 미래 확장/미상값 수용

  static PerformerRole fromString(String? s) => switch (s) {
        'conductor' => PerformerRole.conductor,
        'orchestra' => PerformerRole.orchestra,
        'soloist' => PerformerRole.soloist,
        'ensemble' => PerformerRole.ensemble,
        'vocalist' => PerformerRole.vocalist,
        _ => PerformerRole.unknown,
      };

  String get value => name;
}

/// 수록곡 작품 매칭 신뢰도 (§3-4). 검증 큐(§4-5)가 이 값으로 필터.
enum Confidence {
  confirmed,
  unverified;

  static Confidence fromString(String? s) =>
      s == 'confirmed' ? Confidence.confirmed : Confidence.unverified;

  String get value => name;
}

/// 소장 상태 — disposed_at 기반 파생 (§6-2, 처분·분실 포함)
enum HoldingStatus { owned, disposed }

/// 포맷 선택지. albums.format은 자유 텍스트지만 입력·필터 모두 이 넷으로 제한한다.
/// 등록 폼과 필터 시트가 같은 목록을 봐야 필터가 입력값을 놓치지 않는다.
const kAlbumFormats = ['CD', 'LP', 'SACD', 'digital'];

// ─────────────────────────────────────────────────────────────────────────────
// Performer — 값 객체. 저장에서는 album_performers/composition_performers 행.
// ─────────────────────────────────────────────────────────────────────────────

class Performer {
  final String id; // 클라이언트 UUID
  final PerformerRole role;
  final String name;

  const Performer({required this.id, required this.role, required this.name});

  Performer copyWith({PerformerRole? role, String? name}) => Performer(
        id: id,
        role: role ?? this.role,
        name: name ?? this.name,
      );

  factory Performer.fromJson(Map<String, dynamic> j) => Performer(
        id: j['id'] as String,
        role: PerformerRole.fromString(j['role'] as String?),
        name: j['name'] as String,
      );

  /// 공통 필드. 부모 FK(album_id/composition_id)와 user_id는 리포지토리가 덧붙인다.
  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.value,
        'name': name,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Movement — 실제 수록 악장 (§3-1). Composition 내부.
// ─────────────────────────────────────────────────────────────────────────────

class Movement {
  final String id;
  final int seq;
  final String title;
  final int? trackNo;
  final int? durationSec;

  const Movement({
    required this.id,
    required this.seq,
    required this.title,
    this.trackNo,
    this.durationSec,
  });

  Movement copyWith({int? seq, String? title, int? trackNo, int? durationSec}) =>
      Movement(
        id: id,
        seq: seq ?? this.seq,
        title: title ?? this.title,
        trackNo: trackNo ?? this.trackNo,
        durationSec: durationSec ?? this.durationSec,
      );

  factory Movement.fromJson(Map<String, dynamic> j) => Movement(
        id: j['id'] as String,
        seq: j['seq'] as int,
        title: j['title'] as String,
        trackNo: j['track_no'] as int?,
        durationSec: j['duration_sec'] as int?,
      );

  /// composition_id / user_id는 리포지토리가 덧붙인다.
  Map<String, dynamic> toJson() => {
        'id': id,
        'seq': seq,
        'title': title,
        'track_no': trackNo,
        'duration_sec': durationSec,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Composition — 수록곡 (§3-1). Album 애그리게이트 내부.
// ─────────────────────────────────────────────────────────────────────────────

class Composition {
  final String id;
  final String? workId; // 정규 작품 참조. null = 미매칭(§3-4)

  /// 사용자가 적는 자유 텍스트 작품 제목. workId와 공존한다(대체 아님).
  /// 매칭이 붙어도 보존한다 — 발췌·편곡판 등 음반 고유 정보가 여기 남는다.
  final String? title;

  final String composer;
  final String? catalogNumber; // BWV/K./Op.
  final int? discNo;
  final int? trackFrom;
  final int? trackTo;
  final int seq; // 음반 내 표시 순서
  final Confidence confidence;
  final List<Movement> movements;

  /// 곡별 연주자 예외. null(=상속)과 빈 리스트를 구분하려면 null을 쓴다.
  final List<Performer>? performerOverrides;

  const Composition({
    required this.id,
    this.workId,
    this.title,
    required this.composer,
    this.catalogNumber,
    this.discNo,
    this.trackFrom,
    this.trackTo,
    this.seq = 0,
    this.confidence = Confidence.unverified,
    this.movements = const [],
    this.performerOverrides,
  });

  bool get hasPerformerOverride =>
      performerOverrides != null && performerOverrides!.isNotEmpty;

  /// 이 수록곡의 실효 연주자 목록 (§3-2 상속 규칙의 유일한 구현 지점).
  ///
  /// 역할별로: override에 해당 역할이 있으면 override, 없으면 앨범 기본값 상속.
  /// override가 아예 없으면 전부 상속.
  ///
  /// Supabase 조회 경로와 로컬 조회 경로 모두 이 메서드를 거쳐야 기기 간 일치.
  List<Performer> effectivePerformers(Album album) {
    if (!hasPerformerOverride) return album.defaultPerformers;

    final overrides = performerOverrides!;
    final overriddenRoles = overrides.map((p) => p.role).toSet();
    final inherited = album.defaultPerformers
        .where((p) => !overriddenRoles.contains(p.role));

    return [...overrides, ...inherited];
  }

  Composition copyWith({
    String? workId,
    bool setWorkIdNull = false,
    String? title,
    String? composer,
    String? catalogNumber,
    int? discNo,
    int? trackFrom,
    int? trackTo,
    int? seq,
    Confidence? confidence,
    List<Movement>? movements,
    List<Performer>? performerOverrides,
    bool clearOverrides = false,
  }) =>
      Composition(
        id: id,
        workId: setWorkIdNull ? null : (workId ?? this.workId),
        title: title ?? this.title,
        composer: composer ?? this.composer,
        catalogNumber: catalogNumber ?? this.catalogNumber,
        discNo: discNo ?? this.discNo,
        trackFrom: trackFrom ?? this.trackFrom,
        trackTo: trackTo ?? this.trackTo,
        seq: seq ?? this.seq,
        confidence: confidence ?? this.confidence,
        movements: movements ?? this.movements,
        performerOverrides:
            clearOverrides ? null : (performerOverrides ?? this.performerOverrides),
      );

  factory Composition.fromJson(
    Map<String, dynamic> j, {
    List<Movement> movements = const [],
    List<Performer>? performerOverrides,
  }) =>
      Composition(
        id: j['id'] as String,
        workId: j['work_id'] as String?,
        title: j['title'] as String?,
        composer: j['composer'] as String,
        catalogNumber: j['catalog_number'] as String?,
        discNo: j['disc_no'] as int?,
        trackFrom: j['track_from'] as int?,
        trackTo: j['track_to'] as int?,
        seq: (j['seq'] as int?) ?? 0,
        confidence: Confidence.fromString(j['confidence'] as String?),
        movements: movements,
        performerOverrides: performerOverrides,
      );

  /// compositions 행 필드. album_id/user_id는 리포지토리가 덧붙인다.
  /// movements·performerOverrides는 별도 테이블이므로 여기 미포함.
  Map<String, dynamic> toJson() => {
        'id': id,
        'work_id': workId,
        'title': title,
        'composer': composer,
        'catalog_number': catalogNumber,
        'disc_no': discNo,
        'track_from': trackFrom,
        'track_to': trackTo,
        'seq': seq,
        'confidence': confidence.value,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Album — 애그리게이트 루트 (§3-1). 저장·동기화의 커밋 단위.
// ─────────────────────────────────────────────────────────────────────────────

class Album {
  final String id; // 클라이언트 UUID (생성 시점 확정)
  final String title;
  final String? label;
  final int? releaseYear;
  final int discCount;
  final String? format; // CD / LP / SACD / digital
  final String? barcode; // EAN-13 (중복 감지 §4-3)
  final String? coverUrl;
  final String? location;
  final String? review;
  final DateTime? acquiredAt;
  final DateTime? disposedAt; // null = 소장중, 값 있으면 처분·분실(§6-2)

  final List<Performer> defaultPerformers; // 음반 기본 연주자(§3-2)
  final List<Composition> compositions;

  const Album({
    required this.id,
    required this.title,
    this.label,
    this.releaseYear,
    this.discCount = 1,
    this.format,
    this.barcode,
    this.coverUrl,
    this.location,
    this.review,
    this.acquiredAt,
    this.disposedAt,
    this.defaultPerformers = const [],
    this.compositions = const [],
  });

  HoldingStatus get status =>
      disposedAt == null ? HoldingStatus.owned : HoldingStatus.disposed;

  /// 미확인 필드 보유 여부 — "확인 필요" 배지(§6-1)·검증 큐(§4-5) 판단.
  bool get needsVerification =>
      compositions.any((c) => c.confidence == Confidence.unverified);

  Album copyWith({
    String? title,
    String? label,
    int? releaseYear,
    int? discCount,
    String? format,
    String? barcode,
    String? coverUrl,
    String? location,
    String? review,
    DateTime? acquiredAt,
    DateTime? disposedAt,
    bool clearDisposedAt = false,
    List<Performer>? defaultPerformers,
    List<Composition>? compositions,
  }) =>
      Album(
        id: id,
        title: title ?? this.title,
        label: label ?? this.label,
        releaseYear: releaseYear ?? this.releaseYear,
        discCount: discCount ?? this.discCount,
        format: format ?? this.format,
        barcode: barcode ?? this.barcode,
        coverUrl: coverUrl ?? this.coverUrl,
        location: location ?? this.location,
        review: review ?? this.review,
        acquiredAt: acquiredAt ?? this.acquiredAt,
        disposedAt: clearDisposedAt ? null : (disposedAt ?? this.disposedAt),
        defaultPerformers: defaultPerformers ?? this.defaultPerformers,
        compositions: compositions ?? this.compositions,
      );

  /// 애그리게이트 조립: 평면 테이블에서 읽은 조각들을 Album 트리로 결합.
  factory Album.assemble({
    required Map<String, dynamic> albumJson,
    required List<Performer> defaultPerformers,
    required List<Composition> compositions,
  }) =>
      Album(
        id: albumJson['id'] as String,
        title: albumJson['title'] as String,
        label: albumJson['label'] as String?,
        releaseYear: albumJson['release_year'] as int?,
        discCount: (albumJson['disc_count'] as int?) ?? 1,
        format: albumJson['format'] as String?,
        barcode: albumJson['barcode'] as String?,
        coverUrl: albumJson['cover_url'] as String?,
        location: albumJson['location'] as String?,
        review: albumJson['review'] as String?,
        acquiredAt: parseDate(albumJson['acquired_at']),
        disposedAt: parseDate(albumJson['disposed_at']),
        defaultPerformers: defaultPerformers,
        compositions: compositions,
      );

  /// albums 행 필드. user_id는 리포지토리가 덧붙인다.
  /// 하위는 각자 테이블로 분해되므로 미포함.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'label': label,
        'release_year': releaseYear,
        'disc_count': discCount,
        'format': format,
        'barcode': barcode,
        'cover_url': coverUrl,
        'location': location,
        'review': review,
        'acquired_at': dateToJson(acquiredAt),
        'disposed_at': dateToJson(disposedAt),
      };
}
