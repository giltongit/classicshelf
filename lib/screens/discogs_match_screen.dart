// =============================================================================
// discogs_match_screen.dart — 바코드 후보 릴리스 선택 (§2-2 ④)
//
// 바코드 하나에 릴리스가 수백 건 잡히는 게 정상이다 — 같은 음반의 각국·각연도
// 프레싱이 Discogs에서는 전부 별개 릴리스이기 때문이다. 어느 판을 갖고 있는지는
// 사용자만 알 수 있으므로, 판을 가르는 정보(연도·국가·레이블·카탈로그번호·포맷)를
// 한 줄에 붙여 보여주고 고르게 한다.
//
// 20건씩 끊어 보여준다. 전부 그리면 목록이 길기만 하고 판단에 도움이 안 되는데,
// 대개 앞쪽 몇 건에서 정답이 나온다.
//
// 커버 이미지는 띄우지 않는다 — Discogs API Terms상 이미지는 Restricted Data라
// 상업적 사용이 금지된다(요청도 저장도 하지 않는다).
// =============================================================================

import 'package:flutter/material.dart';

import '../services/discogs_service.dart';
import '../theme/app_theme.dart';

class DiscogsMatchScreen extends StatefulWidget {
  final String barcode;
  final List<DiscogsMatch> matches;

  const DiscogsMatchScreen({
    super.key,
    required this.barcode,
    required this.matches,
  });

  @override
  State<DiscogsMatchScreen> createState() => _DiscogsMatchScreenState();
}

class _DiscogsMatchScreenState extends State<DiscogsMatchScreen> {
  int _visible = kDiscogsPageSize;

  @override
  Widget build(BuildContext context) {
    final total = widget.matches.length;
    final shown = _visible.clamp(0, total);
    final hasMore = shown < total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('음반 선택'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '바코드 ${widget.barcode} · $total건',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: shown + 1, // 마지막은 "더 보기" 또는 출처 표기
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.dim),
        itemBuilder: (context, i) {
          if (i == shown) {
            return Column(
              children: [
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: TextButton(
                      onPressed: () => setState(
                          () => _visible += kDiscogsPageSize),
                      child: Text(
                        '더 보기 (${total - shown}건 남음)',
                        style: const TextStyle(color: AppColors.gold),
                      ),
                    ),
                  ),
                const _DiscogsCredit(),
              ],
            );
          }

          final m = widget.matches[i];
          return ListTile(
            title: Text(
              m.title,
              style: const TextStyle(
                color: AppColors.cream,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (m.subtitle.isNotEmpty)
                  Text(
                    m.subtitle,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                if (m.format != null)
                  Text(
                    m.format!,
                    style: const TextStyle(color: AppColors.dim, fontSize: 11),
                  ),
              ],
            ),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.muted),
            onTap: () => Navigator.of(context).pop(m),
          );
        },
      ),
    );
  }
}

/// 출처 표기 (§2-5). Discogs 데이터가 보이는 화면에는 이 표기가 있어야 한다.
class _DiscogsCredit extends StatelessWidget {
  const _DiscogsCredit();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        'Data provided by Discogs',
        style: TextStyle(color: AppColors.muted, fontSize: 11),
      ),
    );
  }
}
