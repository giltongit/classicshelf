// @collection 어노테이션과 isarId 필드는 준비 상태 (Isar codegen 가용 시 part 복원 예정)
import 'package:isar/isar.dart';

class Book {
  /// Isar 로컬 PK (int auto-increment). Supabase uuid와 별도.
  Id isarId = Isar.autoIncrement;

  /// Supabase uuid — Storage 경로의 {bookId} 컴포넌트로도 사용.
  String supabaseId;

  String userId;
  String title;
  String author;
  String? isbn;

  /// 직접 촬영: Supabase Storage public URL (covers/{userId}/{bookId}.jpg)
  /// 외부 표지: 네이버/구글 북스 원본 URL — 변환 없이 그대로 사용
  String? coverUrl;

  Book({
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
      )..isarId = isarId;

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
