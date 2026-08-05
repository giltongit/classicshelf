// =============================================================================
// wishlist_screen.dart — 희망 목록 "희망" 탭 (대 1-D)
//
// Wishlist는 Album과 별개 독립 애그리게이트 루트(§3-2)다. 앨범 목록에 토글을
// 얹지 않고 별도 탭으로 둔 이유가 여기 있다 — 조회 경로도 필터도 공유하지 않는다.
//
// 구독: wishlistProvider (StreamProvider, Drift watch) — 추가/삭제 후
//   invalidate 호출이 없다. 서가 목록과 같은 패턴(§6-1).
//
// 항목 단위 insert/delete라 Album의 LWW 통째 덮어쓰기 함정(§3-2)은 해당 없다:
//   "폼에 없는 필드가 유실된다"는 문제 자체가 성립하지 않는다.
//
// 확정 연결(§17-20, 해소): 카드를 탭하면 추가 시트가 편집 모드로 열리고, 등록 폼과
//   같은 작곡가→작품 2단 자동완성(widgets/form_fields.dart)으로 work_id를 채운다.
//   고르지 않으면 workId는 null 그대로 — 자유 텍스트 위시도 계속 유효하다.
//
// 이번 범위 밖(§17 부채):
//   · 자동 해소 — 앨범을 등록할 때 매칭되는 위시를 감지해 지우는 로직.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/wishlist_entry.dart';
import '../models/work.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/form_fields.dart';

const _uuid = Uuid();

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishAsync = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('희망 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '희망 항목 추가',
            onPressed: () => _openWishSheet(context),
          ),
        ],
      ),
      body: wishAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => Center(
          child: Text(
            '불러오기 실패: $e',
            style: const TextStyle(color: AppColors.red),
            textAlign: TextAlign.center,
          ),
        ),
        data: (items) {
          if (items.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, i) => _WishCard(item: items[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.bg,
        tooltip: '희망 항목 추가',
        onPressed: () => _openWishSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── 빈 상태 ────────────────────────────────────────────────────────────────────

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border, size: 56, color: AppColors.dim),
          const SizedBox(height: 16),
          const Text(
            '희망 목록이 비어 있습니다',
            style: TextStyle(color: AppColors.muted, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '듣고 싶은 작품이나 음반을 적어두세요',
            style: TextStyle(color: AppColors.dim, fontSize: 13),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('희망 항목 추가'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gold,
              side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            onPressed: () => _openWishSheet(context),
          ),
        ],
      ),
    );
  }
}

// ── 항목 카드 ──────────────────────────────────────────────────────────────────
// 삭제 UX는 앨범 상세(book_detail_screen)의 확인 다이얼로그 패턴을 따른다.
// 스와이프만 두면 오조작 시 되돌릴 길이 없어, 스와이프 후에도 확인을 받는다.

class _WishCard extends ConsumerWidget {
  final WishItem item;
  const _WishCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.red),
      ),
      confirmDismiss: (_) => _confirmDelete(context, item),
      onDismissed: (_) => _delete(context, ref, item),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          // 상세 화면 대신 편집 시트 — 확정 연결(work_id)을 여기서 붙인다.
          onTap: () => _openWishSheet(context, existing: item),
          // 상세 화면이 없으므로 길게 눌러 삭제를 스와이프의 대체 경로로 둔다.
          onLongPress: () async {
            if (await _confirmDelete(context, item) && context.mounted) {
              await _delete(context, ref, item);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayTitle,
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.displaySubtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.displaySubtitle!,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _TypeBadge(type: item.type),
                          const SizedBox(width: 8),
                          // 확정 연결됨 — 자동 해소 감지가 강한 매칭을 쓸 수 있다.
                          if (item.workId != null) ...[
                            const Icon(Icons.link,
                                size: 13, color: AppColors.gold),
                            const SizedBox(width: 8),
                          ],
                          if (item.createdAt != null)
                            Text(
                              _formatDate(item.createdAt!),
                              style: const TextStyle(
                                color: AppColors.dim,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      if (item.note != null && item.note!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.note!,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final WishType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.goldSubtle,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.label,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.'
    '${d.day.toString().padLeft(2, '0')}';

// ── 삭제 ──────────────────────────────────────────────────────────────────────

Future<bool> _confirmDelete(BuildContext context, WishItem item) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface2,
      title: const Text('희망 항목 삭제',
          style: TextStyle(color: AppColors.cream, fontSize: 17)),
      content: Text(
        '「${item.displayTitle}」을(를) 희망 목록에서 지웁니다.',
        style: const TextStyle(color: AppColors.muted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('취소', style: TextStyle(color: AppColors.muted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('삭제', style: TextStyle(color: AppColors.red)),
        ),
      ],
    ),
  );
  return ok ?? false;
}

Future<void> _delete(
    BuildContext context, WidgetRef ref, WishItem item) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    // 목록은 Drift watch 기반이라 삭제만 하면 자동 갱신된다(invalidate 불필요).
    await ref.read(collectionRepositoryProvider).deleteWishItem(item.id);
    messenger.showSnackBar(const SnackBar(content: Text('삭제했습니다')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
  }
}

// ── 추가·편집 시트 ─────────────────────────────────────────────────────────────
// 한 시트가 신규와 편집을 겸한다(existing != null 이면 편집). 위시는 항목 단위
// upsert라 같은 id로 다시 저장하면 수정이 된다 — 별도 화면을 만들 이유가 없다.
//
// 작곡가·작품 입력은 등록 폼과 같은 AutocompleteField다. 고르면 workId가 붙고,
// 그냥 타이핑하면 예전처럼 자유 텍스트로 남는다 — 연결을 강제하지 않는다(§4-9).

void _openWishSheet(BuildContext context, {WishItem? existing}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true, // 키보드가 올라와도 폼이 가려지지 않게
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _WishSheet(existing: existing),
  );
}

class _WishSheet extends ConsumerStatefulWidget {
  /// null이면 신규 추가, 값이 있으면 그 항목의 편집.
  final WishItem? existing;
  const _WishSheet({this.existing});

  @override
  ConsumerState<_WishSheet> createState() => _WishSheetState();
}

class _WishSheetState extends ConsumerState<_WishSheet> {
  final _composerCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _composerFocus = FocusNode();
  final _titleFocus = FocusNode();

  late final String _id;
  late WishType _type;
  bool _saving = false;
  String? _composerError; // 자동완성 필드는 TextFormField가 아니라 직접 검증한다

  /// 자동완성에서 고른 정규 작품. 안 골랐으면 null(미매칭 허용).
  String? _workId;

  /// workId를 채울 때 고른 작품의 제목. 이후 제목을 손으로 고치면 매칭이 더는
  /// 유효하지 않으므로 workId를 떨군다(등록 폼 카드와 같은 규칙).
  String? _matchedTitle;

  // 폼에 입력란이 없는 필드 — 편집 시 그대로 다시 실어 보낸다.
  // saveWishItem은 행 통째 upsert라 여기서 안 들고 있으면 저장 한 번에 지워진다.
  String? _albumId;
  int? _priority;
  String? _note;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _id = e?.id ?? _uuid.v4(); // 신규는 클라이언트 UUID 발급(§3-0)
    _type = e?.type ?? WishType.work;
    _composerCtrl.text = e?.composer ?? '';
    _titleCtrl.text = e?.title ?? '';
    _workId = e?.workId;
    _matchedTitle = e?.workId == null ? null : e?.title;
    _albumId = e?.albumId;
    _priority = e?.priority;
    _note = e?.note;
  }

  @override
  void dispose() {
    _composerCtrl.dispose();
    _titleCtrl.dispose();
    _composerFocus.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  /// type=album에는 work_id를 붙일 수 없다(wishlist_target_ck, §6-2).
  /// 자동완성은 두 유형 모두에서 쓰지만, 음반 단위일 땐 고른 결과가 제목·작곡가
  /// 텍스트로만 남는다.
  bool get _canLinkWork => _type == WishType.work;

  Future<void> _save() async {
    final composer = _composerCtrl.text.trim();
    if (composer.isEmpty) {
      setState(() => _composerError = '작곡가를 입력하세요');
      return;
    }
    setState(() {
      _composerError = null;
      _saving = true;
    });

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final title = _titleCtrl.text.trim();

    final item = WishItem(
      id: _id, // 편집이면 기존 id — saveWishItem이 upsert로 수정 처리
      type: _type,
      albumId: _type == WishType.album ? _albumId : null,
      workId: _canLinkWork ? _workId : null,
      composer: composer,
      title: title.isEmpty ? null : title,
      priority: _priority,
      note: _note,
    );

    try {
      // saveWishItem이 로컬 쓰기 → 온라인이면 Supabase upsert,
      // 오프라인·실패면 sync_queue 적재까지 처리한다. 여기서 분기하지 않는다.
      await ref.read(collectionRepositoryProvider).saveWishItem(item);
      navigator.pop();
      messenger.showSnackBar(SnackBar(
        content: Text(_isEditing ? '희망 항목을 수정했습니다' : '희망 목록에 추가했습니다'),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? '희망 항목 편집' : '희망 항목 추가',
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          AutocompleteField<String>(
            controller: _composerCtrl,
            focusNode: _composerFocus,
            label: '작곡가 *',
            hint: '예: Beethoven',
            // 신규는 바로 입력, 편집은 기존 값을 먼저 보게 둔다(키보드 안 띄움).
            autofocus: !_isEditing,
            search: (q) =>
                ref.read(collectionRepositoryProvider).suggestComposers(q),
            displayString: (s) => s,
            optionBuilder: (s) => Text(s,
                style:
                    const TextStyle(color: AppColors.cream, fontSize: 14)),
            onSelected: (_) => setState(() {
              // 작곡가가 바뀌면 이전 매칭은 더는 유효하지 않다.
              _workId = null;
              _matchedTitle = null;
              _composerError = null;
            }),
            onChanged: (_) => setState(() {
              _workId = null;
              _matchedTitle = null;
              _composerError = null;
            }),
          ),
          if (_composerError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(_composerError!,
                  style: const TextStyle(color: AppColors.red, fontSize: 12)),
            ),
          const SizedBox(height: 12),
          AutocompleteField<Work>(
            controller: _titleCtrl,
            focusNode: _titleFocus,
            label: '작품명 / 음반명',
            hint: '예: Symphony No. 5',
            search: (q) => ref
                .read(collectionRepositoryProvider)
                .suggestWorks(_composerCtrl.text, q),
            displayString: (w) => w.title,
            optionBuilder: (w) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.title,
                    style: const TextStyle(
                        color: AppColors.cream, fontSize: 14)),
                if (w.genre != null || w.period != null)
                  Text(
                    [w.genre, w.period].whereType<String>().join(' · '),
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11),
                  ),
              ],
            ),
            onSelected: (w) => setState(() {
              _workId = w.id;
              _matchedTitle = w.title;
              // 자동완성 목록은 이 작곡가의 works에서 왔으므로 표기를 정규명에 맞춘다.
              _composerCtrl.text = w.composer;
            }),
            onChanged: (v) => setState(() {
              // 고른 뒤 제목을 손으로 고치면 참조와 표기가 어긋난다 — 매칭 해제.
              if (_matchedTitle != null && v != _matchedTitle) {
                _workId = null;
                _matchedTitle = null;
              }
            }),
          ),
          if (_workId != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(
                    _canLinkWork ? Icons.link : Icons.link_off,
                    size: 14,
                    color: _canLinkWork ? AppColors.gold : AppColors.muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _canLinkWork
                        ? '작품 데이터와 연결됨'
                        : '음반 단위는 작품 연결을 저장하지 않습니다',
                    style: TextStyle(
                      color: _canLinkWork
                          ? AppColors.gold.withValues(alpha: 0.9)
                          : AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            '희망 단위',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 6),
          // 작품 단위(연주 무관) vs 음반 단위(특정 릴리스) — §6-2의 이중 성격.
          SegmentedButton<WishType>(
            segments: WishType.values
                .map((t) => ButtonSegment<WishType>(
                      value: t,
                      label: Text(t.label),
                    ))
                .toList(),
            selected: {_type},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('취소',
                    style: TextStyle(color: AppColors.muted)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bg,
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.bg),
                      )
                    : Text(_isEditing ? '저장' : '추가'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
