import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cover_upload_provider.dart';
import 'providers.dart';

/// sync_queue flush 트리거:
///   1) 앱 시작 시 온라인이면 즉시 1회
///   2) 오프라인 → 온라인 복귀 감지 때마다
///   3) 앱 포그라운드 복귀 시 (triggerFlush 호출)
///
/// 클라이언트 UUID 전환으로 흐름이 단순해졌다: 예전엔 flush가 서버 uuid를 새로
/// 발급받아(_flushInsert) 그 id로 표지를 promote해야 했으나, 이제 id가 생성 시점에
/// 확정이라 promote 단계가 사라졌다. flush 후엔 펜딩 표지만 그대로 올리면 된다.
/// 목록도 albumSummariesProvider(reactive)라 flush 후 invalidate가 불필요하다.
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

      // uid 확보 직후 1회 — 원격 유실 행 복원 (fire-and-forget, 앱 기동 비차단).
      // 로컬 Drift는 그대로이므로(원격에만 재삽입) 목록 invalidate 불필요.
      ref
          .read(collectionRepositoryProvider)
          .reconcileLocalOnlyToRemote()
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

  /// sync_queue flush → 펜딩 표지 flush.
  /// DNS 실패로 아무것도 성공하지 못한 경우 3초 후 1회 자동 재시도.
  Future<void> _flushAll() async {
    if (_isFlushing) {
      debugPrint('[QUEUE] 이미 flush 중 — 스킵');
      return;
    }
    _isFlushing = true;
    try {
      // 1) 애그리게이트 insert/update/delete 반영
      final result = await ref.read(collectionRepositoryProvider).flushSyncQueue();

      // DNS 실패 감지: DNS 오류가 있고 성공이 0이면(네트워크 불안정 추정) 3초 후 1회 재시도.
      // (FlushResult.dnsFailures는 이제 그룹 단위 카운트라 totalItems 직접 비교 대신
      //  "성공 0" 조건으로 판정)
      if (result.dnsFailures > 0 && result.succeeded == 0) {
        debugPrint('[QUEUE] DNS 실패 감지 — 3초 후 재시도');
        await Future.delayed(const Duration(seconds: 3));
        final retry = await ref.read(collectionRepositoryProvider).flushSyncQueue();
        debugPrint(
          '[QUEUE] 재시도 결과: 성공 ${retry.succeeded}건 / 실패 ${retry.totalItems - retry.succeeded}건',
        );
      }

      // 2) 펜딩 표지 flush (promote 불필요 — 클라 UUID라 처음부터 최종 경로)
      await ref.read(coverUploadProvider.notifier).flush();
    } finally {
      _isFlushing = false;
    }
  }
}

final syncQueueFlusherProvider =
    AsyncNotifierProvider<SyncQueueFlusher, void>(SyncQueueFlusher.new);
