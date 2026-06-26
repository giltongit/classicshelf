import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../models/book.dart';
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
