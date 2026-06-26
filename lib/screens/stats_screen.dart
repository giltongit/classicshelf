import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

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
          onStartTracking: () =>
              ref.read(trackingStartedProvider.notifier).startToday(),
        ),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _StatsBody extends StatelessWidget {
  final List<Book> books;
  final AsyncValue<DateTime?> trackingAsync;
  final VoidCallback onStartTracking;

  const _StatsBody({
    required this.books,
    required this.trackingAsync,
    required this.onStartTracking,
  });

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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section1AntiLibrary(books: books),
          const SizedBox(height: 24),
          _Section2Medium(books: books),
          const SizedBox(height: 24),
          _Section3YearDist(books: books),
          const SizedBox(height: 24),
          _Section4Authors(books: books),
          ..._section5Language(books),
          _Section6Monthly(
            books: books,
            trackingAsync: trackingAsync,
            onStartTracking: onStartTracking,
          ),
          ..._section7Wishlist(context, books),
        ],
      ),
    );
  }

  List<Widget> _section5Language(List<Book> books) {
    final withLang =
        books.where((b) => b.language != null && b.language!.isNotEmpty).toList();
    if (withLang.isEmpty || withLang.length / books.length < 0.2) return [];
    final langs = withLang.map((b) => b.language!).toSet();
    if (langs.length == 1 && langs.first == 'ko') return [];
    return [
      const SizedBox(height: 24),
      _Section5Language(books: books, langBooks: withLang),
    ];
  }

  List<Widget> _section7Wishlist(BuildContext context, List<Book> books) {
    final wishlist = books.where((b) => b.status == 'wishlist').toList();
    if (wishlist.isEmpty) return [];
    return [
      const SizedBox(height: 24),
      _Section7Wishlist(wishlist: wishlist, context: context),
    ];
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

    return _SectionCard(
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
          // 읽음/미독 progress bar
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
          const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            const Divider(color: AppColors.dim),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 14,
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

// ── 섹션 2: 매체별 분포 ──────────────────────────────────────────────────────

class _Section2Medium extends StatelessWidget {
  final List<Book> books;
  const _Section2Medium({required this.books});

  @override
  Widget build(BuildContext context) {
    final total = books.length;
    final paper = books.where((b) => b.medium == 'paper').length;
    final ebook = books.where((b) => b.medium == 'ebook').length;
    final audio = books.where((b) => b.medium == 'audio').length;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('매체별 분포'),
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
        ],
      ),
    );
  }
}

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

// ── 섹션 3: 출판연도 분포 ──────────────────────────────────────────────────────

class _Section3YearDist extends StatelessWidget {
  final List<Book> books;
  const _Section3YearDist({required this.books});

  static const _bucketOrder = [
    '~1979', '1980-1985', '1986-1990', '1991-1995', '1996-2000',
    '2001-2005', '2006-2010', '2011-2015', '2016-2020', '2021-2025',
    '2026~', '미상',
  ];

  String _bucket(String? year) {
    if (year == null || year.isEmpty) return '미상';
    final y = int.tryParse(year.trim());
    if (y == null) return '미상';
    if (y <= 1979) return '~1979';
    if (y <= 1985) return '1980-1985';
    if (y <= 1990) return '1986-1990';
    if (y <= 1995) return '1991-1995';
    if (y <= 2000) return '1996-2000';
    if (y <= 2005) return '2001-2005';
    if (y <= 2010) return '2006-2010';
    if (y <= 2015) return '2011-2015';
    if (y <= 2020) return '2016-2020';
    if (y <= 2025) return '2021-2025';
    return '2026~';
  }

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final b in books) {
      final k = _bucket(b.year);
      counts[k] = (counts[k] ?? 0) + 1;
    }
    final rows = _bucketOrder
        .where((k) => (counts[k] ?? 0) > 0)
        .map((k) => (k, counts[k]!))
        .toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    final maxVal = rows.map((r) => r.$2).reduce(max);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('출판연도 분포'),
          const SizedBox(height: 12),
          ...rows.map((r) => _BarRow(
                label: r.$1,
                count: r.$2,
                ratio: r.$2 / maxVal,
              )),
        ],
      ),
    );
  }
}

// ── 섹션 4: 저자 집중도 ──────────────────────────────────────────────────────

class _Section4Authors extends StatelessWidget {
  final List<Book> books;
  const _Section4Authors({required this.books});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final b in books) {
      final a = b.author.trim();
      if (a.isNotEmpty) counts[a] = (counts[a] ?? 0) + 1;
    }
    final maxVal =
        counts.values.isNotEmpty ? counts.values.reduce(max) : 0;
    if (maxVal <= 1) return const SizedBox.shrink();

    final sorted = counts.entries.toList()
      ..sort((a, b) =>
          b.value != a.value ? b.value.compareTo(a.value) : a.key.compareTo(b.key));
    final top10 = sorted.take(10).toList();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('저자 집중도 TOP 10'),
          const SizedBox(height: 12),
          ...top10.map((e) => _BarRow(
                label: e.key,
                count: e.value,
                ratio: e.value / maxVal,
              )),
        ],
      ),
    );
  }
}

// ── 섹션 5: 언어별 분포 ──────────────────────────────────────────────────────

class _Section5Language extends StatelessWidget {
  final List<Book> books;
  final List<Book> langBooks;
  const _Section5Language(
      {required this.books, required this.langBooks});

  static const _langNames = {
    'ko': '한국어',
    'en': '영어',
    'ja': '일본어',
    'zh': '중국어',
    'fr': '프랑스어',
    'de': '독일어',
    'es': '스페인어',
  };

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final b in langBooks) {
      final l = b.language!;
      counts[l] = (counts[l] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isNotEmpty ? sorted.first.value : 1;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('언어별 분포'),
          const SizedBox(height: 12),
          ...sorted.map((e) => _BarRow(
                label: _langNames[e.key] ?? e.key,
                count: e.value,
                ratio: e.value / maxVal,
              )),
        ],
      ),
    );
  }
}

// ── 섹션 6: 월별 책과의 만남 ──────────────────────────────────────────────────

class _Section6Monthly extends StatelessWidget {
  final List<Book> books;
  final AsyncValue<DateTime?> trackingAsync;
  final VoidCallback onStartTracking;

  const _Section6Monthly({
    required this.books,
    required this.trackingAsync,
    required this.onStartTracking,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('월별 책과의 만남'),
          const SizedBox(height: 12),
          trackingAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.gold, strokeWidth: 2)),
            error: (e, s) => const Text('불러오기 실패',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
            data: (trackingDate) => trackingDate == null
                ? _TrackingSetupCard(onStart: onStartTracking)
                : _MonthlyChart(
                    books: books, trackingStartedAt: trackingDate),
          ),
        ],
      ),
    );
  }
}

class _TrackingSetupCard extends StatelessWidget {
  final VoidCallback onStart;
  const _TrackingSetupCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '지금부터 나의 도서관에 새로 들어오는 책의 흐름을 기록합니다',
          style: TextStyle(
              color: AppColors.cream, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onStart,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: const BorderSide(color: AppColors.gold),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('오늘부터 시작'),
        ),
      ],
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final List<Book> books;
  final DateTime trackingStartedAt;

  const _MonthlyChart(
      {required this.books, required this.trackingStartedAt});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // 최근 12개월 버킷 초기화
    final months = <String, int>{};
    for (var i = 11; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i);
      months['${m.year}-${m.month.toString().padLeft(2, '0')}'] = 0;
    }

    // tracking_started_at 이후 책만 집계 (effectiveDate = acquiredAt ?? createdAt)
    for (final b in books) {
      final d = b.acquiredAt ?? b.createdAt;
      if (d == null) continue;
      if (d.isBefore(trackingStartedAt)) continue;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      if (months.containsKey(key)) months[key] = months[key]! + 1;
    }

    final entries = months.entries.toList();
    final maxVal = entries.map((e) => e.value).reduce(max);

    if (maxVal == 0) {
      return const Text(
        '아직 기록된 책이 없습니다',
        style: TextStyle(color: AppColors.muted, fontSize: 13),
      );
    }

    return Column(
      children: entries.map((e) {
        final parts = e.key.split('-');
        final label = '${parts[0].substring(2)}년 ${int.parse(parts[1])}월';
        return _BarRow(
          label: label,
          count: e.value,
          ratio: maxVal > 0 ? e.value / maxVal : 0,
        );
      }).toList(),
    );
  }
}

// ── 섹션 7: 오래 기다린 책 ───────────────────────────────────────────────────

class _Section7Wishlist extends StatelessWidget {
  final List<Book> wishlist;
  final BuildContext context;

  const _Section7Wishlist(
      {required this.wishlist, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final now = DateTime.now();
    final sorted = [...wishlist]
      ..sort((a, b) {
        final aDays = now.difference(a.createdAt ?? now).inDays;
        final bDays = now.difference(b.createdAt ?? now).inDays;
        return bDays.compareTo(aDays);
      });
    final top = sorted.take(20).toList();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('오래 기다린 책'),
          const SizedBox(height: 12),
          ...top.map((b) => _WishlistRow(book: b, now: now, context: ctx)),
        ],
      ),
    );
  }
}

class _WishlistRow extends StatelessWidget {
  final Book book;
  final DateTime now;
  final BuildContext context;

  const _WishlistRow(
      {required this.book, required this.now, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final days = now.difference(book.createdAt ?? now).inDays;

    return InkWell(
      onTap: () => context.push('/books/${book.localId}'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            _SmallCover(coverUrl: book.coverUrl, title: book.title),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(book.author,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    '$days일째 기다리는 중',
                    style: const TextStyle(
                        color: AppColors.gold, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.dim, size: 16),
          ],
        ),
      ),
    );
  }
}

class _SmallCover extends StatelessWidget {
  final String? coverUrl;
  final String title;
  const _SmallCover({required this.coverUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 36,
        height: 50,
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (coverUrl == null) return _placeholder();
    if (coverUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: coverUrl!,
        fit: BoxFit.cover,
        placeholder: (c, u) => _placeholder(),
        errorWidget: (c, u, e) => _placeholder(),
      );
    }
    return Image.file(File(coverUrl!),
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => _placeholder());
  }

  Widget _placeholder() {
    final ch = title.isNotEmpty ? title[0] : '?';
    return Container(
      color: AppColors.surface3,
      alignment: Alignment.center,
      child: Text(ch,
          style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              fontSize: 14)),
    );
  }
}

// ── 공통 위젯 ─────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dim, width: 0.5),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int count;
  final double ratio;

  const _BarRow(
      {required this.label, required this.count, required this.ratio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) => Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.dim,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 8,
                    width: constraints.maxWidth * ratio.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.cream, fontSize: 12),
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withAlpha(80), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$count',
              style: TextStyle(
                color: fg,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
