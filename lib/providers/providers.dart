import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../models/book.dart';
import '../models/book_filter.dart';
import '../repositories/book_repository.dart';
import '../repositories/book_repository_impl.dart';
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

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepositoryImpl(
    supabase: ref.watch(supabaseClientProvider),
    db: ref.watch(databaseProvider),
  );
});

/// 로컬 Drift에서 책 목록을 반환. invalidate() 로 갱신.
final booksProvider = FutureProvider<List<Book>>((ref) {
  return ref.watch(bookRepositoryProvider).getBooks();
});

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

// ── 책 필터/정렬 ───────────────────────────────────────────────────────────────

String? bookGroupKey(String title) {
  final trimmed = title.trimLeft();
  if (trimmed.isEmpty) return null;
  final code = trimmed.codeUnitAt(0);
  // 한글 음절: 쌍자음 통합 (ㄲ→ㄱ, ㄸ→ㄷ, ㅃ→ㅂ, ㅆ→ㅅ, ㅉ→ㅈ)
  if (code >= 0xAC00 && code <= 0xD7A3) {
    const map = [
      'ㄱ', 'ㄱ', 'ㄴ', 'ㄷ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅂ',
      'ㅅ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
    ];
    return map[(code - 0xAC00) ~/ 588];
  }
  if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
    return trimmed[0].toUpperCase();
  }
  if (code >= 48 && code <= 57) return trimmed[0];
  return null;
}

List<Book> applyBookFilterAndSort(List<Book> books, BookFilter filter) {
  var result = books;

  if (filter.searchQuery.isNotEmpty) {
    final q = filter.searchQuery.toLowerCase();
    result = result.where((b) =>
      b.title.toLowerCase().contains(q) ||
      b.author.toLowerCase().contains(q) ||
      (b.location?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  final filtered = result.where((b) {
    if (filter.statuses.isNotEmpty && !filter.statuses.contains(b.status)) {
      return false;
    }
    if (filter.attributes.isNotEmpty) {
      final match =
          (filter.attributes.contains('priority') && b.priorityRead) ||
          (filter.attributes.contains('read') && b.isRead) ||
          (filter.attributes.contains('unread') && !b.isRead);
      if (!match) return false;
    }
    if (filter.media.isNotEmpty && !filter.media.contains(b.medium)) {
      return false;
    }
    if (filter.initial != null && bookGroupKey(b.title) != filter.initial) {
      return false;
    }
    if (filter.locations.isNotEmpty &&
        !filter.locations.contains(b.location)) {
      return false;
    }
    return true;
  }).toList();

  switch (filter.sortBy) {
    case 'title':
      filtered.sort((a, b) => a.title.compareTo(b.title));
    case 'author':
      filtered.sort((a, b) => a.author.compareTo(b.author));
    case 'year':
      filtered.sort((a, b) {
        if (a.year == null) return 1;
        if (b.year == null) return -1;
        return b.year!.compareTo(a.year!);
      });
    case 'location':
      filtered.sort(
          (a, b) => (a.location ?? '').compareTo(b.location ?? ''));
    default: // createdAt 내림차순
      filtered.sort((a, b) {
        final ca = a.createdAt, cb = b.createdAt;
        if (ca == null && cb == null) return 0;
        if (ca == null) return 1;
        if (cb == null) return -1;
        return cb.compareTo(ca);
      });
  }
  return filtered;
}

class BookFilterNotifier extends Notifier<BookFilter> {
  @override
  BookFilter build() => const BookFilter();
  void update(BookFilter f) => state = f;
  void setSearchQuery(String q) =>
      state = state.copyWith(searchQuery: q);
}

final bookFilterProvider =
    NotifierProvider<BookFilterNotifier, BookFilter>(BookFilterNotifier.new);

/// booksProvider(전체) + bookFilterProvider(조건) → 필터·정렬 적용 결과.
/// booksAsync 상태(loading/error)는 그대로 전달되므로 .when() 패턴 유지 가능.
final filteredBooksProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final booksAsync = ref.watch(booksProvider);
  final filter = ref.watch(bookFilterProvider);
  return booksAsync.whenData((books) => applyBookFilterAndSort(books, filter));
});

// ── Google 계정 연결 ────────────────────────────────────────────────────────────

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
