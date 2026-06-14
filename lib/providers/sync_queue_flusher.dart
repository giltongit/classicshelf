import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cover_upload_provider.dart';
import 'providers.dart';

/// sync_queue flush 트리거:
///   1) 앱 시작 시 온라인이면 즉시 1회
///   2) 오프라인 → 온라인 복귀 감지 때마다
/// CoverUploadNotifier와 동일한 connectivity_plus 패턴.
class SyncQueueFlusher extends AsyncNotifier<void> {
  StreamSubscription<List<ConnectivityResult>>? _sub;

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

  /// sync_queue flush → 표지 promote → 나머지 표지 flush 순서를 보장하는 헬퍼.
  Future<void> _flushAll() async {
    // 1) 책 insert/update/delete → supabaseId 확보
    final inserted = await ref.read(bookRepositoryProvider).flushSyncQueue();
    ref.invalidate(booksProvider);

    // 2) 이번에 supabaseId를 새로 얻은 책의 표지를 올바른 경로로 promote
    for (final book in inserted) {
      await ref
          .read(coverUploadProvider.notifier)
          .promoteLocalCover(
            localId: book.localId,
            supabaseId: book.supabaseId,
            userId: book.userId,
          );
    }

    // 3) 그 외 펜딩 표지 (온라인 상태에서 업로드 실패한 것 등) flush
    await ref.read(coverUploadProvider.notifier).flush();
    ref.invalidate(booksProvider);
  }
}

final syncQueueFlusherProvider =
    AsyncNotifierProvider<SyncQueueFlusher, void>(SyncQueueFlusher.new);
