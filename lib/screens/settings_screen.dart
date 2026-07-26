import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/home_background_notifier.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

// TODO: 클래식 재작성 (2B)
//   book 시절 CSV 내보내기 서비스 프로바이더가 여기 있었다.
//   csv_export_service.dart 는 2A에서 삭제됨 — 앨범 기준으로 재작성 필요.

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
    final libraryName = switch (ref.watch(libraryNameProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _SectionHeader('도서관 이름'),
          _SettingsTile(
            icon: Icons.local_library_outlined,
            title: libraryName ?? '나의 도서관',
            subtitle: libraryName == null
                ? '홈 화면 상단에 표시할 도서관 이름을 설정합니다'
                : '탭하여 도서관 이름을 변경합니다',
            onTap: () => _editLibraryName(context, ref, libraryName),
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
          // TODO: 클래식 재작성 (2B)
          //   '데이터 관리' 섹션 전체를 비활성화했다. 원래 항목:
          //     - CSV로 내보내기  (csv_export_service, bookRepositoryProvider)
          //     - CSV 가져오기    (/csv-import 라우트, csv_import_screen)
          //     - KDC 자동 채우기 (LibrarySearchService.getClassNo + updateBook)
          //   앨범/작품 기준 내보내기·가져오기로 재설계 후 복원할 것.
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editLibraryName(
      BuildContext context, WidgetRef ref, String? current) async {
    final controller = TextEditingController(text: current ?? '');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        // 가로 모드에서 키보드가 올라오면 세로 여백이 모자라 넘친다.
        scrollable: true,
        title: const Text('도서관 이름'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(
            hintText: '나의 도서관',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              Navigator.pop(ctx);
              ref
                  .read(libraryNameProvider.notifier)
                  .setLibraryName(name.isEmpty ? null : name);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // TODO: 클래식 재작성 (2B)
  //   _exportCsv() / _backfillKdc() 를 제거했다.
  //   _exportCsv  : bookRepositoryProvider.getBooks() + CsvExportService.export()
  //   _backfillKdc: booksProvider + LibrarySearchService.getClassNo + updateBook(kdc)
  //   둘 다 book 전용 프로바이더·서비스에 의존해 컴파일 불가였다.
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
