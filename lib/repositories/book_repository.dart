import '../models/book.dart';

/// _flushInsert가 성공적으로 Supabase에 insert하고 supabaseId를 확보한 책 정보.
/// SyncQueueFlusher → CoverUploadNotifier 간 표지 promote 연결에 사용한다.
typedef BookInsertResult = ({int localId, String supabaseId, String userId});

/// flushSyncQueue 반환값: 신규 insert 목록 + DNS 실패 통계.
typedef FlushSyncResult = ({
  List<BookInsertResult> inserted,
  int totalItems,
  int dnsFailures,
  int succeeded,
});

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
  /// 반환값: FlushSyncResult (삽입된 책 목록 + DNS 실패 통계).
  Future<FlushSyncResult> flushSyncQueue();

  /// Storage 업로드 완료 후 cover_url을 Drift + Supabase 양쪽에 반영.
  /// [bookId]는 supabaseId(UUID) 또는 localId 문자열(오프라인 추가 직후).
  /// 내부적으로 updateBook과 동일한 낙관적 쓰기 + sync_queue 패턴을 사용한다.
  Future<void> updateCoverUrl(String bookId, String storageUrl);

  Future<int> pendingQueueCount();

  /// Drift만 업데이트 — Supabase/sync_queue 없음.
  Future<void> togglePriorityRead(int localId);

  /// 로컬에 supabaseId가 있으나 원격에 없는 행을 동일 uuid로 재삽입.
  /// 원격에 이미 있는 행은 건드리지 않는다(보수적).
  Future<void> reconcileLocalOnlyToRemote();
}
