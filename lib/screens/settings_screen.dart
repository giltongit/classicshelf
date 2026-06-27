import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart' show BooksCompanion;

import '../features/home/home_background_notifier.dart';
import '../providers/providers.dart';
import '../services/csv_export_service.dart';
import '../theme/app_theme.dart';

final _csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return CsvExportService(ref.watch(bookRepositoryProvider));
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgState = switch (ref.watch(homeBackgroundProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final slotPaths =
        bgState?.slotPaths ?? const <String?>[null, null, null];
    final notifier = ref.read(homeBackgroundProvider.notifier);
    final authAsync = ref.watch(authNotifierProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _SectionHeader('계정'),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                authAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                        child: CircularProgressIndicator(color: AppColors.gold)),
                  ),
                  error: (_, _) => const Text(
                    '연결에 실패했습니다. 다시 시도해 주세요.',
                    style: TextStyle(color: AppColors.red),
                  ),
                  data: (isLinked) => isLinked
                      ? _AccountLinked(email: authService.linkedGoogleEmail)
                      : _AccountUnlinked(
                          onTap: () => ref
                              .read(authNotifierProvider.notifier)
                              .linkGoogle()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('로그아웃'),
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: const Text('로그아웃 완료',
                                style: TextStyle(color: AppColors.cream)),
                            content: const Text('앱을 다시 시작해 주세요.',
                                style: TextStyle(color: AppColors.muted)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('확인',
                                    style: TextStyle(color: AppColors.gold)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: BorderSide(
                          color: AppColors.red.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _SectionHeader('홈 배경 이미지'),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _BgSlot(
                          slot: 0, path: slotPaths[0], notifier: notifier),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BgSlot(
                          slot: 1, path: slotPaths[1], notifier: notifier),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BgSlot(
                          slot: 2, path: slotPaths[2], notifier: notifier),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '앱을 열 때마다 등록된 사진 중 하나가 배경으로 표시됩니다',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const _SectionHeader('데이터'),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'CSV로 내보내기',
            subtitle: '전체 도서 목록을 CSV 파일로 공유합니다',
            onTap: () => _exportCsv(context, ref),
          ),
          _SettingsTile(
            icon: Icons.upload_file_outlined,
            title: 'CSV 가져오기',
            subtitle: 'CSV 파일에서 도서 목록을 불러옵니다',
            onTap: () => context.push('/csv-import'),
          ),
          // TODO: 출시 전 제거 — 디버그용
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.bug_report, color: AppColors.muted),
              title: const Text('DB 상태 확인 (디버그)',
                  style: TextStyle(color: AppColors.cream)),
              onTap: () async {
                final db = ref.read(databaseProvider);
                final books = await db.select(db.books).get();
                final total = books.length;
                final hasSupa = books
                    .where((b) =>
                        b.supabaseId != null && b.supabaseId!.isNotEmpty)
                    .length;
                final nullSupa = total - hasSupa;
                final queueRows = await db.select(db.syncQueue).get();
                final queueTotal = queueRows.length;
                final insertCount = queueRows
                    .where((r) => r.operation == 'insert').length;
                final updateCount = queueRows
                    .where((r) => r.operation == 'update').length;
                final deleteCount = queueRows
                    .where((r) => r.operation == 'delete').length;
                final sample = books
                    .where((b) => b.supabaseId != null)
                    .take(5)
                    .map((b) {
                      final t = b.title;
                      final title = t.length > 10 ? t.substring(0, 10) : t;
                      return '$title... ${b.supabaseId!.substring(0, 8)}';
                    })
                    .join('\n');
                if (context.mounted) {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('로컬 DB 상태'),
                      content: Text(
                        '=== 로컬 DB ===\n'
                        '전체: $total권\n'
                        'supabaseId 있음: $hasSupa권\n'
                        'supabaseId null: $nullSupa권\n'
                        '\n=== sync_queue ===\n'
                        '전체: $queueTotal건\n'
                        'insert: $insertCount건\n'
                        'update: $updateCount건\n'
                        'delete: $deleteCount건\n'
                        '\n=== supabaseId 샘플 ===\n$sample',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('확인'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('supabaseId 초기화'),
                                content: const Text(
                                  '로컬 DB의 supabaseId를 전부 null로 초기화합니다.\n'
                                  '다음 앱 시작 시 Supabase에 재동기화됩니다.\n'
                                  '계속하시겠습니까?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('초기화',
                                        style:
                                            TextStyle(color: AppColors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true) return;

                            // 로딩 다이얼로그 먼저 표시
                            if (!context.mounted) return;
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const AlertDialog(
                                content: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 16),
                                    Text('초기화 중...'),
                                  ],
                                ),
                              ),
                            );

                            // 다음 프레임에서 실제 작업 실행 (UI가 먼저 그려지도록)
                            await Future.microtask(() async {
                              final db = ref.read(databaseProvider);
                              final books =
                                  await db.select(db.books).get();

                              for (final book in books) {
                                await (db.update(db.books)
                                      ..where((t) => t.id.equals(book.id)))
                                    .write(const BooksCompanion(
                                        supabaseId: Value(null)));
                              }

                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '초기화 완료 (${books.length}권). 앱을 재시작하세요.')),
                                );
                              }
                            });
                          },
                          child: const Text('supabaseId 초기화',
                              style: TextStyle(color: AppColors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    // 1. 권수 먼저 조회
    final books = await ref.read(bookRepositoryProvider).getBooks();
    if (!context.mounted) return;

    if (books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내보낼 책이 없습니다')),
      );
      return;
    }

    // 2. 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1915),
        title: const Text(
          'CSV로 내보내기',
          style: TextStyle(color: Color(0xFFF0E6D3)),
        ),
        content: Text(
          '${books.length}권을 내보냅니다. 계속할까요?\n\n'
          '파일은 휴대폰 다운로드 폴더에 저장됩니다.',
          style: const TextStyle(color: Color(0xFF7A7060)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소',
                style: TextStyle(color: Color(0xFF7A7060))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('내보내기',
                style: TextStyle(color: Color(0xFFC8A96E))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 3. 내보내기 실행
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await ref.read(_csvExportServiceProvider).export();
      if (!context.mounted) return;
      final fileName = result.path.split('/').last;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1915),
          title: const Text(
            '저장 완료',
            style: TextStyle(color: Color(0xFFF0E6D3)),
          ),
          content: Text(
            '${result.count}권을 다운로드 폴더에 저장했습니다.\n\n'
            '내 파일 앱 → 다운로드\n$fileName',
            style: const TextStyle(
              color: Color(0xFF7A7060),
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                '확인',
                style: TextStyle(color: Color(0xFFC8A96E)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('내보내기 실패: $e')),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gold),
      title: Text(title, style: const TextStyle(color: AppColors.cream)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.dim),
      onTap: onTap,
    );
  }
}

// ── 계정 섹션 위젯 ──────────────────────────────────────────────────────────────

class _AccountUnlinked extends StatelessWidget {
  final VoidCallback onTap;
  const _AccountUnlinked({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Google 계정',
          style: TextStyle(color: AppColors.cream),
        ),
        const SizedBox(height: 4),
        const Text(
          '계정을 연결하면 기기를 바꿔도\n나의 도서관이 그대로 유지됩니다.',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.account_circle_outlined),
            label: const Text('Google 계정 연결'),
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gold,
              side: const BorderSide(color: AppColors.gold),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountLinked extends StatelessWidget {
  final String? email;
  const _AccountLinked({required this.email});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded,
            color: AppColors.gold, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email ?? '',
                style: const TextStyle(color: AppColors.cream),
              ),
              const Text(
                '나의 도서관이 동기화되고 있습니다.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BgSlot extends StatelessWidget {
  final int slot;
  final String? path;
  final HomeBackgroundNotifier notifier;
  const _BgSlot(
      {required this.slot, required this.path, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: path != null ? _filled(path!) : _empty(),
    );
  }

  Widget _filled(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(imagePath), fit: BoxFit.cover),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xB3000000),
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => notifier.addOrReplace(slot),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.swap_horiz,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => notifier.remove(slot),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return GestureDetector(
      onTap: () => notifier.addOrReplace(slot),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.muted),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add, color: AppColors.muted, size: 28),
      ),
    );
  }
}
