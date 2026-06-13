/// 도메인 모델. 로컬 DB의 int PK(Drift)와 Supabase uuid(supabaseId)를 분리한다.
/// Drift 테이블의 int id는 database 계층에서만 관리하며 이 모델에 노출하지 않는다.
class Book {
  /// Supabase uuid — Storage 경로의 {bookId} 컴포넌트로도 사용.
  final String supabaseId;

  final String userId;
  final String title;
  final String author;
  final String? isbn;

  /// 직접 촬영: Supabase Storage public URL (covers/{userId}/{bookId}.jpg)
  /// 외부 표지: 네이버/구글 북스 원본 URL — 변환 없이 그대로 사용
  final String? coverUrl;

  const Book({
    required this.supabaseId,
    required this.userId,
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
  });

  Book copyWith({
    String? supabaseId,
    String? userId,
    String? title,
    String? author,
    String? isbn,
    String? coverUrl,
  }) =>
      Book(
        supabaseId: supabaseId ?? this.supabaseId,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        author: author ?? this.author,
        isbn: isbn ?? this.isbn,
        coverUrl: coverUrl ?? this.coverUrl,
      );

  // Supabase 직렬화: 'id' 컬럼 ↔ supabaseId
  Map<String, dynamic> toJson() => {
        'id': supabaseId,
        'user_id': userId,
        'title': title,
        'author': author,
        if (isbn != null) 'isbn': isbn,
        if (coverUrl != null) 'cover_url': coverUrl,
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        supabaseId: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        isbn: json['isbn'] as String?,
        coverUrl: json['cover_url'] as String?,
      );
}
