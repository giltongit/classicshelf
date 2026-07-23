class Book {
  /// Drift auto-increment PK. Drift에서 읽어올 때 채워짐; 아직 미저장이면 null.
  final int? localId;

  /// Supabase uuid — Storage 경로 {bookId} 컴포넌트로도 사용.
  /// Supabase에 아직 동기화되지 않은 로컬 전용 책은 null.
  final String? supabaseId;
  final String userId;
  final String title;
  final String author;
  final String? isbn;

  /// 직접 촬영: Storage public URL / 외부: 네이버·구글 북스 원본 URL
  final String? coverUrl;
  final String? description;

  /// 'owned' | 'wishlist' | 'rental'
  final String status;
  final String? review;
  final int? pageCount;
  final String? year;
  final String? genre;
  final String? publisher;
  final String? location;
  final bool priorityRead;
  final bool isRead;
  final String medium;
  final String? language;
  final String? callNumber;
  final String? kdc;
  final String? ddc;
  final String? lc;
  final DateTime? acquiredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// 처분(판매/기부/분실 등) 시점. null이면 아직 소장 중.
  /// status는 그대로 'owned'를 유지하고 이 필드만 orthogonal하게 처분 여부를 나타낸다
  /// (결정: disposed 상태 A안 — 공통_아키텍처.md §25).
  final DateTime? disposedAt;

  /// 실제로 지금 서가에 있는 소장본인가 — status만으로는 판단 불가(처분된 책도
  /// status는 'owned'로 남아있음). 소장 여부를 판정하는 모든 코드는 이 getter를
  /// 사용해야 한다 (직접 `status == 'owned'`만 체크하면 처분된 책이 다시 보이는
  /// 회귀가 생길 수 있음).
  bool get isActiveOwned => status == 'owned' && disposedAt == null;

  /// 처분된 책인가.
  bool get isDisposed => disposedAt != null;

  const Book({
    this.localId,
    this.supabaseId,
    required this.userId,
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
    this.description,
    this.status = 'owned',
    this.review,
    this.pageCount,
    this.year,
    this.genre,
    this.publisher,
    this.location,
    this.priorityRead = false,
    this.isRead = false,
    this.medium = 'paper',
    this.language,
    this.callNumber,
    this.kdc,
    this.ddc,
    this.lc,
    this.acquiredAt,
    this.createdAt,
    this.updatedAt,
    this.disposedAt,
  });

  // acquiredAt/disposedAt은 null로 명시 설정(날짜 지우기)이 필요하므로 sentinel 패턴 사용.
  static const _absent = Object();

  Book copyWith({
    int? localId,
    String? supabaseId,
    String? userId,
    String? title,
    String? author,
    String? isbn,
    String? coverUrl,
    String? description,
    String? status,
    String? review,
    int? pageCount,
    String? year,
    String? genre,
    String? publisher,
    String? location,
    bool? priorityRead,
    bool? isRead,
    String? medium,
    String? language,
    String? callNumber,
    String? kdc,
    String? ddc,
    String? lc,
    Object? acquiredAt = _absent,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? disposedAt = _absent,
  }) =>
      Book(
        localId: localId ?? this.localId,
        supabaseId: supabaseId ?? this.supabaseId,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        author: author ?? this.author,
        isbn: isbn ?? this.isbn,
        coverUrl: coverUrl ?? this.coverUrl,
        description: description ?? this.description,
        status: status ?? this.status,
        review: review ?? this.review,
        pageCount: pageCount ?? this.pageCount,
        year: year ?? this.year,
        genre: genre ?? this.genre,
        publisher: publisher ?? this.publisher,
        location: location ?? this.location,
        priorityRead: priorityRead ?? this.priorityRead,
        isRead: isRead ?? this.isRead,
        medium: medium ?? this.medium,
        language: language ?? this.language,
        callNumber: callNumber ?? this.callNumber,
        kdc: kdc ?? this.kdc,
        ddc: ddc ?? this.ddc,
        lc: lc ?? this.lc,
        acquiredAt: acquiredAt == _absent ? this.acquiredAt : acquiredAt as DateTime?,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        disposedAt: disposedAt == _absent ? this.disposedAt : disposedAt as DateTime?,
      );

  // ── Supabase 직렬화 ──────────────────────────────────────────────────────

  /// Supabase INSERT 페이로드. id는 서버가 생성하므로 제외.
  Map<String, dynamic> toSupabaseInsert() => {
        'user_id': userId,
        'title': title,
        'author': author,
        if (isbn != null) 'isbn': isbn,
        if (coverUrl != null) 'cover_url': coverUrl,
        if (description != null) 'description': description,
        'status': status,
        if (review != null) 'review': review,
        if (pageCount != null) 'page_count': pageCount,
        if (year != null) 'year': year,
        if (genre != null) 'genre': genre,
        if (publisher != null) 'publisher': publisher,
        if (location != null) 'location': location,
        'priority_read': priorityRead,
        'is_read': isRead,
        'medium': medium,
        if (language != null) 'language': language,
        if (callNumber != null) 'call_number': callNumber,
        if (kdc != null) 'kdc': kdc,
        if (ddc != null) 'ddc': ddc,
        if (lc  != null) 'lc':  lc,
        if (acquiredAt != null) 'acquired_at': _formatDate(acquiredAt!),
        if (disposedAt != null) 'disposed_at': disposedAt!.toUtc().toIso8601String(),
      };

  /// Supabase UPDATE 페이로드. updated_at을 수동 갱신(트리거 없음).
  Map<String, dynamic> toSupabaseUpdate() => {
        'title': title,
        'author': author,
        'isbn': isbn,
        'cover_url': coverUrl,
        'description': description,
        'status': status,
        'review': review,
        'page_count': pageCount,
        'year': year,
        'genre': genre,
        'publisher': publisher,
        'location': location,
        'priority_read': priorityRead,
        'is_read': isRead,
        'medium': medium,
        'language': language,
        'call_number': callNumber,
        'kdc': kdc,
        'ddc': ddc,
        'lc':  lc,
        'acquired_at': acquiredAt != null ? _formatDate(acquiredAt!) : null,
        'disposed_at': disposedAt?.toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

  /// Supabase 응답 row(snake_case) → Book 도메인.
  /// localId는 Supabase가 모르므로 채우지 않는다 (호출 측에서 copyWith로 추가).
  factory Book.fromJson(Map<String, dynamic> json) => Book(
        supabaseId: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        isbn: json['isbn'] as String?,
        coverUrl: json['cover_url'] as String?,
        description: json['description'] as String?,
        status: (json['status'] as String?) ?? 'owned',
        review: json['review'] as String?,
        pageCount: json['page_count'] as int?,
        year: json['year'] as String?,
        genre: json['genre'] as String?,
        publisher: json['publisher'] as String?,
        location: json['location'] as String?,
        priorityRead: (json['priority_read'] as bool?) ?? false,
        isRead: (json['is_read'] as bool?) ?? false,
        medium: (json['medium'] as String?) ?? 'paper',
        language: json['language'] as String?,
        callNumber: json['call_number'] as String?,
        kdc: json['kdc'] as String?,
        ddc: json['ddc'] as String?,
        lc:  json['lc']  as String?,
        acquiredAt: _parseDateTime(json['acquired_at']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
        disposedAt: _parseDateTime(json['disposed_at']),
      );

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
