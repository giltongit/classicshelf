import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _SectionHeader('데이터'),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'CSV로 내보내기',
            subtitle: '전체 도서 목록을 CSV 파일로 공유합니다',
            onTap: () => _exportCsv(context, ref),
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
