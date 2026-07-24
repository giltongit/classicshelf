import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'stats_common.dart';

class StatsYearScreen extends ConsumerWidget {
  const StatsYearScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('출판연도 분포')),
      body: booksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Text('불러오기 실패: $e',
              style: const TextStyle(color: AppColors.red)),
        ),
        data: (books) => _YearBody(
              books: books.where((b) => !b.isDisposed).toList(),
            ),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

typedef _YearEntry = ({String label, int count, List<Book> yearBooks});

class _YearBody extends StatelessWidget {
  final List<Book> books;
  const _YearBody({required this.books});

  @override
  Widget build(BuildContext context) {
    // 연도별 파티셔닝
    final yearMap = <int, List<Book>>{};
    final unknownBooks = <Book>[];
    for (final b in books) {
      final y = int.tryParse(b.year?.trim() ?? '');
      if (y == null) {
        unknownBooks.add(b);
      } else {
        yearMap.putIfAbsent(y, () => []).add(b);
      }
    }

    if (yearMap.isEmpty && unknownBooks.isEmpty) {
      return const Center(
        child: Text('연도 정보가 없습니다',
            style: TextStyle(color: AppColors.muted)),
      );
    }

    // 범위: [upperYear .. minYear] 내림차순 (미래 연도 책도 포함)
    final currentYear = DateTime.now().year;
    final rows = <_YearEntry>[];
    final int? minYear =
        yearMap.isEmpty ? null : yearMap.keys.reduce(min);

    if (minYear != null) {
      final upperYear = max(currentYear, yearMap.keys.reduce(max));
      for (var y = upperYear; y >= minYear; y--) {
        final yBooks = yearMap[y] ?? [];
        rows.add((label: '$y', count: yBooks.length, yearBooks: yBooks));
      }
    }

    // 미상 맨 끝
    if (unknownBooks.isNotEmpty) {
      rows.add((
        label: '미상',
        count: unknownBooks.length,
        yearBooks: unknownBooks,
      ));
    }

    final maxVal =
        rows.map((r) => r.count).fold(0, (a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (minYear != null) ...[
          Text(
            '$minYear년부터 올해까지',
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.dim, height: 1),
          const SizedBox(height: 8),
        ],
        ...rows.map((r) => _YearBarRow(
              label: r.label,
              count: r.count,
              ratio: (maxVal > 0 && r.count > 0) ? r.count / maxVal : 0,
              onTap: r.count > 0
                  ? () => _showModal(context, r.label, r.yearBooks)
                  : null,
            )),
      ],
    );
  }

  void _showModal(
      BuildContext context, String label, List<Book> yearBooks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (sheetCtx, scrollController) => _YearBooksSheet(
          label: label,
          yearBooks: yearBooks,
          scrollController: scrollController,
          outerContext: context,
        ),
      ),
    );
  }
}

// ── 연도별 책 목록 모달 시트 ──────────────────────────────────────────────────

class _YearBooksSheet extends StatelessWidget {
  final String label;
  final List<Book> yearBooks;
  final ScrollController scrollController;
  final BuildContext outerContext;

  const _YearBooksSheet({
    required this.label,
    required this.yearBooks,
    required this.scrollController,
    required this.outerContext,
  });

  @override
  Widget build(BuildContext context) {
    // ListTile/InkWell은 가장 가까운 Material에 잉크 효과를 그린다.
    // Container 배경을 쓰면 그 효과가 가려지므로 Material로 배경을 칠한다.
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$label · ${yearBooks.length}권',
                style: const TextStyle(
                    color: AppColors.cream,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Divider(color: AppColors.dim, height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: yearBooks.length,
              itemBuilder: (_, i) {
                final b = yearBooks[i];
                return ListTile(
                  leading: StatsSmallCover(
                      coverUrl: b.coverUrl, title: b.title),
                  title: Text(
                    b.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.cream, fontSize: 13),
                  ),
                  subtitle: Text(
                    b.author,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    outerContext.push('/books/${b.localId}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── 연도 행 (탭 가능) ────────────────────────────────────────────────────────

class _YearBarRow extends StatelessWidget {
  final String label;
  final int count;
  final double ratio; // 0.0 = 0권 (막대 없음, 행 표시)
  final VoidCallback? onTap;

  const _YearBarRow({
    required this.label,
    required this.count,
    required this.ratio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                label,
                style: TextStyle(
                    color: active ? AppColors.cream : AppColors.dim,
                    fontSize: 12),
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
                    if (ratio > 0)
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
                active ? '$count' : '',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: AppColors.cream, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
