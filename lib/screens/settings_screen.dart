import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:charset_converter/charset_converter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../features/home/home_background_notifier.dart';
import '../models/album.dart';
import '../models/album_filter.dart';
import '../providers/providers.dart';
import '../services/csv_service.dart';
import '../theme/app_theme.dart';

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
          const _SectionHeader('작품 데이터'),
          const _WorksSyncTile(),
          const _SectionHeader('데이터 관리'),
          const _CsvExportTile(),
          const _CsvImportTile(),
          // TODO: 클래식 재작성 (2B)
          //   book 시절의 KDC 자동 채우기(LibrarySearchService)는 도서 전용이라
          //   되살리지 않는다. 대응물이 있다면 Work 매칭 백필 쪽이다.
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
          const _SectionHeader('정보'),
          const _DiscogsAttribution(),
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

/// 참조 데이터(Works) 동기화 타일.
/// 앱 시작 시 로컬이 비어 있으면 자동으로 한 번 받고, 여기서는 수동 재동기화만
/// 제공한다(자동 주기 갱신은 미정 — §17-3).
class _WorksSyncTile extends ConsumerWidget {
  const _WorksSyncTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(worksSyncProvider);
    final syncing = state.isLoading;

    final subtitle = switch (state) {
      AsyncLoading() => '내려받는 중… (2만여 건이라 시간이 걸립니다)',
      AsyncError(:final error) => '동기화 실패: $error',
      AsyncData(:final value) when value == 0 =>
        '아직 받지 않았습니다. 탭하면 작곡가·작품 목록을 내려받습니다',
      AsyncData(:final value) => '작품 $value건 보유 — 탭하면 다시 받습니다',
    };

    return ListTile(
      leading: syncing
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.gold),
            )
          : const Icon(Icons.library_music_outlined, color: AppColors.gold),
      title: const Text('작품 데이터 새로고침',
          style: TextStyle(color: AppColors.cream, fontSize: 15)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: state.hasError ? AppColors.red : AppColors.muted,
          fontSize: 12,
        ),
      ),
      onTap: syncing
          ? null
          : () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(worksSyncProvider.notifier).sync();
              final s = ref.read(worksSyncProvider);
              messenger.showSnackBar(SnackBar(
                content: Text(s.hasError
                    ? '작품 데이터 동기화 실패'
                    : '작품 ${s.value ?? 0}건을 받았습니다'),
              ));
            },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CSV 내보내기 / 가져오기 (대 1-H)
//   형식·파싱은 services/csv_service.dart. 여기는 파일 입출력과 확인 UI만 맡는다.
// ─────────────────────────────────────────────────────────────────────────────

class _CsvExportTile extends ConsumerStatefulWidget {
  const _CsvExportTile();

  @override
  ConsumerState<_CsvExportTile> createState() => _CsvExportTileState();
}

class _CsvExportTileState extends ConsumerState<_CsvExportTile> {
  bool _busy = false;

  Future<void> _run() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final repo = ref.read(collectionRepositoryProvider);

      // 목록 뷰는 하위를 안 들고 있어 CSV를 못 만든다 — id만 얻고 애그리게이트를
      // 하나씩 조립한다. 내보내기는 드물게 누르는 동작이라 N번 조회를 감수한다.
      final summaries = await repo.getAlbumSummaries(AlbumFilter.empty);
      final albums = <Album>[];
      for (final s in summaries) {
        final a = await repo.getAlbum(s.id);
        if (a != null) albums.add(a);
      }
      if (albums.isEmpty) {
        messenger.showSnackBar(
            const SnackBar(content: Text('내보낼 음반이 없습니다')));
        return;
      }

      final csv = buildAlbumCsv(albums);
      // BOM을 붙인다 — 없으면 Excel이 UTF-8을 못 알아채 한글이 깨진다.
      final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);
      final now = DateTime.now();
      final stamp = '${now.year}${_two(now.month)}${_two(now.day)}'
          '_${_two(now.hour)}${_two(now.minute)}';

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'CSV 내보내기',
        fileName: 'classicshelf_$stamp.csv',
        bytes: bytes,
      );
      if (path == null) return; // 사용자가 취소
      messenger.showSnackBar(SnackBar(
        content: Text('음반 ${albums.length}장을 내보냈습니다'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('내보내기 실패: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.gold),
            )
          : const Icon(Icons.upload_file_outlined, color: AppColors.gold),
      title: const Text('CSV로 내보내기',
          style: TextStyle(color: AppColors.cream, fontSize: 15)),
      subtitle: const Text(
        '수록곡·연주자·악장까지 한 파일로. 백업과 이관에 씁니다',
        style: TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      onTap: _busy ? null : _run,
    );
  }
}

class _CsvImportTile extends ConsumerStatefulWidget {
  const _CsvImportTile();

  @override
  ConsumerState<_CsvImportTile> createState() => _CsvImportTileState();
}

class _CsvImportTileState extends ConsumerState<_CsvImportTile> {
  bool _busy = false;

  /// 내보내기는 UTF-8(BOM)로 쓰지만, 사용자가 Excel에서 저장하면 한글 Windows
  /// 기준 CP949로 나온다. UTF-8로 먼저 읽어 보고 깨지면 CP949로 다시 읽는다.
  Future<String> _decode(Uint8List bytes) async {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      try {
        return await CharsetConverter.decode('EUC-KR', bytes);
      } catch (_) {
        // 그래도 안 되면 손상 문자를 흘려보내고 진행한다 — 일부 깨진 셀 때문에
        // 파일 전체를 거부하지 않는다.
        return utf8.decode(bytes, allowMalformed: true);
      }
    }
  }

  Future<void> _run() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      // 확장자 필터를 걸면 기기·파일관리자에 따라 csv가 회색으로 잠기는 일이
      // 있어 전체를 열고 내용으로 판단한다.
      final picked = await FilePicker.platform.pickFiles(withData: true);
      final bytes = picked?.files.single.bytes;
      if (bytes == null) return; // 취소 또는 읽기 실패

      final content = await _decode(bytes);
      const uuid = Uuid();
      final result = parseAlbumCsv(content, newId: uuid.v4);

      if (result.albums.isEmpty) {
        messenger.showSnackBar(SnackBar(
          content: Text(result.warnings.isEmpty
              ? '가져올 음반이 없습니다'
              : result.warnings.first),
        ));
        return;
      }
      if (!mounted) return;

      // 가져오기는 같은 id의 기존 앨범을 덮어쓴다 — 누르기 전에 규모를 보여준다.
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface2,
          title: const Text('CSV 가져오기',
              style: TextStyle(color: AppColors.cream, fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '음반 ${result.albums.length}장 '
                '(수록곡 ${result.albums.fold<int>(0, (n, a) => n + a.compositions.length)}곡)'
                '을 가져옵니다.\n'
                '같은 id의 음반이 이미 있으면 덮어씁니다.',
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              if (result.warnings.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '건너뛴 줄 ${result.warnings.length}건',
                  style: const TextStyle(color: AppColors.red, fontSize: 12),
                ),
                const SizedBox(height: 4),
                ...result.warnings.take(3).map((w) => Text(
                      '· $w',
                      style: const TextStyle(
                          color: AppColors.dim, fontSize: 11),
                    )),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  const Text('취소', style: TextStyle(color: AppColors.muted)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('가져오기',
                  style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      );
      if (ok != true) return;

      // 저장은 기존 경로 그대로 — saveAlbum이 로컬 커밋 후 온라인이면 원격,
      // 아니면 큐에 쌓는다. 가져오기 전용 저장 경로를 만들지 않는다.
      final repo = ref.read(collectionRepositoryProvider);
      var saved = 0;
      final failures = <String>[];
      for (final a in result.albums) {
        try {
          await repo.saveAlbum(a);
          saved++;
        } catch (e) {
          failures.add('${a.title}: $e');
        }
      }
      messenger.showSnackBar(SnackBar(
        content: Text(failures.isEmpty
            ? '음반 $saved장을 가져왔습니다'
            : '음반 $saved장 가져옴 · ${failures.length}장 실패'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('가져오기 실패: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.gold),
            )
          : const Icon(Icons.download_outlined, color: AppColors.gold),
      title: const Text('CSV 가져오기',
          style: TextStyle(color: AppColors.cream, fontSize: 15)),
      subtitle: const Text(
        '내보낸 형식 그대로. 같은 id면 덮어쓰고, 없으면 새로 만듭니다',
        style: TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      onTap: _busy ? null : _run,
    );
  }
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Discogs 출처 표기 (§2-5). Discogs API Terms of Use가 요구하는 고정 문구로,
/// 문안을 임의로 줄이거나 바꾸면 안 된다(상표·비제휴 고지가 핵심).
/// 바코드 조회 기능을 쓰는 한 이 표기는 앱에 남아 있어야 한다.
class _DiscogsAttribution extends StatelessWidget {
  const _DiscogsAttribution();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Text(
        "This application uses Discogs' API but is not affiliated with, "
        "sponsored or endorsed by Discogs. 'Discogs' is a trademark of "
        'Zink Media, LLC.',
        style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.5),
      ),
    );
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
