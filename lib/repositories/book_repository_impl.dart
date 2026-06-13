import 'package:drift/drift.dart' show Value, DoUpdate;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../models/book.dart';
import 'book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final SupabaseClient _supabase;
  final AppDatabase _db;

  BookRepositoryImpl({
    required this._supabase,
    required this._db,
  });

  // ── 공개 인터페이스 ────────────────────────────────────────────────────────

  @override
  Future<List<Book>> getBooks() async {
    final rows = await _db.select(_db.books).get();
    return rows.map(_fromData).toList();
  }

  @override
  Future<Book> addBook(Book book) async {
    // ① Supabase INSERT (id는 서버 생성, toSupabaseInsert는 id 제외)
    final row = await _supabase
        .from('books')
        .insert(book.toSupabaseInsert())
        .select()
        .single();
    final created = Book.fromJson(row);

    // ② Drift 미러
    await _db.into(_db.books).insert(_toCompanion(created));

    return created;
  }

  @override
  Future<Book> updateBook(Book book) async {
    // ① Supabase UPDATE
    final row = await _supabase
        .from('books')
        .update(book.toSupabaseUpdate())
        .eq('id', book.supabaseId)
        .select()
        .single();
    final updated = Book.fromJson(row);

    // ② Drift 미러 (supabaseId 기준 row 업데이트)
    await (_db.update(_db.books)
          ..where((t) => t.supabaseId.equals(updated.supabaseId)))
        .write(_toCompanion(updated));

    return updated;
  }

  @override
  Future<void> deleteBook(String supabaseId) async {
    // ① Supabase DELETE
    await _supabase.from('books').delete().eq('id', supabaseId);

    // ② Drift DELETE
    await (_db.delete(_db.books)
          ..where((t) => t.supabaseId.equals(supabaseId)))
        .go();
  }

  @override
  Future<void> syncFromRemote() async {
    // Supabase 전체 조회 (RLS가 본인 데이터만 반환)
    final rows = await _supabase.from('books').select();

    for (final row in rows) {
      final book = Book.fromJson(row);
      // supabaseId unique 제약 기준 upsert
      await _db.into(_db.books).insert(
            _toCompanion(book),
            onConflict: DoUpdate(
              (_) => _toCompanion(book),
              target: [_db.books.supabaseId],
            ),
          );
    }
  }

  // ── 변환 함수 (Drift ↔ 도메인) ─────────────────────────────────────────────

  /// BookData(Drift 행) → Book 도메인
  Book _fromData(BookData d) => Book(
        supabaseId: d.supabaseId,
        userId: d.userId,
        title: d.title,
        author: d.author,
        isbn: d.isbn,
        coverUrl: d.coverUrl,
        description: d.description,
        status: d.status,
        review: d.review,
        pageCount: d.pageCount,
        year: d.year,
        genre: d.genre,
        publisher: d.publisher,
        location: d.location,
        priorityRead: d.priorityRead,
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
      );

  /// Book 도메인 → BooksCompanion (Drift 삽입/수정용)
  BooksCompanion _toCompanion(Book b) => BooksCompanion(
        supabaseId: Value(b.supabaseId),
        userId: Value(b.userId),
        title: Value(b.title),
        author: Value(b.author),
        isbn: Value(b.isbn),
        coverUrl: Value(b.coverUrl),
        description: Value(b.description),
        status: Value(b.status),
        review: Value(b.review),
        pageCount: Value(b.pageCount),
        year: Value(b.year),
        genre: Value(b.genre),
        publisher: Value(b.publisher),
        location: Value(b.location),
        priorityRead: Value(b.priorityRead),
        createdAt: b.createdAt != null
            ? Value(b.createdAt!)
            : const Value.absent(),
        updatedAt: b.updatedAt != null
            ? Value(b.updatedAt!)
            : const Value.absent(),
      );
}
