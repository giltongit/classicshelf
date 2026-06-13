import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'database/app_database.dart';
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
            const SizedBox(height: 16),
            // [임시 - DB 검증용] 5b 끝나면 제거 예정
            ElevatedButton(
              onPressed: () => _dbTest(ref),
              child: const Text('DB 테스트'),
            ),
          ],
        ),
      ),
    );
  }

  // [임시 - DB 검증용] insert 1건 → select 전체 → 개수 출력
  Future<void> _dbTest(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final bookId = 'test-${DateTime.now().millisecondsSinceEpoch}';
    await db.into(db.books).insert(
          BooksCompanion.insert(
            supabaseId: bookId,
            userId: 'test-user',
            title: 'Drift 테스트 책',
            author: '테스터',
          ),
        );
    final rows = await db.select(db.books).get();
    debugPrint('[DB Test] insert 완료 — books 총 ${rows.length}건');
    debugPrint('[DB Test] 최신 행: ${rows.last.title} / ${rows.last.supabaseId}');
  }
}
