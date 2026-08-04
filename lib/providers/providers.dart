import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../models/album.dart';
import '../models/album_filter.dart';
import '../models/album_summary.dart';
import '../models/wishlist_entry.dart';
import '../repositories/collection_repository.dart';
import '../repositories/collection_repository_impl.dart';
import '../repositories/profile_repository.dart';
import '../repositories/profile_repository_impl.dart';
import '../services/auth_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openDatabaseConnection());
  ref.onDispose(db.close);
  return db;
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepositoryImpl(
    supabase: ref.watch(supabaseClientProvider),
    db: ref.watch(databaseProvider),
  );
});

// ── 앨범 필터 상태 ─────────────────────────────────────────────────────────────
// book의 BookFilterNotifier 대체. 메모리 필터(applyBookFilterAndSort)는 제거 —
// 필터·정렬은 이제 리포지토리 쿼리(getAlbumSummaries)가 담당한다.

class AlbumFilterNotifier extends Notifier<AlbumFilter> {
  @override
  AlbumFilter build() => AlbumFilter.empty;

  void update(AlbumFilter f) => state = f;

  void setQuery(String? q) => state = (q == null || q.trim().isEmpty)
      ? state.copyWith(clearQuery: true)
      : state.copyWith(query: q);

  void setStatus(HoldingStatus? s) => state = s == null
      ? state.copyWith(clearStatus: true)
      : state.copyWith(status: s);

  void setComposer(String? c) => state = (c == null || c.isEmpty)
      ? state.copyWith(clearComposer: true)
      : state.copyWith(composer: c);

  void setFormat(String? f) => state = (f == null || f.isEmpty)
      ? state.copyWith(clearFormat: true)
      : state.copyWith(format: f);

  void setSort(AlbumSort sort) => state = state.copyWith(sort: sort);

  void setOnlyNeedsVerification(bool v) =>
      state = state.copyWith(onlyNeedsVerification: v);

  void reset() => state = AlbumFilter.empty;
}

final albumFilterProvider =
    NotifierProvider<AlbumFilterNotifier, AlbumFilter>(AlbumFilterNotifier.new);

// ── 앨범 목록 (reactive) ────────────────────────────────────────────────────────
/// 필터를 watch → watchAlbumSummaries(Drift `.watch()`)에 주입.
/// book의 booksProvider(FutureProvider + 수동 invalidate) 패턴을 대체 —
/// 쓰기 시 Drift 변경 스트림이 자동 방출하므로 화면의 invalidate 호출이 사라진다.
final albumSummariesProvider = StreamProvider<List<AlbumSummary>>((ref) {
  final filter = ref.watch(albumFilterProvider);
  return ref.watch(collectionRepositoryProvider).watchAlbumSummaries(filter);
});

/// 홈·전체집계용 — albumFilterProvider를 watch하지 않는다.
/// 위 albumSummariesProvider를 홈에서 쓰면 서가 탭에서 건 필터가 홈 집계까지
/// 좁혀버린다(전체 N장이 필터 결과 수로 표시됨). 목록과 집계는 구독을 분리한다.
final allAlbumSummariesProvider = StreamProvider<List<AlbumSummary>>((ref) {
  return ref
      .watch(collectionRepositoryProvider)
      .watchAlbumSummaries(AlbumFilter.empty);
});

// ── 앨범 단건 (상세) ────────────────────────────────────────────────────────────
/// 상세 화면 — 앨범 애그리게이트 단건.
/// write가 albums를 touch하면 목록(watch)은 자동 갱신되나, 상세는 진입 시
/// 조회로 충분하다. 편집 후 갱신이 필요하면 화면에서
/// ref.invalidate(albumDetailProvider(id)).
final albumDetailProvider =
    FutureProvider.family<Album?, String>((ref, albumId) {
  return ref.watch(collectionRepositoryProvider).getAlbum(albumId);
});

// ── 희망 목록 (reactive) ────────────────────────────────────────────────────────
/// wishlist는 Album과 별개 독립 애그리게이트(§3-2)라 앨범 필터를 타지 않는다.
/// albumSummariesProvider와 동일하게 Drift watch 기반 — 추가/삭제 후 invalidate 불필요.
final wishlistProvider = StreamProvider<List<WishItem>>((ref) {
  return ref.watch(collectionRepositoryProvider).watchWishlist();
});

// ── profile (book 무관 — 유지) ──────────────────────────────────────────────────

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// tracking_started_at을 Supabase profiles 테이블에서 읽고 캐시.
/// setDate() 호출 시 Supabase에 upsert + 상태 갱신.
class TrackingStartedNotifier extends AsyncNotifier<DateTime?> {
  @override
  Future<DateTime?> build() {
    return ref.watch(profileRepositoryProvider).getTrackingStartedAt();
  }

  Future<void> startToday() async {
    final today = DateTime.now();
    await ref.read(profileRepositoryProvider).setTrackingStartedAt(today);
    state = AsyncData(today);
  }
}

final trackingStartedProvider =
    AsyncNotifierProvider<TrackingStartedNotifier, DateTime?>(
  TrackingStartedNotifier.new,
);

class LibraryNameNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() {
    return ref.watch(profileRepositoryProvider).getLibraryName();
  }

  Future<void> setLibraryName(String? name) async {
    final trimmed = name?.trim();
    final value = (trimmed?.isEmpty ?? true) ? null : trimmed;
    await ref.read(profileRepositoryProvider).setLibraryName(value);
    state = AsyncData(value);
  }
}

final libraryNameProvider =
    AsyncNotifierProvider<LibraryNameNotifier, String?>(
  LibraryNameNotifier.new,
);

// ── Google 계정 연결 (book 무관 — 유지) ──────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<bool> {
  StreamSubscription<AuthState>? _sub;

  @override
  Future<bool> build() async {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final linked = data.session?.user.identities
              ?.any((i) => i.provider == 'google') ??
          false;
      debugPrint('[AUTH] 상태 변경: ${data.event} / linked=$linked');
      state = AsyncValue.data(linked);
    });

    ref.onDispose(() => _sub?.cancel());

    return ref.read(authServiceProvider).isGoogleLinked;
  }

  Future<void> linkGoogle() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).linkGoogle();
      // state는 onAuthStateChange에서 자동 갱신.
      // linkIdentity는 브라우저를 열고 즉시 반환하므로
      // 실제 완료는 deep link 수신 후 onAuthStateChange 이벤트로 처리됨.
    } catch (e, st) {
      debugPrint('[AUTH] linkGoogle 실패: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);
