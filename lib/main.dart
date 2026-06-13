import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/book.dart';
import 'providers/cover_upload_provider.dart';
import 'providers/providers.dart';
import 'services/auth_service.dart';

// 실행 시 --dart-define-from-file=env/dev.json 필수
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );

  // ProviderScope 외부이므로 AuthService를 직접 인스턴스화
  await AuthService(Supabase.instance.client).ensureSignedIn();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Library',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

/// 앱 진입점 화면. 실제 UI는 STEP 6+ 에서 구성.
class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 앱 시작 시 표지 업로드 큐 / connectivity 리스너 초기화 (pre-warm)
    ref.watch(coverUploadProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Library'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('준비 중'),
            const SizedBox(height: 20),
            // [임시 - Repository 검증용] STEP 6 화면 붙이면 제거 예정
            ElevatedButton(
              onPressed: () => _addBookTest(ref),
              child: const Text('책 추가 테스트'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _syncTest(ref),
              child: const Text('동기화 테스트'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _listTest(ref),
              child: const Text('목록 조회'),
            ),
          ],
        ),
      ),
    );
  }

  // [임시 - Repository 검증용] STEP 6 화면 붙이면 제거 예정
  Future<void> _addBookTest(WidgetRef ref) async {
    final repo = ref.read(bookRepositoryProvider);
    final userId =
        ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';
    final dummy = Book(
      supabaseId: '', // addBook 내부에서 무시됨, Supabase가 uuid 생성
      userId: userId,
      title: '테스트 책 ${DateTime.now().millisecondsSinceEpoch}',
      author: '테스터',
    );
    try {
      final added = await repo.addBook(dummy);
      debugPrint('[Book Test] addBook 완료: ${added.supabaseId} / ${added.title}');
    } catch (e) {
      debugPrint('[Book Test] addBook 실패: $e');
    }
  }

  Future<void> _syncTest(WidgetRef ref) async {
    final repo = ref.read(bookRepositoryProvider);
    try {
      await repo.syncFromRemote();
      final books = await repo.getBooks();
      debugPrint('[Book Test] syncFromRemote 완료 — Drift books: ${books.length}건');
    } catch (e) {
      debugPrint('[Book Test] syncFromRemote 실패: $e');
    }
  }

  Future<void> _listTest(WidgetRef ref) async {
    final repo = ref.read(bookRepositoryProvider);
    try {
      final books = await repo.getBooks();
      debugPrint('[Book Test] getBooks: 총 ${books.length}건');
      for (final b in books) {
        debugPrint('[Book Test]   - ${b.title} (${b.supabaseId})');
      }
    } catch (e) {
      debugPrint('[Book Test] getBooks 실패: $e');
    }
  }
}
