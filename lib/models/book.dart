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

  /// 'owned' | 'wishlist'
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

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
    DateTime? createdAt,
    DateTime? updatedAt,
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
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
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
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
      );

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}
