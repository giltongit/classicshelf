// =============================================================================
// wish_resolution_dialog.dart — 위시 자동 해소 확인 (§17-21)
//
// 감지 결과를 사용자에게 보이고 승인한 것만 지운다. 트리거 두 곳(앨범 저장
// 직후 / 위시 화면 "지금 확인")이 같은 다이얼로그를 쓴다.
//
// 기본값은 전부 체크다 — 여기 오른 항목은 이미 "완전 일치"를 통과했고,
// 사용자는 대개 전부 지우려고 이 화면을 본다. 아닌 것만 풀면 된다.
// 아무것도 안 지우려면 취소 한 번으로 끝난다.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../services/wish_resolution.dart';
import '../theme/app_theme.dart';

/// 매칭 목록을 보이고, 사용자가 고른 위시 항목을 삭제한다.
/// 반환값은 실제로 지운 건수(0이면 취소했거나 전부 체크 해제).
/// [matches]가 비어 있으면 아무것도 하지 않고 0을 돌려준다 — 호출부에서
/// 매번 빈 검사를 반복하지 않게 여기서 흡수한다.
Future<int> promptWishResolution(
  BuildContext context,
  WidgetRef ref,
  List<WishMatch> matches,
) async {
  if (matches.isEmpty) return 0;

  final picked = await showDialog<List<WishMatch>>(
    context: context,
    barrierDismissible: false, // 무심코 닫아도 아무 일이 없게(=취소와 동일)
    builder: (_) => _WishResolutionDialog(matches: matches),
  );
  if (picked == null || picked.isEmpty) return 0;

  // 목록은 Drift watch 기반이라 삭제만 하면 자동 갱신된다(invalidate 불필요).
  final repo = ref.read(collectionRepositoryProvider);
  var removed = 0;
  for (final m in picked) {
    try {
      await repo.deleteWishItem(m.wish.id);
      removed++;
    } catch (e) {
      debugPrint('[WISH] 해소 삭제 실패 id=${m.wish.id}: $e');
    }
  }
  return removed;
}

class _WishResolutionDialog extends StatefulWidget {
  final List<WishMatch> matches;
  const _WishResolutionDialog({required this.matches});

  @override
  State<_WishResolutionDialog> createState() => _WishResolutionDialogState();
}

class _WishResolutionDialogState extends State<_WishResolutionDialog> {
  late final Set<String> _checked =
      widget.matches.map((m) => m.wish.id).toSet();

  @override
  Widget build(BuildContext context) {
    final multi = widget.matches.length > 1;
    return AlertDialog(
      backgroundColor: AppColors.surface2,
      title: Text(
        multi ? '소장한 희망 항목 ${widget.matches.length}건' : '소장한 희망 항목',
        style: const TextStyle(color: AppColors.cream, fontSize: 17),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              multi
                  ? '아래 희망 항목과 일치하는 음반이 서가에 있습니다. 지울 항목을 고르세요.'
                  : '이 희망 항목과 일치하는 음반이 서가에 있습니다. 위시에서 제거할까요?',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.matches.length,
                itemBuilder: (context, i) {
                  final m = widget.matches[i];
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.gold,
                    checkColor: AppColors.bg,
                    value: _checked.contains(m.wish.id),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _checked.add(m.wish.id);
                      } else {
                        _checked.remove(m.wish.id);
                      }
                    }),
                    title: Text(
                      m.wish.displayTitle,
                      style: const TextStyle(
                          color: AppColors.cream, fontSize: 14),
                    ),
                    subtitle: Text(
                      '음반: ${m.albumTitle}',
                      style: const TextStyle(
                          color: AppColors.dim, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('그대로 두기',
              style: TextStyle(color: AppColors.muted)),
        ),
        TextButton(
          onPressed: _checked.isEmpty
              ? null
              : () => Navigator.pop(
                    context,
                    widget.matches
                        .where((m) => _checked.contains(m.wish.id))
                        .toList(),
                  ),
          child: Text(
            multi ? '제거 (${_checked.length})' : '제거',
            style: TextStyle(
              color: _checked.isEmpty ? AppColors.dim : AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}
