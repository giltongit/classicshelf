import '../models/book.dart';

/// 화면은 이 인터페이스만 알며 Drift / Supabase 존재를 모른다.
abstract interface class BookRepository {
  /// 로컬 Drift에서 책 목록 반환.
  Future<List<Book>> getBooks();

  /// Supabase INSERT → Drift 미러 → 생성된 Book 반환.
  Future<Book> addBook(Book book);

  /// Supabase UPDATE → Drift 미러 → 갱신된 Book 반환.
  Future<Book> updateBook(Book book);

  /// Supabase DELETE → Drift DELETE (supabaseId 기준).
  Future<void> deleteBook(String supabaseId);

  /// Supabase 전체 조회 → Drift upsert 미러링 (supabaseId 기준).
  Future<void> syncFromRemote();
}
