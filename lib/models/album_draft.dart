// =============================================================================
// album_draft.dart — 외부 조회 결과 → 등록 폼 프리필용 초안 (아키텍처 v10 §4-1)
//
// 왜 Album을 그대로 쓰지 않고 별도 계층을 두는가:
//   · Album 애그리게이트는 id(uuid)를 가진 "저장할 실체"다. 초안은 아직 실체가
//     아니라서 id가 없어야 한다 — id는 폼이 카드/행을 만들 때 발급한다.
//     초안이 id를 들고 오면, 사용자가 취소한 조회 결과의 id가 떠돌게 된다.
//   · Composition.composer는 non-null인데, 초안 단계에서는 작곡가를 못 찾는 일이
//     흔하다(Discogs 크레딧 관행이 일정하지 않다). 초안은 빈 문자열을 허용한다.
//
// add_book_screen.dart 상단 주석의 "Draft는 대 2 자동입력에서 필요해지면"이
// 바로 이 파일이다.
//
// 출처 무관하게 재사용 가능한 형태로 둔다(지금 공급자는 Discogs 하나뿐이지만,
// sourceName/sourceUrl로 일반화해 두면 다른 공급자가 붙어도 폼은 안 바뀐다).
// =============================================================================

/// 초안 단계의 연주자. 역할 문자열은 PerformerRole.value와 같은 어휘를 쓴다.
class DraftPerformer {
  final String role; // conductor / orchestra / soloist / ensemble / vocalist
  final String name;

  const DraftPerformer({required this.role, required this.name});
}

/// 초안 단계의 악장. 폼의 _MovementRow에 1:1로 들어간다.
class DraftMovement {
  final String title;
  final int? trackNo;
  final int? durationSec;

  const DraftMovement({required this.title, this.trackNo, this.durationSec});
}

/// 초안 단계의 수록곡. 폼의 _CompositionCard에 1:1로 들어간다.
class DraftComposition {
  /// 못 찾았으면 빈 문자열. 폼이 빈 채로 보여주고 사용자가 채운다
  /// (억지로 추측해 넣지 않는다 — §4-2 선택 입력 철학).
  final String composer;

  final String? title;
  final String? catalogNumber;
  final int? discNo;
  final int? trackFrom;
  final int? trackTo;
  final List<DraftMovement> movements;

  /// 이 곡만의 연주자 (§3-3 곡별 override). **null = 앨범 기본값 상속**이고,
  /// 빈 리스트를 넣지 않는다 — 저장 계층(Composition.performerOverrides)이
  /// null과 빈 리스트를 같은 뜻으로 보되 왕복 형태를 null로 맞추기 때문이다.
  ///
  /// 앨범 기본값과 **다른** 역할만 담는다. 같은 값을 굳이 override로 복사하면
  /// 상속이 끊겨서, 나중에 앨범 기본 연주자를 고쳐도 이 곡만 옛 값에 남는다.
  final List<DraftPerformer>? performerOverrides;

  const DraftComposition({
    this.composer = '',
    this.title,
    this.catalogNumber,
    this.discNo,
    this.trackFrom,
    this.trackTo,
    this.movements = const [],
    this.performerOverrides,
  });
}

/// 음반 등록 폼에 주입할 초안 한 벌.
class AlbumDraft {
  final String? title;
  final String? label;
  final int? releaseYear;
  final int? discCount;
  final String? format; // kAlbumFormats 중 하나로 정규화된 값
  final String? barcode;

  final List<DraftPerformer> defaultPerformers;
  final List<DraftComposition> compositions;

  /// 출처 표기용 (§2-5 · Discogs API Terms). 이 둘이 있으면 폼 상단에
  /// "Data provided by …" 배지 + 원본 링크를 띄운다.
  final String? sourceName;
  final String? sourceUrl;

  const AlbumDraft({
    this.title,
    this.label,
    this.releaseYear,
    this.discCount,
    this.format,
    this.barcode,
    this.defaultPerformers = const [],
    this.compositions = const [],
    this.sourceName,
    this.sourceUrl,
  });

  /// 출처 배지를 띄울 조건. 이름·링크가 모두 있어야 표기 의무를 온전히 지킨다.
  bool get hasAttribution =>
      sourceName != null && sourceUrl != null && sourceUrl!.isNotEmpty;
}
