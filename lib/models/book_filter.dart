class BookFilter {
  final Set<String> statuses;
  final Set<String> attributes;
  final Set<String> media;
  final String? initial;
  final Set<String> locations;
  final String sortBy;

  const BookFilter({
    this.statuses = const {},
    this.attributes = const {},
    this.media = const {},
    this.initial,
    this.locations = const {},
    this.sortBy = 'createdAt',
  });

  static const _absent = Object();

  BookFilter copyWith({
    Set<String>? statuses,
    Set<String>? attributes,
    Set<String>? media,
    Object? initial = _absent,
    Set<String>? locations,
    String? sortBy,
  }) =>
      BookFilter(
        statuses: statuses ?? this.statuses,
        attributes: attributes ?? this.attributes,
        media: media ?? this.media,
        initial: identical(initial, _absent) ? this.initial : initial as String?,
        locations: locations ?? this.locations,
        sortBy: sortBy ?? this.sortBy,
      );

  bool get isEmpty =>
      statuses.isEmpty &&
      attributes.isEmpty &&
      media.isEmpty &&
      initial == null &&
      locations.isEmpty &&
      sortBy == 'createdAt';

  // 뱃지 카운트: 정렬 기준은 카운트 제외
  int get activeCount =>
      statuses.length +
      attributes.length +
      media.length +
      (initial != null ? 1 : 0) +
      locations.length;
}
