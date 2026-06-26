import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'stats_common.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    final trackingAsync = ref.watch(trackingStartedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: booksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Text('불러오기 실패: $e',
              style: const TextStyle(color: AppColors.red)),
        ),
        data: (books) => _StatsBody(
          books: books,
          trackingAsync: trackingAsync,
        ),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _StatsBody extends StatelessWidget {
  final List<Book> books;
  final AsyncValue<DateTime?> trackingAsync;

  const _StatsBody({required this.books, required this.trackingAsync});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_outlined, size: 56, color: AppColors.dim),
            SizedBox(height: 16),
            Text('등록된 책이 없습니다',
                style: TextStyle(color: AppColors.muted, fontSize: 15)),
          ],
        ),
      );
    }

    final wishlistPreview = _wishlistPreview(books);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _Section1AntiLibrary(books: books),
        const SizedBox(height: 12),
        _Section2MediumLang(books: books),
        const SizedBox(height: 12),
        _DrilldownCard(
          title: '출판연도 분포',
          preview: _yearPreview(books),
          route: '/stats/year',
        ),
        const SizedBox(height: 8),
        _DrilldownCard(
          title: '저자 집중도',
          preview: _authorPreview(books),
          route: '/stats/author',
        ),
        const SizedBox(height: 8),
        _DrilldownCard(
          title: '월별 책과의 만남',
          preview: _monthlyPreview(books, trackingAsync),
          route: '/stats/monthly',
        ),
        if (wishlistPreview != null) ...[
          const SizedBox(height: 8),
          _DrilldownCard(
            title: '오래 기다린 책',
            preview: wishlistPreview,
            route: '/stats/wishlist',
          ),
        ],
      ],
    );
  }

  // ── 드릴다운 카드 미리보기 텍스트 계산 ────────────────────────────────────

  static String _yearPreview(List<Book> books) {
    final counts = <String, int>{};
    for (final b in books) {
      final k = yearBucket(b.year);
      if (k != '미상') counts[k] = (counts[k] ?? 0) + 1;
    }
    if (counts.isEmpty) return '연도 정보가 없습니다';
    final top =
        counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return '${_bucketToDecade(top.key)} 책이 가장 많습니다';
  }

  static String _bucketToDecade(String b) => switch (b) {
        '~1979' => '1980년 이전',
        '1980-1985' || '1986-1990' => '1980년대',
        '1991-1995' || '1996-2000' => '1990년대',
        '2001-2005' || '2006-2010' => '2000년대',
        '2011-2015' || '2016-2020' => '2010년대',
        '2021-2025' => '2020년대',
        _ => b,
      };

  static String _authorPreview(List<Book> books) {
    final counts = <String, int>{};
    for (final b in books) {
      final a = b.author.trim();
      if (a.isNotEmpty) counts[a] = (counts[a] ?? 0) + 1;
    }
    if (counts.isEmpty || counts.values.every((v) => v == 1)) {
      return '다양한 저자의 책을 소장하고 있습니다';
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return '${sorted.first.key} 외 ${sorted.length - 1}명의 저자';
  }

  static String _monthlyPreview(
      List<Book> books, AsyncValue<DateTime?> trackingAsync) {
    return trackingAsync.maybeWhen(
      data: (date) {
        if (date == null) return '지금부터 기록을 시작할 수 있습니다';
        final count = books.where((b) {
          final d = b.acquiredAt ?? b.createdAt;
          return d != null && !d.isBefore(date);
        }).length;
        return '${date.month}월부터 기록 중 · 총 $count권';
      },
      orElse: () => '...',
    );
  }

  static String? _wishlistPreview(List<Book> books) {
    final wishlist = books.where((b) => b.status == 'wishlist').toList();
    if (wishlist.isEmpty) return null;
    final now = DateTime.now();
    wishlist.sort((a, b) {
      final aDays = now.difference(a.createdAt ?? now).inDays;
      final bDays = now.difference(b.createdAt ?? now).inDays;
      return bDays.compareTo(aDays);
    });
    final oldest = wishlist.first;
    final days = now.difference(oldest.createdAt ?? now).inDays;
    return '${oldest.title} · $days일째 기다리는 중';
  }
}

// ── 섹션 1: 안티라이브러리 대시보드 ──────────────────────────────────────────

class _Section1AntiLibrary extends StatelessWidget {
  final List<Book> books;
  const _Section1AntiLibrary({required this.books});

  @override
  Widget build(BuildContext context) {
    final total = books.length;
    final readCount = books.where((b) => b.isRead).length;
    final unread = total - readCount;
    final readRatio = total > 0 ? readCount / total : 0.0;
    final owned = books.where((b) => b.status == 'owned').length;
    final wishlist = books.where((b) => b.status == 'wishlist').length;
    final rental = books.where((b) => b.status == 'rental').length;
    final priority = books.where((b) => b.priorityRead).length;
    final message = _message(unread, total);

    return StatsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '나의 도서관 · 전체 $total권',
            style: const TextStyle(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: LayoutBuilder(
                builder: (ctx, constraints) => Row(
                  children: [
                    Container(
                      width: constraints.maxWidth * readRatio,
                      color: AppColors.gold,
                    ),
                    Expanded(child: Container(color: AppColors.dim)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _Dot(color: AppColors.gold),
              const SizedBox(width: 4),
              Text('읽음 $readCount권',
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12)),
              const SizedBox(width: 12),
              _Dot(color: AppColors.dim),
              const SizedBox(width: 4),
              Text('미독 $unread권',
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CountChip(
                  label: '소장',
                  count: owned,
                  fg: AppColors.gold,
                  bg: AppColors.goldSubtle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _CountChip(
                  label: '희망',
                  count: wishlist,
                  fg: AppColors.muted,
                  bg: AppColors.mutedSubtle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _CountChip(
                  label: '대여',
                  count: rental,
                  fg: const Color(0xFF5B7FA6),
                  bg: const Color(0x265B7FA6),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _CountChip(
                  label: '우선',
                  count: priority,
                  fg: AppColors.red,
                  bg: const Color(0x26E74C3C),
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  String _message(int unread, int total) {
    if (total == 0) return '';
    final ratio = unread / total;
    if (ratio >= 0.8) return '당신의 도서관은 무한한 가능성을 담고 있습니다';
    if (ratio >= 0.5) return '당신의 도서관에는 $unread권의 가능성이 있습니다';
    if (ratio >= 0.3) return '도서관의 절반이 아직 당신을 기다립니다';
    return '깊이 읽어내는 도서관입니다';
  }
}

// ── 섹션 2: 매체별 + 언어별 (조건부) ─────────────────────────────────────────

class _Section2MediumLang extends StatelessWidget {
  final List<Book> books;
  const _Section2MediumLang({required this.books});

  @override
  Widget build(BuildContext context) {
    final total = books.length;
    final paper = books.where((b) => b.medium == 'paper').length;
    final ebook = books.where((b) => b.medium == 'ebook').length;
    final audio = books.where((b) => b.medium == 'audio').length;

    final withLang = books
        .where((b) => b.language != null && b.language!.isNotEmpty)
        .toList();
    final langs = withLang.map((b) => b.language!).toSet();
    final showLang = withLang.length >= total * 0.2 &&
        !(langs.length == 1 && langs.first == 'ko');

    String langText = '';
    if (showLang) {
      final lc = <String, int>{};
      for (final b in withLang) {
        lc[b.language!] = (lc[b.language!] ?? 0) + 1;
      }
      final sorted = lc.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final parts = sorted
          .take(4)
          .map((e) => '${langNames[e.key] ?? e.key} ${e.value}')
          .toList();
      final other = sorted.skip(4).fold(0, (s, e) => s + e.value);
      if (other > 0) parts.add('기타 $other');
      langText = parts.join(' · ');
    }

    return StatsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatsSectionTitle('매체별 분포'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MediumCard(
                  icon: Icons.menu_book_outlined,
                  label: '종이책',
                  count: paper,
                  total: total,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MediumCard(
                  icon: Icons.tablet_outlined,
                  label: '전자책',
                  count: ebook,
                  total: total,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MediumCard(
                  icon: Icons.headphones_outlined,
                  label: '오디오북',
                  count: audio,
                  total: total,
                ),
              ),
            ],
          ),
          if (showLang) ...[
            const SizedBox(height: 10),
            const Divider(color: AppColors.dim, height: 1),
            const SizedBox(height: 8),
            const StatsSectionTitle('언어별'),
            const SizedBox(height: 4),
            Text(
              langText,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ── 드릴다운 카드 ──────────────────────────────────────────────────────────────

class _DrilldownCard extends StatelessWidget {
  final String title;
  final String preview;
  final String route;

  const _DrilldownCard({
    required this.title,
    required this.preview,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dim, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    preview,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── 섹션 전용 위젯 ────────────────────────────────────────────────────────────

class _MediumCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final int total;

  const _MediumCard(
      {required this.icon,
      required this.label,
      required this.count,
      required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(height: 6),
          Text('$count권',
              style: const TextStyle(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 2),
          Text('$pct%',
              style: const TextStyle(color: AppColors.gold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color fg;
  final Color bg;

  const _CountChip({
    required this.label,
    required this.count,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: fg, fontSize: 11)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$count',
              style: TextStyle(
                  color: fg, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
