import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';
import '../repositories/book_repository_impl.dart';
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
