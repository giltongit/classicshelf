import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../services/cover_upload_service.dart';
import 'providers.dart';

/// 펜딩 업로드 항목. 오프라인 시 큐에 직렬화하여 저장.
class PendingUpload {
  final String filePath; // 리사이즈된 캐시 파일 경로
  final String userId;
  final String bookId;

  const PendingUpload({
    required this.filePath,
    required this.userId,
    required this.bookId,
  });

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'userId': userId,
        'bookId': bookId,
      };

  factory PendingUpload.fromJson(Map<String, dynamic> json) => PendingUpload(
        filePath: json['filePath'] as String,
        userId: json['userId'] as String,
        bookId: json['bookId'] as String,
      );
}

/// 표지 업로드 큐 관리자 (Riverpod AsyncNotifier).
///
/// state 타입: AsyncValue of List[PendingUpload] (현재 펜딩 큐)
/// - 온라인: 즉시 업로드 후 public URL 반환.
/// - 오프라인: 큐에 적재, documents에 JSON 영속화.
/// - 온라인 복귀: SyncQueueFlusher가 순서를 보장하며 구동.
///   1) flushSyncQueue() → 오프라인 책 insert + supabaseId 확보
///   2) promoteLocalCover() → supabaseId 경로로 표지 업로드
///   3) flush() → 그 외 나머지 펜딩 처리
class CoverUploadNotifier extends AsyncNotifier<List<PendingUpload>> {
  final _uploadService = CoverUploadService();

  @override
  Future<List<PendingUpload>> build() async {
    final queue = await _loadQueue();
    debugPrint('[COVER] CoverUploadNotifier 초기화 완료 (펜딩: ${queue.length}건)');
    return queue;
  }

  /// 업로드 시도. 성공 시 Storage public URL 반환, 실패 시 큐 적재 후 null 반환.
  Future<String?> enqueue({
    required File file,
    required String userId,
    required String bookId,
  }) async {
    try {
      return await _uploadService.upload(
        file: file,
        userId: userId,
        bookId: bookId,
      );
    } catch (e) {
      debugPrint('[COVER] 업로드 실패, 큐에 적재: $bookId — $e');
      final current = state.value ?? [];
      final updated = [
        ...current,
        PendingUpload(filePath: file.path, userId: userId, bookId: bookId),
      ];
      state = AsyncData(updated);
      await _saveQueue(updated);
      return null;
    }
  }

  /// 오프라인 추가 책의 표지 promote.
  /// SyncQueueFlusher가 _flushInsert 완료 후 supabaseId를 넘겨 호출한다.
  /// - localId 기반으로 펜딩 항목을 찾아 supabaseId 경로로 재업로드
  /// - 업로드 성공 후 updateCoverUrl(supabaseId) → Drift + Supabase 반영
  Future<void> promoteLocalCover({
    required int localId,
    required String supabaseId,
    required String userId,
  }) async {
    final current = state.value ?? [];
    final item = current
        .where((e) => e.bookId == localId.toString())
        .firstOrNull;
    if (item == null) {
      debugPrint('[COVER-FIX] promoteLocalCover — localId=$localId 해당 펜딩 없음, 스킵');
      return;
    }
    debugPrint('[COVER-FIX] promoteLocalCover 진입 — localId=$localId supabaseId=$supabaseId');

    final file = File(item.filePath);
    if (!file.existsSync()) {
      debugPrint('[COVER-FIX] promoteLocalCover 파일 없음, 큐 제거 — localId=$localId');
      final remaining = current.where((e) => e.bookId != localId.toString()).toList();
      state = AsyncData(remaining);
      await _saveQueue(remaining);
      return;
    }

    try {
      debugPrint('[COVER-FIX] Storage upload 직전 — supabaseId=$supabaseId');
      final url = await _uploadService.upload(
        file: file,
        userId: userId,
        bookId: supabaseId, // supabaseId 경로: covers/userId/supabaseId.jpg
      );
      debugPrint('[COVER-FIX] Storage upload 완료 — supabaseId=$supabaseId url=$url');
      await ref.read(bookRepositoryProvider).updateCoverUrl(supabaseId, url);
      final remaining = current.where((e) => e.bookId != localId.toString()).toList();
      state = AsyncData(remaining);
      await _saveQueue(remaining);
      debugPrint('[COVER-FIX] promoteLocalCover 완료 — supabaseId=$supabaseId');
    } catch (e) {
      debugPrint('[COVER-FIX] promoteLocalCover 실패 — localId=$localId: $e');
      // 큐 유지 → 다음 온라인 복귀 시 재시도
    }
  }

  /// 펜딩 큐 일괄 처리.
  Future<void> flush() async {
    final current = state.value ?? [];
    debugPrint('[COVER-FIX] flush 진입 — 펜딩 ${current.length}건: ${current.map((e) => e.bookId).toList()}');
    if (current.isEmpty) return;

    var remaining = List<PendingUpload>.from(current);

    for (final item in List<PendingUpload>.from(remaining)) {
      debugPrint('[COVER-FIX] 처리 시작 — bookId=${item.bookId} filePath=${item.filePath}');
      final file = File(item.filePath);
      if (!file.existsSync()) {
        debugPrint('[COVER-FIX] 파일 없음, 제거: ${item.filePath}');
        remaining.remove(item);
        continue;
      }
      try {
        debugPrint('[COVER-FIX] Storage upload 호출 직전 — bookId=${item.bookId}');
        final url = await _uploadService.upload(
          file: file,
          userId: item.userId,
          bookId: item.bookId,
        );
        debugPrint('[COVER-FIX] Storage upload 완료 — bookId=${item.bookId} url=$url');
        remaining.remove(item);
        debugPrint('[COVER-FIX] updateCoverUrl 호출 직전 — bookId=${item.bookId} url=$url');
        await ref.read(bookRepositoryProvider).updateCoverUrl(item.bookId, url);
        debugPrint('[COVER-FIX] updateCoverUrl 반환 — bookId=${item.bookId}');
      } catch (e) {
        debugPrint('[COVER-FIX] flush 항목 실패 — bookId=${item.bookId} error=$e');
        // 남겨두고 다음 온라인 복귀 시 재시도
      }
    }

    state = AsyncData(remaining);
    await _saveQueue(remaining);
    debugPrint('[COVER-FIX] flush 완료 — 남은 ${remaining.length}건');
  }

  // ── 큐 영속화 ──────────────────────────────────────────────────────────────

  Future<File> _queueFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/cover_upload_queue.json');
  }

  Future<void> _saveQueue(List<PendingUpload> queue) async {
    final f = await _queueFile();
    await f.writeAsString(jsonEncode(queue.map((e) => e.toJson()).toList()));
  }

  Future<List<PendingUpload>> _loadQueue() async {
    final f = await _queueFile();
    if (!f.existsSync()) return [];
    try {
      final raw = await f.readAsString();
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PendingUpload.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[COVER] 펜딩 큐 로드 실패 (파일 손상?): $e');
      return [];
    }
  }
}

final coverUploadProvider =
    AsyncNotifierProvider<CoverUploadNotifier, List<PendingUpload>>(
  CoverUploadNotifier.new,
);
