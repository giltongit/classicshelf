import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value, DoUpdate, OrderingTerm;
import 'package:flutter/foundation.dart';
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

  // ── 공개 인터페이스 ────��───────────────────────────────────────────────────

  @override
  Future<List<Book>> getBooks() async {
    final rows = await _db.select(_db.books).get();
    return rows.map(_fromData).toList();
  }

  @override
  Future<Book> addBook(Book book) async {
    debugPrint('[ADD] ▶ addBook 시작: title="${book.title}"');
    // Drift INSERT 먼저 — 오프라인에서도 목록에 즉시 반영
    final localId = await _db.into(_db.books).insert(_toCompanion(book));
    final localBook = book.copyWith(localId: localId);
    debugPrint('[ADD] Drift INSERT 완료: localId=$localId');

    final isOnline = await _isOnline();
    debugPrint('[ADD] 판정: online=$isOnline');

    if (isOnline) {
      final payload = book.toSupabaseInsert();
      debugPrint('[ADD] Supabase INSERT 시도 payload keys=${payload.keys.toList()}');
      try {
        final row = await _supabase
            .from('books')
            .insert(payload)
            .select()
            .single();
        final supabaseId = row['id'] as String;
        debugPrint('[ADD] Supabase INSERT 성공: supabaseId=$supabaseId');
        // Drift 행에 서버 uuid 반영
        await (_db.update(_db.books)..where((t) => t.id.equals(localId)))
            .write(BooksCompanion(supabaseId: Value(supabaseId)));
        debugPrint('[ADD] Drift supabaseId 반영 완료');
        final result = Book.fromJson(row).copyWith(localId: localId);
        debugPrint('[ADD] ◀ 반환: localId=${result.localId} supabaseId=${result.supabaseId}');
        return result;
      } catch (e, st) {
        debugPrint('[ADD] Supabase INSERT 예외: $e');
        debugPrint('[ADD] StackTrace: $st');
        await _enqueue(localId, 'insert', localBook);
        debugPrint('[ADD] ◀ 반환(큐): localId=$localId supabaseId=null');
        return localBook;
      }
    } else {
      debugPrint('[ADD] 오프라인 → 큐 적재');
      await _enqueue(localId, 'insert', localBook);
      debugPrint('[ADD] ◀ 반환(큐): localId=$localId supabaseId=null');
      return localBook;
    }
  }

  @override
  Future<Book> updateBook(Book book) async {
    debugPrint('[UPD] ▶ updateBook 시작: localId=${book.localId} supabaseId=${book.supabaseId} coverUrl=${book.coverUrl}');
    // 클라이언트 동일성 확인 — 다르면 stale 레퍼런스 문제
    debugPrint('[UPD] 클라이언트: _supabase=${_supabase.hashCode} instance=${Supabase.instance.client.hashCode} identical=${identical(_supabase, Supabase.instance.client)}');
    // Drift UPDATE 먼저 — 낙관적
    try {
      await (_db.update(_db.books)..where((t) => t.id.equals(book.localId!)))
          .write(_toCompanion(book));
      debugPrint('[UPD] Drift UPDATE 완료');
    } catch (driftErr, driftSt) {
      debugPrint('[UPD] Drift UPDATE 예외: $driftErr\n$driftSt');
      rethrow;
    }

    if (book.supabaseId == null) {
      // 순수 로컬 전용 — Drift만
      debugPrint('[UPD] ◀ 반환(supabaseId 없음 → Drift만)');
      return book;
    }

    final isOnline = await _isOnline();
    debugPrint('[UPD] 판정: online=$isOnline');

    if (isOnline) {
      final payload = book.toSupabaseUpdate();
      debugPrint('[UPD] Supabase UPDATE 시도: supabaseId=${book.supabaseId} payload keys=${payload.keys.toList()}');
      // stale _supabase 우회 — Supabase.instance.client 직접 사용
      final client = Supabase.instance.client;
      try {
        final row = await client
            .from('books')
            .update(payload)
            .eq('id', book.supabaseId!)
            .select()
            .single();
        debugPrint('[UPD] Supabase UPDATE 성공 row.id=${row['id']}');
        final updated = Book.fromJson(row).copyWith(localId: book.localId);
        // Drift에 서버 응답 반영 (updated_at 등)
        await (_db.update(_db.books)..where((t) => t.id.equals(book.localId!)))
            .write(_toCompanion(updated));
        debugPrint('[UPD] ◀ 반환: supabaseId=${updated.supabaseId}');
        return updated;
      } on PostgrestException catch (e) {
        debugPrint('[UPD] PostgrestException: code=${e.code} msg="${e.message}" details=${e.details} hint=${e.hint}');
        await _enqueue(book.localId!, 'update', book);
        debugPrint('[UPD] ◀ 반환(큐/PG): localId=${book.localId}');
        return book;
      } catch (e, st) {
        debugPrint('[UPD] Supabase UPDATE 예외(${e.runtimeType}): $e');
        debugPrint('[UPD] StackTrace: $st');
        await _enqueue(book.localId!, 'update', book);
        debugPrint('[UPD] ◀ 반환(큐): localId=${book.localId}');
        return book;
      }
    } else {
      debugPrint('[UPD] 오프라인 → 큐 적재');
      await _enqueue(book.localId!, 'update', book);
      debugPrint('[UPD] ◀ 반환(큐): localId=${book.localId}');
      return book;
    }
  }

  @override
  Future<void> deleteBook(Book book) async {
    // Drift DELETE 먼저 — 낙관적
    await (_db.delete(_db.books)..where((t) => t.id.equals(book.localId!))).go();

    // supabaseId 없는 순수 로컬 → 큐 적재 불필요
    if (book.supabaseId == null) return;

    if (await _isOnline()) {
      try {
        await Supabase.instance.client.from('books').delete().eq('id', book.supabaseId!);
        final storagePath = _coverStoragePath(book.coverUrl);
        if (storagePath != null) {
          try {
            await Supabase.instance.client.storage.from('covers').remove([storagePath]);
            debugPrint('[DELETE] Storage 표지 삭제: $storagePath');
          } catch (e) {
            debugPrint('[DELETE] Storage 표지 삭제 실패(무시): $e');
          }
        }
      } catch (e) {
        debugPrint('[QUEUE] deleteBook Supabase 실패: $e');
        await _enqueue(book.localId!, 'delete', book);
      }
    } else {
      await _enqueue(book.localId!, 'delete', book);
    }
  }

  @override
  Future<void> syncFromRemote() async {
    final rows = await Supabase.instance.client.from('books').select();
    for (final row in rows) {
      final book = Book.fromJson(row);
      await _db.into(_db.books).insert(
            _toCompanion(book),
            onConflict: DoUpdate(
              (_) => _toCompanion(book),
              target: [_db.books.supabaseId],
            ),
          );
    }
  }

  @override
  Future<void> updateCoverUrl(String bookId, String storageUrl) async {
    debugPrint('[COVER-FIX] updateCoverUrl 진입 — bookId=$bookId storageUrl=$storageUrl');

    // bookId 는 supabaseId(UUID) 또는 localId 문자열
    final localIdInt = int.tryParse(bookId);
    debugPrint('[COVER-FIX] 탐색 방법 — ${localIdInt != null ? "localId=$localIdInt" : "supabaseId=$bookId"}');

    final bookData = localIdInt != null
        ? await (_db.select(_db.books)
              ..where((t) => t.id.equals(localIdInt)))
            .getSingleOrNull()
        : await (_db.select(_db.books)
              ..where((t) => t.supabaseId.equals(bookId)))
            .getSingleOrNull();

    debugPrint('[COVER-FIX] Drift 탐색 결과 — ${bookData == null ? "행 없음" : "localId=${bookData.id} supabaseId=${bookData.supabaseId} 현재coverUrl=${bookData.coverUrl}"}');

    if (bookData == null) {
      debugPrint('[COVER-FIX] 로컬 행 없음 → 스킵');
      return;
    }

    // 멱등: 이미 원격 URL이 설정돼 있으면 재처리하지 않음
    if (bookData.coverUrl != null && bookData.coverUrl!.startsWith('http')) {
      debugPrint('[COVER-FIX] 이미 원격 URL → 스킵 (coverUrl=${bookData.coverUrl})');
      return;
    }

    debugPrint('[COVER-FIX] updateBook 호출 직전 — localId=${bookData.id} supabaseId=${bookData.supabaseId} 새coverUrl=$storageUrl');
    // updateBook과 동일한 낙관적 쓰기 경로 — Drift 선반영 후 온라인이면 Supabase PATCH,
    // 오프라인이면 sync_queue 'update' 적재.
    final book = _fromData(bookData).copyWith(coverUrl: storageUrl);
    await updateBook(book);
    debugPrint('[COVER-FIX] updateBook 반환 완료 — bookId=$bookId');
  }

  @override
  Future<int> pendingQueueCount() async {
    final rows = await _db.select(_db.syncQueue).get();
    return rows.length;
  }

  @override
  Future<void> togglePriorityRead(int localId) async {
    final row = await (_db.select(_db.books)
          ..where((t) => t.id.equals(localId)))
        .getSingleOrNull();
    if (row == null) return;
    await (_db.update(_db.books)..where((t) => t.id.equals(localId)))
        .write(BooksCompanion(priorityRead: Value(!row.priorityRead)));
  }

  @override
  Future<void> reconcileLocalOnlyToRemote() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      debugPrint('[RECONCILE] uid 없음 — 미로그인, 중단');
      return;
    }

    // 원격 id 집합 (현재 user의 행만)
    final remoteRows = await Supabase.instance.client
        .from('books')
        .select('id')
        .eq('user_id', uid) as List<dynamic>;
    final remoteIds = remoteRows.map((r) => r['id'] as String).toSet();
    debugPrint('[RECONCILE] 원격 ${remoteIds.length}건 확인');

    // 로컬 전체
    final localRows = await _db.select(_db.books).get();

    // supabaseId 있음 + 원격 미존재인 행만
    final orphans = localRows.where((r) =>
        r.supabaseId != null &&
        r.supabaseId!.isNotEmpty &&
        !remoteIds.contains(r.supabaseId!));

    int restored = 0;
    for (final row in orphans) {
      final book = _fromData(row);
      // 기존 insert 페이로드에 uuid를 명시 — 서버가 새 uuid를 생성하지 않도록
      final payload = {
        'id': book.supabaseId!,
        ...book.toSupabaseInsert(),
        'user_id': uid, // stale userId 보정
      };
      try {
        await Supabase.instance.client.from('books').insert(payload);
        debugPrint('[RECONCILE] 복원 성공: supabaseId=${book.supabaseId} title="${book.title}"');
        restored++;
      } on PostgrestException catch (e) {
        // 23505 = unique_violation: 동시에 다른 기기가 이미 복원한 경우 — 무해
        if (e.code == '23505') {
          debugPrint('[RECONCILE] 이미 존재(skip): supabaseId=${book.supabaseId} code=${e.code}');
        } else {
          debugPrint('[RECONCILE] 실패: supabaseId=${book.supabaseId} code=${e.code} msg="${e.message}"');
        }
      } catch (e) {
        debugPrint('[RECONCILE] 실패(unknown): supabaseId=${book.supabaseId} $e');
      }
    }
    debugPrint('[RECONCILE] 완료 — 복원 $restored건 / 대상 ${orphans.length}건');
  }

  // ── sync_queue flush ───────────────────────────────────────────────────────

  @override
  Future<FlushSyncResult> flushSyncQueue() async {
    final rows = await (_db.select(_db.syncQueue)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    if (rows.isEmpty) {
      debugPrint('[QUEUE] flush 시작: 0건 (비어 있음)');
      return (inserted: const <BookInsertResult>[], totalItems: 0, dnsFailures: 0, succeeded: 0);
    }
    debugPrint('[QUEUE] flush 시작: ${rows.length}건');
    final inserted = <BookInsertResult>[];
    int dnsFailures = 0;
    for (final item in rows) {
      try {
        switch (item.operation) {
          case 'insert':
            final result = await _flushInsert(item);
            if (result != null) inserted.add(result);
          case 'update':
            await _flushUpdate(item);
          case 'delete':
            await _flushDelete(item);
          default:
            debugPrint('[QUEUE] 처리: id=${item.id} op=${item.operation} → 알 수 없는 op, 삭제');
            await _deleteQueueItem(item.id);
        }
      } catch (e) {
        debugPrint('[QUEUE] 처리: id=${item.id} op=${item.operation} → 오류(보존): $e');
        if (_isDnsError(e)) dnsFailures++;
      }
    }
    final remaining = await pendingQueueCount();
    final succeeded = rows.length - remaining;
    debugPrint('[QUEUE] flush 완료: 남은 $remaining건, 신규 insert ${inserted.length}건');
    return (
      inserted: inserted,
      totalItems: rows.length,
      dnsFailures: dnsFailures,
      succeeded: succeeded,
    );
  }

  static bool _isDnsError(Object e) {
    final s = e.toString();
    return s.contains('Failed host lookup') ||
        s.contains('No address associated with hostname');
  }

  /// insert 성공 시 BookInsertResult 반환, 스킵/실패 시 null.
  Future<BookInsertResult?> _flushInsert(SyncQueueData item) async {
    final bookData = await (_db.select(_db.books)
          ..where((t) => t.id.equals(item.localBookId)))
        .getSingleOrNull();
    if (bookData == null) {
      debugPrint('[QUEUE] 처리: id=${item.id} op=insert localBookId=${item.localBookId} → 책 없음, 삭제');
      await _deleteQueueItem(item.id);
      return null;
    }
    if (bookData.supabaseId != null && bookData.supabaseId!.isNotEmpty) {
      debugPrint('[QUEUE] 처리: id=${item.id} op=insert localBookId=${item.localBookId} → 이미 supabaseId=${bookData.supabaseId}, 삭제');
      await _deleteQueueItem(item.id);
      return null;
    }
    final book = _fromData(bookData);
    final resolvedUserId = book.userId.isNotEmpty
        ? book.userId
        : (Supabase.instance.client.auth.currentUser?.id ?? '');
    if (resolvedUserId.isEmpty) {
      debugPrint('[QUEUE] 처리: id=${item.id} op=insert localBookId=${item.localBookId} → userId 없음(미로그인?), 보존');
      return null;
    }
    final bookToInsert = resolvedUserId != book.userId
        ? book.copyWith(userId: resolvedUserId)
        : book;
    if (resolvedUserId != book.userId) {
      await (_db.update(_db.books)..where((t) => t.id.equals(item.localBookId)))
          .write(BooksCompanion(userId: Value(resolvedUserId)));
    }
    final row = await Supabase.instance.client
        .from('books')
        .insert(bookToInsert.toSupabaseInsert())
        .select()
        .single();
    final supabaseId = row['id'] as String;
    await (_db.update(_db.books)..where((t) => t.id.equals(item.localBookId)))
        .write(BooksCompanion(supabaseId: Value(supabaseId)));
    await _deleteQueueItem(item.id);
    debugPrint('[QUEUE] 처리: id=${item.id} op=insert localBookId=${item.localBookId} → 성공 supabaseId=$supabaseId');
    return (localId: item.localBookId, supabaseId: supabaseId, userId: resolvedUserId);
  }

  Future<void> _flushUpdate(SyncQueueData item) async {
    final bookData = await (_db.select(_db.books)
          ..where((t) => t.id.equals(item.localBookId)))
        .getSingleOrNull();
    if (bookData == null) {
      debugPrint('[QUEUE] 처리: id=${item.id} op=update localBookId=${item.localBookId} → 책 없음, 삭제');
      await _deleteQueueItem(item.id);
      return;
    }
    if (bookData.supabaseId == null || bookData.supabaseId!.isEmpty) {
      // 서버에 없는 책(null 또는 ""): 대응 op=insert가 큐에 있을 것이므로 skip
      debugPrint('[QUEUE] 처리: id=${item.id} op=update localBookId=${item.localBookId} → supabaseId 없음, skip 삭제');
      await _deleteQueueItem(item.id);
      return;
    }
    final book = _fromData(bookData);
    // .select() 없이 PATCH — 서버 행 있으면 갱신, 없으면 0 rows(무해)
    await Supabase.instance.client
        .from('books')
        .update(book.toSupabaseUpdate())
        .eq('id', bookData.supabaseId!);
    await _deleteQueueItem(item.id);
    debugPrint('[QUEUE] 처리: id=${item.id} op=update localBookId=${item.localBookId} → 성공/대상없음 supabaseId=${bookData.supabaseId}');
  }

  Future<void> _flushDelete(SyncQueueData item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    final supabaseId = payload['supabase_id'] as String?;
    if (supabaseId == null) {
      debugPrint('[QUEUE] 처리: id=${item.id} op=delete → supabaseId 없음, 삭제');
      await _deleteQueueItem(item.id);
      return;
    }
    await Supabase.instance.client.from('books').delete().eq('id', supabaseId);
    final storagePath = _coverStoragePath(payload['cover_url'] as String?);
    if (storagePath != null) {
      try {
        await Supabase.instance.client.storage.from('covers').remove([storagePath]);
        debugPrint('[DELETE] Storage 표지 삭제(큐): $storagePath');
      } catch (e) {
        debugPrint('[DELETE] Storage 표지 삭제 실패(큐, 무시): $e');
      }
    }
    await _deleteQueueItem(item.id);
    debugPrint('[QUEUE] 처리: id=${item.id} op=delete → 성공 supabaseId=$supabaseId');
  }

  Future<void> _deleteQueueItem(int id) async {
    await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(id))).go();
  }

  // ── 내부 헬퍼 ─────────────────────────────────────────────────────────────

  /// cover_url → Storage 경로 파싱.
  /// `.../object/public/covers/{userId}/{id}.{ext}` → `{userId}/{id}.{ext}`
  /// 외부 URL / null / 패턴 불일치 → null (remove 건너뜀)
  String? _coverStoragePath(String? coverUrl) {
    if (coverUrl == null) return null;
    const marker = '/object/public/covers/';
    final idx = coverUrl.indexOf(marker);
    if (idx == -1) return null;
    return coverUrl.substring(idx + marker.length);
  }

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    debugPrint('[NET] connectivity raw=$results');
    return !results.contains(ConnectivityResult.none);
  }

  Future<void> _enqueue(int localBookId, String operation, Book book) async {
    await _db.into(_db.syncQueue).insert(
          SyncQueueCompanion.insert(
            localBookId: localBookId,
            operation: operation,
            payload: _bookToPayload(operation, book),
          ),
        );
    final count = await pendingQueueCount();
    debugPrint('[QUEUE] 적재: op=$operation, 큐 $count건');
  }

  String _bookToPayload(String operation, Book book) {
    if (operation == 'delete') {
      return jsonEncode({
        'local_book_id': book.localId,
        'supabase_id': book.supabaseId,
        if (book.coverUrl != null) 'cover_url': book.coverUrl,
      });
    }
    return jsonEncode({
      'local_book_id': book.localId,
      if (book.supabaseId != null) 'supabase_id': book.supabaseId,
      'user_id': book.userId,
      'title': book.title,
      'author': book.author,
      if (book.isbn != null) 'isbn': book.isbn,
      if (book.coverUrl != null) 'cover_url': book.coverUrl,
      if (book.description != null) 'description': book.description,
      'status': book.status,
      if (book.review != null) 'review': book.review,
      if (book.pageCount != null) 'page_count': book.pageCount,
      if (book.year != null) 'year': book.year,
      if (book.genre != null) 'genre': book.genre,
      if (book.publisher != null) 'publisher': book.publisher,
      if (book.location != null) 'location': book.location,
      'priority_read': book.priorityRead,
      'is_read': book.isRead,
      'medium': book.medium,
      if (book.language != null) 'language': book.language,
      if (book.callNumber != null) 'call_number': book.callNumber,
      if (book.kdc != null) 'kdc': book.kdc,
      if (book.ddc != null) 'ddc': book.ddc,
      if (book.lc  != null) 'lc':  book.lc,
      if (book.acquiredAt != null)
        'acquired_at': '${book.acquiredAt!.year}-${book.acquiredAt!.month.toString().padLeft(2, '0')}-${book.acquiredAt!.day.toString().padLeft(2, '0')}',
    });
  }

  // ── Drift ↔ 도메인 변환 ────��──────────────────────────────────────────────

  Book _fromData(BookData d) => Book(
        localId: d.id,
        // 빈 문자열("")은 null과 동일 취급 — uuid 컬럼에 "" 전달 방지
        supabaseId: (d.supabaseId?.isEmpty == true) ? null : d.supabaseId,
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
        isRead: d.isRead,
        medium: d.medium,
        language: d.language,
        callNumber: d.callNumber,
        kdc: d.kdc,
        ddc: d.ddc,
        lc:  d.lc,
        acquiredAt: d.acquiredAt,
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
      );

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
        isRead: Value(b.isRead),
        medium: Value(b.medium),
        language: Value(b.language),
        callNumber: Value(b.callNumber),
        kdc: Value(b.kdc),
        ddc: Value(b.ddc),
        lc:  Value(b.lc),
        acquiredAt: Value(b.acquiredAt),
        createdAt:
            b.createdAt != null ? Value(b.createdAt!) : const Value.absent(),
        updatedAt:
            b.updatedAt != null ? Value(b.updatedAt!) : const Value.absent(),
      );
}
