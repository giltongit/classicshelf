import '../models/book.dart';

/// 화면은 이 인터페이스만 알며 Drift / Supabase 존재를 모른다.
abstract interface class BookRepository {
  /// 로컬 Drift에서 책 목록 반환.
  Future<List<Book>> getBooks();

  /// Drift INSERT 먼저(낙관적) → 온라인이면 Supabase INSERT + supabaseId 반영.
  /// 오프라인/실패면 sync_queue에 'insert' 적재 후 로컬 Book 반환.
  Future<Book> addBook(Book book);

  /// Drift UPDATE 먼저(낙관적) → 온라인이면 Supabase UPDATE.
  /// 오프라인/실패 + supabaseId 있으면 sync_queue에 'update' 적재.
  Future<Book> updateBook(Book book);

  /// Drift DELETE 먼저(낙관적) → supabaseId 있고 온라인이면 Supabase DELETE.
  /// 오프라인/실패면 sync_queue에 'delete' 적재.
  Future<void> deleteBook(Book book);

  /// Supabase 전체 조회 → Drift upsert 미러링 (supabaseId 기준).
  Future<void> syncFromRemote();

  /// sync_queue를 createdAt 오름차순으로 Supabase에 반영하고 성공 항목 삭제.
  /// 앱 시작 시 온라인이면 1회 + 온라인 복귀 때마다 SyncQueueFlusher가 호출.
  Future<void> flushSyncQueue();

  // TODO: 검증용 임시 — 5c-2 검증 후 제거.
  Future<int> pendingQueueCount();
  Future<void> debugDumpQueue();
  Future<void> clearSyncQueue();

  /// 로컬에 supabaseId가 있으나 원격에 없는 행을 동일 uuid로 재삽입.
  /// 원격에 이미 있는 행은 건드리지 않는다(보수적).
  Future<void> reconcileLocalOnlyToRemote();
}
