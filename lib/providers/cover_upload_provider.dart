import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../services/cover_upload_service.dart';

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
/// - 온라인 복귀: connectivity_plus 이벤트로 자동 flush.
class CoverUploadNotifier extends AsyncNotifier<List<PendingUpload>> {
  final _uploadService = CoverUploadService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  Future<List<PendingUpload>> build() async {
    ref.onDispose(() => _connectivitySub?.cancel());

    final queue = await _loadQueue();

    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (!results.contains(ConnectivityResult.none)) {
          debugPrint('[COVER] 온라인 복귀 — 펜딩 큐 flush 시작 (${state.value?.length ?? 0}건)');
          flush();
        }
      },
    );

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

  /// 펜딩 큐 일괄 처리.
  Future<void> flush() async {
    final current = state.value ?? [];
    if (current.isEmpty) return;

    var remaining = List<PendingUpload>.from(current);

    for (final item in List<PendingUpload>.from(remaining)) {
      final file = File(item.filePath);
      if (!file.existsSync()) {
        debugPrint('[COVER] 큐 항목 파일 없음, 제거: ${item.filePath}');
        remaining.remove(item);
        continue;
      }
      try {
        final url = await _uploadService.upload(
          file: file,
          userId: item.userId,
          bookId: item.bookId,
        );
        debugPrint('[COVER] 큐 flush 성공: ${item.bookId} → $url');
        remaining.remove(item);
        // TODO: books 테이블 cover_url 업데이트 (STEP 6 BookRepository에서 처리)
      } catch (e) {
        debugPrint('[COVER] 큐 flush 실패: ${item.bookId} — $e');
        // 남겨두고 다음 온라인 복귀 시 재시도
      }
    }

    state = AsyncData(remaining);
    await _saveQueue(remaining);
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
