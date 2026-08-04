// =============================================================================
// album_filter.dart — 컬렉션 필터 (book_filter.dart 대체)
//   필터 축(§6-3): 작곡가 · 시대 · 포맷 · 소장상태 + 검색어.
//   불변 값 객체. 화면이 조합해 리포지토리 조회에 넘긴다.
// =============================================================================

import 'album.dart' show HoldingStatus;

/// 정렬 기준 (§6-3)
enum AlbumSort {
  createdDesc, // 등록순(기본)
  composerAsc, // 작곡가순
  releaseYearDesc, // 발매연도순
  titleAsc;
}

class AlbumFilter {
  /// FTS 검색어 (§6-3: trigram + 2글자 이하 LIKE 폴백은 리포지토리 책임).
  final String? query;

  final String? composer; // 특정 작곡가
  final String? period; // 시대
  final String? format; // CD / LP / SACD / digital
  final String? conductor; // 지휘자(연주자 필터)

  /// 소장상태. null = 전체, owned/disposed로 좁힘.
  final HoldingStatus? status;

  /// 미확인 항목만 보기(검증 큐 성격, §4-5 목록 필터).
  final bool onlyNeedsVerification;

  final AlbumSort sort;

  const AlbumFilter({
    this.query,
    this.composer,
    this.period,
    this.format,
    this.conductor,
    this.status,
    this.onlyNeedsVerification = false,
    this.sort = AlbumSort.createdDesc,
  });

  static const empty = AlbumFilter();

  /// 필터 시트가 다루는 축의 활성 개수. 아이콘 뱃지용.
  /// 검색어(query)·정렬(sort)은 화면에 별도 UI가 있으므로 세지 않는다.
  int get activeCount => [
        status != null,
        format != null,
        composer != null,
        conductor != null,
        period != null,
        onlyNeedsVerification,
      ].where((on) => on).length;

  /// 시트의 "초기화" — 시트가 다루는 축만 해제하고 검색어·정렬은 보존한다.
  /// AlbumFilter.empty로 통째 되돌리면 검색창 TextEditingController의 글자는
  /// 남는데 필터만 풀려 화면과 상태가 어긋난다.
  AlbumFilter clearedForSheet() => AlbumFilter(query: query, sort: sort);

  bool get isEmpty =>
      (query == null || query!.isEmpty) &&
      composer == null &&
      period == null &&
      format == null &&
      conductor == null &&
      status == null &&
      !onlyNeedsVerification;

  AlbumFilter copyWith({
    String? query,
    bool clearQuery = false,
    String? composer,
    bool clearComposer = false,
    String? period,
    bool clearPeriod = false,
    String? format,
    bool clearFormat = false,
    String? conductor,
    bool clearConductor = false,
    HoldingStatus? status,
    bool clearStatus = false,
    bool? onlyNeedsVerification,
    AlbumSort? sort,
  }) =>
      AlbumFilter(
        query: clearQuery ? null : (query ?? this.query),
        composer: clearComposer ? null : (composer ?? this.composer),
        period: clearPeriod ? null : (period ?? this.period),
        format: clearFormat ? null : (format ?? this.format),
        conductor: clearConductor ? null : (conductor ?? this.conductor),
        status: clearStatus ? null : (status ?? this.status),
        onlyNeedsVerification:
            onlyNeedsVerification ?? this.onlyNeedsVerification,
        sort: sort ?? this.sort,
      );
}
