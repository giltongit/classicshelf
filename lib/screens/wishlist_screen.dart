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
// 이번 범위 밖(§17 부채):
//   · 자동 해소 — 앨범을 등록할 때 매칭되는 위시를 감지해 지우는 로직.
//   · 확정 연결 — composer/title 자유 텍스트를 실제 album_id/work_id로 잇는 UI.
//     Works 시드(대 1-A) 이후 작업.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/wishlist_entry.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

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
            onPressed: () => _openAddSheet(context, ref),
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
        onPressed: () => _openAddSheet(context, ref),
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
            onPressed: () => _openAddSheet(context, ref),
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

// ── 추가 시트 ──────────────────────────────────────────────────────────────────
// Works 시드(대 1-A)가 아직 없어 자동완성 대상이 없다. compositions.title(§3-1a)과
// 같은 방식으로 자유 텍스트를 받는다 — album_id/work_id는 여기서 채우지 않는다.

void _openAddSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true, // 키보드가 올라와도 폼이 가려지지 않게
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _AddWishSheet(),
  );
}

class _AddWishSheet extends ConsumerStatefulWidget {
  const _AddWishSheet();

  @override
  ConsumerState<_AddWishSheet> createState() => _AddWishSheetState();
}

class _AddWishSheetState extends ConsumerState<_AddWishSheet> {
  final _formKey = GlobalKey<FormState>();
  final _composerCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  WishType _type = WishType.work;
  bool _saving = false;

  @override
  void dispose() {
    _composerCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final title = _titleCtrl.text.trim();

    // 신규는 항상 클라이언트 UUID 발급(§3-0). 위시는 편집 개념이 없어 이 한 곳뿐.
    final item = WishItem(
      id: _uuid.v4(),
      type: _type,
      composer: _composerCtrl.text.trim(),
      title: title.isEmpty ? null : title,
    );

    try {
      // saveWishItem이 로컬 쓰기 → 온라인이면 Supabase upsert,
      // 오프라인·실패면 sync_queue 적재까지 처리한다. 여기서 분기하지 않는다.
      await ref.read(collectionRepositoryProvider).saveWishItem(item);
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('희망 목록에 추가했습니다')));
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '희망 항목 추가',
              style: TextStyle(
                color: AppColors.cream,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _composerCtrl,
              autofocus: true,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: AppColors.cream),
              decoration: const InputDecoration(
                labelText: '작곡가 *',
                hintText: '예: Beethoven',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '작곡가를 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: AppColors.cream),
              decoration: const InputDecoration(
                labelText: '작품명 / 음반명',
                hintText: '예: 교향곡 5번 Op.67',
              ),
              onFieldSubmitted: (_) => _saving ? null : _save(),
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
                  onPressed:
                      _saving ? null : () => Navigator.pop(context),
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
                      : const Text('추가'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
