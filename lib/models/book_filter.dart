class BookFilter {
  final Set<String> statuses;
  final Set<String> attributes;
  final Set<String> media;
  final String? initial;
  final Set<String> locations;
  final String sortBy;
  final String searchQuery;

  /// 처분된 책도 목록에 포함할지. 기본 false — 처분된 책은 서가·검색·통계에서
  /// 기본적으로 숨겨지고, 이 필터를 켰을 때만 노출된다 (결정: disposed 상태 §25).
  final bool showDisposed;

  const BookFilter({
    this.statuses = const {},
    this.attributes = const {},
    this.media = const {},
    this.initial,
    this.locations = const {},
    this.sortBy = 'createdAt',
    this.searchQuery = '',
    this.showDisposed = false,
  });

  static const _absent = Object();

  BookFilter copyWith({
    Set<String>? statuses,
    Set<String>? attributes,
    Set<String>? media,
    Object? initial = _absent,
    Set<String>? locations,
    String? sortBy,
    String? searchQuery,
    bool? showDisposed,
  }) =>
      BookFilter(
        statuses: statuses ?? this.statuses,
        attributes: attributes ?? this.attributes,
        media: media ?? this.media,
        initial: identical(initial, _absent) ? this.initial : initial as String?,
        locations: locations ?? this.locations,
        sortBy: sortBy ?? this.sortBy,
        searchQuery: searchQuery ?? this.searchQuery,
        showDisposed: showDisposed ?? this.showDisposed,
      );

  bool get isEmpty =>
      statuses.isEmpty &&
      attributes.isEmpty &&
      media.isEmpty &&
      initial == null &&
      locations.isEmpty &&
      sortBy == 'createdAt' &&
      searchQuery.isEmpty &&
      !showDisposed;

  // 뱃지 카운트: 정렬 기준·검색어는 카운트 제외
  int get activeCount =>
      statuses.length +
      attributes.length +
      media.length +
      (initial != null ? 1 : 0) +
      locations.length +
      (showDisposed ? 1 : 0);
}
