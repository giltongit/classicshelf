import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/book_repository.dart';
import 'cover_upload_provider.dart';
import 'providers.dart';

/// sync_queue flush 트리거:
///   1) 앱 시작 시 온라인이면 즉시 1회
///   2) 오프라인 → 온라인 복귀 감지 때마다
///   3) 앱 포그라운드 복귀 시 (triggerFlush 호출)
/// CoverUploadNotifier와 동일한 connectivity_plus 패턴.
class SyncQueueFlusher extends AsyncNotifier<void> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isFlushing = false;

  @override
  Future<void> build() async {
    ref.onDispose(() => _sub?.cancel());

    // 앱 시작 시 온라인이면 즉시 flush
    final initResults = await Connectivity().checkConnectivity();
    if (!initResults.contains(ConnectivityResult.none)) {
      debugPrint('[QUEUE] 앱 시작 — 온라인, sync_queue flush 실행');
      try {
        await _flushAll();
      } catch (e) {
        debugPrint('[QUEUE] 앱 시작 flush 오류: $e');
      }

      // uid 확보 직후 1회 — 원격 유실 행 복원 (fire-and-forget, 앱 기동 비차단)
      ref
          .read(bookRepositoryProvider)
          .reconcileLocalOnlyToRemote()
          .then((_) => ref.invalidate(booksProvider))
          .catchError((Object e) {
        debugPrint('[RECONCILE] 앱 시작 복원 오류: $e');
      });
    }

    // 온라인 복귀 감지 → flush
    _sub = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (!results.contains(ConnectivityResult.none)) {
          debugPrint('[QUEUE] 온라인 복귀 — sync_queue flush 실행');
          _flushAll().catchError((Object e) {
            debugPrint('[QUEUE] flush 오류(onConnectivity): $e');
          });
        }
      },
    );
  }

  /// 앱 포그라운드 복귀 등 외부에서 flush를 트리거할 때 호출.
  void triggerFlush() {
    _flushAll().catchError((Object e) {
      debugPrint('[QUEUE] flush 오류(triggerFlush): $e');
    });
  }

  /// sync_queue flush → 표지 promote → 나머지 표지 flush 순서를 보장하는 헬퍼.
  /// DNS 실패로 전체 항목이 실패한 경우 3초 후 1회 자동 재시도.
  Future<void> _flushAll() async {
    if (_isFlushing) {
      debugPrint('[QUEUE] 이미 flush 중 — 스킵');
      return;
    }
    _isFlushing = true;
    try {
      // 1) 책 insert/update/delete → supabaseId 확보
      final result = await ref.read(bookRepositoryProvider).flushSyncQueue();
      ref.invalidate(booksProvider);

      // DNS 실패 감지: 전체 항목이 DNS 오류로 실패한 경우 3초 후 1회 재시도
      if (result.dnsFailures > 0 && result.dnsFailures == result.totalItems) {
        debugPrint('[QUEUE] DNS 실패 감지 — 3초 후 재시도');
        await Future.delayed(const Duration(seconds: 3));
        final retryResult = await ref.read(bookRepositoryProvider).flushSyncQueue();
        ref.invalidate(booksProvider);
        debugPrint(
          '[QUEUE] 재시도 결과: 성공 ${retryResult.succeeded}건 / 실패 ${retryResult.totalItems - retryResult.succeeded}건',
        );
        await _promoteAndFlushCovers(retryResult.inserted);
        return;
      }

      // 2) 표지 promote + 펜딩 표지 flush
      await _promoteAndFlushCovers(result.inserted);
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _promoteAndFlushCovers(List<BookInsertResult> inserted) async {
    // 이번에 supabaseId를 새로 얻은 책의 표지를 올바른 경로로 promote
    for (final book in inserted) {
      await ref
          .read(coverUploadProvider.notifier)
          .promoteLocalCover(
            localId: book.localId,
            supabaseId: book.supabaseId,
            userId: book.userId,
          );
    }
    // 그 외 펜딩 표지 (온라인 상태에서 업로드 실패한 것 등) flush
    await ref.read(coverUploadProvider.notifier).flush();
    ref.invalidate(booksProvider);
  }
}

final syncQueueFlusherProvider =
    AsyncNotifierProvider<SyncQueueFlusher, void>(SyncQueueFlusher.new);
