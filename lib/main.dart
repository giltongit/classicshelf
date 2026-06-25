import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/cover_upload_provider.dart';
import 'providers/sync_queue_flusher.dart';
import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

// 실행 시 --dart-define-from-file=env/dev.json 필수
const _supabaseUrl            = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );

  await AuthService(Supabase.instance.client).ensureSignedIn();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[QUEUE] 앱 포그라운드 복귀 — sync_queue flush 트리거');
      ref.read(syncQueueFlusherProvider.notifier).triggerFlush();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 앱 시작 시 업로드 큐 / sync_queue / connectivity 리스너 초기화 (pre-warm)
    ref.watch(coverUploadProvider);
    ref.watch(syncQueueFlusherProvider);

    return MaterialApp.router(
      title: 'My Library',
      theme: AppTheme.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
