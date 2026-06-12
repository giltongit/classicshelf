class Book {
  final String id; // uuid — Storage 경로의 {book_id} 컴포넌트로도 사용
  final String userId;
  final String title;
  final String author;
  final String? isbn;

  /// 직접 촬영: Supabase Storage public URL (covers/{userId}/{bookId}.jpg)
  /// 외부 표지: 네이버/구글 북스 원본 URL — 변환 없이 그대로 사용
  final String? coverUrl;

  const Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
  });

  Book copyWith({
    String? id,
    String? userId,
    String? title,
    String? author,
    String? isbn,
    String? coverUrl,
  }) =>
      Book(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        author: author ?? this.author,
        isbn: isbn ?? this.isbn,
        coverUrl: coverUrl ?? this.coverUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'author': author,
        if (isbn != null) 'isbn': isbn,
        if (coverUrl != null) 'cover_url': coverUrl,
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        isbn: json['isbn'] as String?,
        coverUrl: json['cover_url'] as String?,
      );
}
