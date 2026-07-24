import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../utils/kdc_genre.dart';
import 'stats_common.dart';

/// 장르 지형도 — KDC 대분류 10개를 고정된 위치의 "지역"으로, 중분류를 그 안의
/// 세부 지형으로 보여준다. 진행률/완독률이 아니라 "내 서가가 지식의 어느
/// 영역에 퍼져 있는가"를 지도처럼 보여주는 것이 목적 (안티라이브러리 철학 —
/// 비어 있는 영역은 결핍이 아니라 아직 가보지 않은 곳).
class StatsGenreScreen extends ConsumerWidget {
  const StatsGenreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('장르 지형도')),
      body: booksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => Center(
          child: Text(
            '불러오기 실패: $e',
            style: const TextStyle(color: AppColors.red),
          ),
        ),
        data: (books) =>
            _GenreBody(books: books.where((b) => !b.isDisposed).toList()),
      ),
    );
  }
}

/// kdc 문자열에서 대분류 키('0'~'9')만 뽑는다. 매핑에 없는 값이면 null(미분류).
String? _mainKeyOf(String? kdc) {
  if (kdc == null) return null;
  final t = kdc.trim();
  if (t.isEmpty) return null;
  final k = t[0];
  return kdcMainClassesOrdered.any((e) => e.key == k) ? k : null;
}

String _wrapLabel(String s) =>
    s.length > 2 ? '${s.substring(0, 2)}\n${s.substring(2)}' : s;

// ── Body ─────────────────────────────────────────────────────────────────────

class _GenreBody extends StatelessWidget {
  final List<Book> books;
  const _GenreBody({required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const Center(
        child: Text('등록된 책이 없습니다', style: TextStyle(color: AppColors.muted)),
      );
    }

    // 대분류별 책 목록 집계
    final byMain = <String, List<Book>>{};
    final unclassified = <Book>[];
    for (final b in books) {
      final key = _mainKeyOf(b.effectiveKdc);
      if (key == null) {
        unclassified.add(b);
      } else {
        byMain.putIfAbsent(key, () => []).add(b);
      }
    }

    final maxCount = kdcMainClassesOrdered
        .map((e) => byMain[e.key]?.length ?? 0)
        .fold(0, (a, b) => a > b ? a : b);
    final exploredCount = kdcMainClassesOrdered
        .where((e) => (byMain[e.key]?.length ?? 0) > 0)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          exploredCount == kdcMainClassesOrdered.length
              ? '10개 영역을 모두 탐험했습니다'
              : '10개 영역 중 $exploredCount곳을 탐험했습니다 · 나머지는 아직 가보지 않은 곳',
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        StatsSectionCard(
          child: SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: kdcMainClassesOrdered.map((e) {
                final list = byMain[e.key] ?? const <Book>[];
                final ratio = maxCount > 0 ? list.length / maxCount : 0.0;
                return Expanded(
                  child: _RidgeBar(
                    label: e.value,
                    count: list.length,
                    ratio: ratio,
                    onTap: list.isEmpty
                        ? null
                        : () => _openDivisionSheet(
                            context,
                            mainKey: e.key,
                            mainLabel: e.value,
                            mainBooks: list,
                          ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (unclassified.isNotEmpty) ...[
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openBooksSheet(
              context,
              title: '분류 안 된 책',
              books: unclassified,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '아직 분류되지 않은 책 ${unclassified.length}권',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.dim,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openDivisionSheet(
    BuildContext context, {
    required String mainKey,
    required String mainLabel,
    required List<Book> mainBooks,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (sheetCtx, scrollController) => _DivisionSheet(
          mainKey: mainKey,
          mainLabel: mainLabel,
          mainBooks: mainBooks,
          scrollController: scrollController,
          outerContext: context,
        ),
      ),
    );
  }

  void _openBooksSheet(
    BuildContext context, {
    required String title,
    required List<Book> books,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (sheetCtx, scrollController) => _BooksSheet(
          title: title,
          books: books,
          scrollController: scrollController,
          outerContext: context,
        ),
      ),
    );
  }
}

// ── 능선 막대 (대분류 1개) ────────────────────────────────────────────────────

class _RidgeBar extends StatelessWidget {
  final String label;
  final int count;
  final double ratio;
  final VoidCallback? onTap;

  const _RidgeBar({
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
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          // 라벨이 1줄/2줄이어도 막대 바닥선은 항상 고정 — 막대+숫자 영역과
          // 라벨 영역을 분리해 라벨 줄 수가 막대 위치에 영향을 주지 않게 한다.
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    active ? '$count' : '',
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 4 + 80 * ratio.clamp(0.0, 1.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: active ? AppColors.gold : AppColors.surface3,
                      border: active
                          ? null
                          : Border.all(color: AppColors.dim, width: 0.5),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 26, // 1줄/2줄 라벨 공통 고정 슬롯
              child: Text(
                _wrapLabel(label),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? AppColors.muted : AppColors.dim,
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 중분류 드릴다운 시트 ──────────────────────────────────────────────────────

class _DivisionSheet extends StatelessWidget {
  final String mainKey;
  final String mainLabel;
  final List<Book> mainBooks;
  final ScrollController scrollController;
  final BuildContext outerContext;

  const _DivisionSheet({
    required this.mainKey,
    required this.mainLabel,
    required this.mainBooks,
    required this.scrollController,
    required this.outerContext,
  });

  @override
  Widget build(BuildContext context) {
    final divisions = kdcDivisionsOf(mainKey);
    final byDivision = <String, List<Book>>{};
    for (final b in mainBooks) {
      final t = b.effectiveKdc?.trim() ?? '';
      if (t.length < 2) continue;
      final divKey = t.substring(0, 2);
      byDivision.putIfAbsent(divKey, () => []).add(b);
    }
    final maxCount = divisions
        .map((e) => byDivision[e.key]?.length ?? 0)
        .fold(0, (a, b) => a > b ? a : b);

    // ListTile/InkWell은 가장 가까운 Material에 잉크 효과를 그린다.
    // Container 배경을 쓰면 그 효과가 가려지므로 Material로 배경을 칠한다.
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
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
                '$mainLabel · ${mainBooks.length}권',
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Divider(color: AppColors.dim, height: 1),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: divisions.map((e) {
                final list = byDivision[e.key] ?? const <Book>[];
                final ratio = maxCount > 0 ? list.length / maxCount : 0.0;
                return _DivisionRow(
                  label: e.value,
                  count: list.length,
                  ratio: ratio,
                  onTap: list.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          showModalBottomSheet(
                            context: outerContext,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => DraggableScrollableSheet(
                              initialChildSize: 0.5,
                              minChildSize: 0.3,
                              maxChildSize: 0.9,
                              builder: (sheetCtx, sc) => _BooksSheet(
                                title: e.value,
                                books: list,
                                scrollController: sc,
                                outerContext: outerContext,
                              ),
                            ),
                          );
                        },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DivisionRow extends StatelessWidget {
  final String label;
  final int count;
  final double ratio;
  final VoidCallback? onTap;

  const _DivisionRow({
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
              width: 100,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? AppColors.cream : AppColors.dim,
                  fontSize: 12,
                ),
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
              width: 28,
              child: Text(
                active ? '$count' : '',
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.cream, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 책 목록 시트 (공용) ───────────────────────────────────────────────────────

class _BooksSheet extends StatelessWidget {
  final String title;
  final List<Book> books;
  final ScrollController scrollController;
  final BuildContext outerContext;

  const _BooksSheet({
    required this.title,
    required this.books,
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
                '$title · ${books.length}권',
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Divider(color: AppColors.dim, height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: books.length,
              itemBuilder: (_, i) {
                final b = books[i];
                return ListTile(
                  leading: StatsSmallCover(
                    coverUrl: b.coverUrl,
                    title: b.title,
                  ),
                  title: Text(
                    b.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    b.author,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
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
