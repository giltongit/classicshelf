import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../services/csv_import_service.dart';
import '../theme/app_theme.dart';

final _csvImportServiceProvider = Provider<CsvImportService>((ref) {
  return CsvImportService(
    ref.watch(bookRepositoryProvider),
    ref.watch(authServiceProvider),
  );
});

class CsvImportScreen extends ConsumerStatefulWidget {
  const CsvImportScreen({super.key});

  @override
  ConsumerState<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends ConsumerState<CsvImportScreen> {
  // 단계: idle → preview → done
  _Step _step = _Step.idle;
  bool _loading = false;
  String? _error;

  List<ImportRow> _rows = [];
  DuplicateAction _dupAction = DuplicateAction.skip;
  ImportResult? _result;

  // ── 파일 선택 + 파싱 + 중복 감지 ─────────────────────────
  Future<void> _pickAndParse() async {
    setState(() { _loading = true; _error = null; });
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (picked == null || picked.files.single.bytes == null) {
        setState(() => _loading = false);
        return;
      }

      final bytes = picked.files.single.bytes!;
      final service = ref.read(_csvImportServiceProvider);

      final rows = await service.parseCsv(bytes);
      if (rows.isEmpty) throw Exception('CSV 파일이 비어 있습니다.');

      final headerMap = service.buildHeaderMap(rows[0]);
      if (!headerMap.columnIndex.containsKey('title') ||
          !headerMap.columnIndex.containsKey('author')) {
        throw Exception('제목(title)과 저자(author) 열을 찾을 수 없습니다.');
      }

      final importRows = await service.detectDuplicates(rows, headerMap);
      if (importRows.isEmpty) throw Exception('가져올 수 있는 행이 없습니다.');

      setState(() {
        _rows = importRows;
        _step = _Step.preview;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── 실행 ─────────────────────────────────────────────────
  Future<void> _execute() async {
    setState(() => _loading = true);
    try {
      final service = ref.read(_csvImportServiceProvider);
      final result = await service.executeImport(_rows, _dupAction);
      setState(() { _result = result; _step = _Step.done; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── 전체 선택/해제 ────────────────────────────────────────
  void _toggleAll(bool value) {
    setState(() {
      for (final r in _rows) { r.selected = value; }
    });
  }

  int get _selectedCount => _rows.where((r) => r.selected).length;
  int get _newCount => _rows.where((r) => r.isNew).length;
  int get _dupCount => _rows.where((r) => !r.isNew).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.cream,
        title: const Text('CSV 가져오기'),
      ),
      body: switch (_step) {
        _Step.idle   => _buildIdle(),
        _Step.preview => _buildPreview(),
        _Step.done   => _buildDone(),
      },
    );
  }

  // ── idle: 파일 선택 ───────────────────────────────────────
  Widget _buildIdle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file_outlined, size: 64, color: AppColors.gold),
            const SizedBox(height: 24),
            const Text(
              'CSV 파일을 선택하세요',
              style: TextStyle(color: AppColors.cream, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'UTF-8 · EUC-KR(CP949) 인코딩 지원\n내서재 내보내기 파일 또는 동일 형식의 CSV',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.6),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
            ],
            const SizedBox(height: 32),
            if (_loading)
              const CircularProgressIndicator(color: AppColors.gold)
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bg,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('파일 선택', style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: _pickAndParse,
              ),
          ],
        ),
      ),
    );
  }

  // ── preview: 미리보기 + 중복 처리 선택 ───────────────────
  Widget _buildPreview() {
    final allSelected = _rows.every((r) => r.selected);
    return Column(
      children: [
        // 요약 바
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Badge('전체 ${_rows.length}', AppColors.muted),
                  const SizedBox(width: 8),
                  _Badge('신규 $_newCount', AppColors.green),
                  const SizedBox(width: 8),
                  _Badge('중복 $_dupCount', AppColors.gold),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('중복 처리:', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(width: 8),
                  _DupToggle(
                    value: _dupAction,
                    onChanged: (v) => setState(() => _dupAction = v),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 전체 선택
        CheckboxListTile(
          tileColor: AppColors.surface2,
          value: allSelected,
          onChanged: (v) => _toggleAll(v ?? false),
          title: Text(
            '전체 선택 ($_selectedCount / ${_rows.length})',
            style: const TextStyle(color: AppColors.cream, fontSize: 13),
          ),
          activeColor: AppColors.gold,
          checkColor: AppColors.bg,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        // 행 목록
        Expanded(
          child: ListView.builder(
            itemCount: _rows.length,
            itemBuilder: (_, i) {
              final row = _rows[i];
              return CheckboxListTile(
                tileColor: i.isEven ? AppColors.surface : AppColors.surface2,
                value: row.selected,
                onChanged: (v) => setState(() => row.selected = v ?? false),
                activeColor: AppColors.gold,
                checkColor: AppColors.bg,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  row.data['title'] ?? '',
                  style: const TextStyle(color: AppColors.cream, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  row.data['author'] ?? '',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                secondary: row.isNew
                    ? const _Badge('신규', AppColors.green)
                    : const _Badge('중복', AppColors.gold),
              );
            },
          ),
        ),
        // 실행 버튼
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.bg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _selectedCount == 0 ? null : _execute,
                      child: Text(
                        '$_selectedCount권 가져오기',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ── done: 결과 ────────────────────────────────────────────
  Widget _buildDone() {
    final r = _result!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: AppColors.green),
            const SizedBox(height: 24),
            const Text('가져오기 완료',
                style: TextStyle(color: AppColors.cream, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            _ResultRow('추가', r.added, AppColors.green),
            _ResultRow('덮어쓰기', r.overwritten, AppColors.gold),
            _ResultRow('건너뜀', r.skipped, AppColors.muted),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.bg,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              onPressed: () => context.go('/'),
              child: const Text('서재로 돌아가기',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Step { idle, preview, done }

// ── 보조 위젯 ─────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _DupToggle extends StatelessWidget {
  final DuplicateAction value;
  final ValueChanged<DuplicateAction> onChanged;
  const _DupToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DuplicateAction>(
      style: SegmentedButton.styleFrom(
        backgroundColor: AppColors.surface2,
        foregroundColor: AppColors.muted,
        selectedForegroundColor: AppColors.bg,
        selectedBackgroundColor: AppColors.gold,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: const TextStyle(fontSize: 11),
      ),
      segments: const [
        ButtonSegment(value: DuplicateAction.skip, label: Text('건너뛰기')),
        ButtonSegment(value: DuplicateAction.overwrite, label: Text('덮어쓰기')),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _ResultRow(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 80,
            child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14))),
          Text('$count권', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
