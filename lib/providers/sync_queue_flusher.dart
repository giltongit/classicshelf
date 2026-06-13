import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        await ref.read(bookRepositoryProvider).flushSyncQueue();
        ref.invalidate(booksProvider);
      } catch (e) {
        debugPrint('[QUEUE] 앱 시작 flush 오류: $e');
      }
    }

    // 온라인 복귀 감지 → flush
    _sub = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (!results.contains(ConnectivityResult.none)) {
          debugPrint('[QUEUE] 온라인 복귀 — sync_queue flush 실행');
          ref
              .read(bookRepositoryProvider)
              .flushSyncQueue()
              .then((_) => ref.invalidate(booksProvider))
              .catchError((Object e) {
            debugPrint('[QUEUE] flush 오류(onConnectivity): $e');
          });
        }
      },
    );
  }
}

final syncQueueFlusherProvider =
    AsyncNotifierProvider<SyncQueueFlusher, void>(SyncQueueFlusher.new);
