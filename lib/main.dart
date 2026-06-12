import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/cover_upload_provider.dart';
import 'services/cover_photo_service.dart';

// 실행 시 --dart-define-from-file=env/dev.json 필수
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment('SUPABASE_ANON_KEY');

// TODO: 추후 Riverpod Provider로 이전 예정
final coverUploadProvider = CoverUploadProvider();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );

  // TODO: 인증 로직은 추후 core/auth_service.dart (AuthService)로 분리 예정
  final supabase = Supabase.instance.client;

  if (supabase.auth.currentSession == null) {
    try {
      await supabase.auth.signInAnonymously();
      debugPrint('[Auth] 익명 로그인 성공: ${supabase.auth.currentUser?.id}');
    } catch (e) {
      // 네트워크 오프라인 등 실패 시에도 앱 정상 부팅 (local-first 원칙)
      debugPrint('[Auth] 익명 로그인 실패 (오프라인?): $e');
    }
  } else {
    debugPrint('[Auth] 기존 세션 유지: ${supabase.auth.currentUser?.id}');
  }

  await coverUploadProvider.init();

  runApp(const MyApp());
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
      home: const MyHomePage(title: 'My Library'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _coverPhotoService = CoverPhotoService();

  // [임시 - RLS 검증용] 검증 완료 후 이 메서드와 버튼 삭제
  Future<void> _rlsTest() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('[RLS Test] 로그인된 사용자 없음');
      return;
    }

    try {
      await supabase.from('books').insert({
        'user_id': userId,
        'title': 'RLS 테스트 책',
        'author': 'test',
      });

      final rows = await supabase
          .from('books')
          .select()
          .eq('user_id', userId);

      debugPrint('[RLS Test] books 행 수: ${rows.length}');
    } catch (e) {
      debugPrint('[RLS Test] 오류: $e');
    }
  }

  // [임시 - RLS 디버깅용] 검증 완료 후 삭제
  Future<void> _sessionDiag() async {
    try {
      final res = await Supabase.instance.client.rpc('debug_auth');
      debugPrint('[DEBUG] auth: $res');
    } catch (e) {
      debugPrint('[DEBUG] debug_auth 오류: $e');
    }
  }

  // [임시 - ③ 검증용] 정식 책 추가 화면 붙이면 삭제 예정
  Future<void> _coverUploadTest() async {
    debugPrint('[COVER Test] ── 진입 ──');
    try {
      // userId 확인
      final userId = Supabase.instance.client.auth.currentUser?.id;
      debugPrint('[COVER Test] userId: $userId');
      if (userId == null) {
        debugPrint('[COVER Test] 로그인된 사용자 없음 — 종료');
        return;
      }

      // 1. 갤러리 픽업
      debugPrint('[COVER Test] 1) picker 호출');
      final raw = await _coverPhotoService.pickFromGallery();
      debugPrint('[COVER Test] 1) picker 반환: ${raw?.path ?? 'null (취소)'}');
      if (raw == null) return;

      // 2. 리사이즈 & 캐시
      final bookId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('[COVER Test] 2) resizeAndCache 진입 — bookId: $bookId');
      final resized = await _coverPhotoService.resizeAndCache(raw, bookId);
      debugPrint('[COVER Test] 2) resizeAndCache 완료: ${resized.path}');

      // 3. enqueue
      debugPrint('[COVER Test] 3) enqueue 진입');
      final url = await coverUploadProvider.enqueue(
        file: resized,
        userId: userId,
        bookId: bookId,
      );

      // 4 & 5. 결과
      if (url != null) {
        debugPrint('[COVER Test] 4) 업로드 성공: $url');
      } else {
        debugPrint('[COVER Test] 4) 업로드 펜딩 — 온라인 복귀 시 자동 재시도');
      }
    } catch (e, st) {
      debugPrint('[COVER Test] !! 예외 발생: $e');
      debugPrint('[COVER Test] !! 스택트레이스: $st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // [임시 - RLS 검증용] 검증 완료 후 삭제
            ElevatedButton(
              onPressed: _rlsTest,
              child: const Text('RLS 테스트'),
            ),
            const SizedBox(height: 12),
            // [임시 - RLS 디버깅용] 검증 완료 후 삭제
            ElevatedButton(
              onPressed: _sessionDiag,
              child: const Text('세션 진단'),
            ),
            const SizedBox(height: 12),
            // [임시 - ③ 검증용] 정식 책 추가 화면 붙이면 삭제 예정
            ElevatedButton(
              onPressed: _coverUploadTest,
              child: const Text('표지 업로드 테스트'),
            ),
          ],
        ),
      ),
    );
  }
}
