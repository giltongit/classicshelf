import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: 인증 로직은 추후 core/auth_service.dart (AuthService)로 분리 예정
const _supabaseUrl = 'https://uzqqmimqefzynbyrwnom.supabase.co';
const _supabasePublishableKey = 'sb_publishable_5gYpX3jpNjFcA8SZanzfCA_fs60Md7N';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );

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
          ],
        ),
      ),
    );
  }
}
