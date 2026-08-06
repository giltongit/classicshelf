import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../models/album.dart';
import '../models/album_filter.dart';
import '../models/album_summary.dart';
import '../models/wishlist_entry.dart';
import '../models/work.dart';
import '../repositories/collection_repository.dart';
import '../repositories/collection_repository_impl.dart';
import '../repositories/profile_repository.dart';
import '../repositories/profile_repository_impl.dart';
import '../services/auth_service.dart';
import '../services/discogs_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// 바코드 조회(§5). 상태를 갖지 않는 얇은 HTTP 래퍼라 앱 전역 하나로 충분하다.
/// 조회 결과를 여기(또는 어디에도) 캐시하지 않는다 — Discogs API Terms의
/// 6시간 캐시 제한 때문. 자세한 내용은 discogs_service.dart 상단 주석.
final discogsServiceProvider = Provider<DiscogsService>((ref) {
  final service = DiscogsService();
  ref.onDispose(service.dispose);
  return service;
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

// ── 필터 시트 선택지 ────────────────────────────────────────────────────────────
/// 작곡가·지휘자 distinct. autoDispose라 시트를 닫으면 버려지고 다음에 열 때
/// 다시 읽는다 — 그 사이 앨범이 추가돼도 선택지가 낡지 않는다.
final filterFacetsProvider = FutureProvider.autoDispose<FilterFacets>((ref) {
  return ref.watch(collectionRepositoryProvider).getFilterFacets();
});

// ── 참조 데이터(Works) 동기화 ───────────────────────────────────────────────────
/// 진행 상태를 화면(설정)이 구독한다. 앱 시작 자동 동기화와 수동 버튼이 같은
/// 노티파이어를 쓰므로 둘이 동시에 돌지 않는다(_running 가드).
///
/// 실패해도 앱은 그대로 쓸 수 있다 — 참조 데이터가 없으면 등록 폼이 자동완성 없이
/// 기존처럼 자유 텍스트로 동작할 뿐이다.
class WorksSyncNotifier extends AsyncNotifier<int> {
  bool _running = false;

  /// build는 로컬 보유 건수만 읽는다(네트워크 없음).
  @override
  Future<int> build() =>
      ref.watch(collectionRepositoryProvider).localWorksCount();

  /// 로컬이 비어 있을 때만 받는다. 앱 시작 경로용.
  Future<void> syncIfEmpty() async {
    final count = await ref.read(collectionRepositoryProvider).localWorksCount();
    if (count > 0) {
      debugPrint('[WORKS] 로컬 $count건 보유 — 앱 시작 동기화 생략');
      return;
    }
    await sync();
  }

  /// 강제 재동기화. 설정 화면의 "작품 데이터 새로고침".
  Future<void> sync() async {
    if (_running) {
      debugPrint('[WORKS] 이미 동기화 중 — 스킵');
      return;
    }
    _running = true;
    state = const AsyncValue.loading();
    try {
      final r = await ref.read(collectionRepositoryProvider).syncWorksFromRemote();
      state = AsyncValue.data(r.works);
    } catch (e, st) {
      debugPrint('[WORKS] 동기화 실패: $e');
      state = AsyncValue.error(e, st);
    } finally {
      _running = false;
    }
  }
}

final worksSyncProvider =
    AsyncNotifierProvider<WorksSyncNotifier, int>(WorksSyncNotifier.new);

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

// ── 매칭된 정규 작품 (상세 표시용) ──────────────────────────────────────────────
/// 앨범의 수록곡이 참조하는 Work를 id→Work로 모아 준다(§3-1a 정규명 표시).
/// 참조 데이터를 아직 안 받았으면 빈 map이고, 화면은 사용자가 적은 제목으로
/// 그대로 표시한다 — 조인이 없어도 상세가 깨지지 않는다.
final albumWorksProvider =
    FutureProvider.family<Map<String, Work>, String>((ref, albumId) async {
  final album = await ref.watch(albumDetailProvider(albumId).future);
  if (album == null) return const {};
  final ids = album.compositions
      .map((c) => c.workId)
      .whereType<String>()
      .toSet();
  if (ids.isEmpty) return const {};
  return ref.watch(collectionRepositoryProvider).getWorksByIds(ids);
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
