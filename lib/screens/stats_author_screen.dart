import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'stats_common.dart';

class StatsAuthorScreen extends ConsumerWidget {
  const StatsAuthorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('가장 많이 만난 저자')),
      body: booksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Text('불러오기 실패: $e',
              style: const TextStyle(color: AppColors.red)),
        ),
        data: (books) => _AuthorBody(books: books),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _AuthorBody extends StatelessWidget {
  final List<Book> books;
  const _AuthorBody({required this.books});

  @override
  Widget build(BuildContext context) {
    // author → 책 목록 매핑
    final authorMap = <String, List<Book>>{};
    for (final b in books) {
      final a = b.author.trim();
      if (a.isNotEmpty) authorMap.putIfAbsent(a, () => []).add(b);
    }

    if (authorMap.isEmpty) {
      return const Center(
        child: Text('저자 정보가 없습니다',
            style: TextStyle(color: AppColors.muted)),
      );
    }

    // 권수 내림차순, 동률 가나다순, TOP 20
    final sorted = authorMap.entries.toList()
      ..sort((a, b) => b.value.length != a.value.length
          ? b.value.length.compareTo(a.value.length)
          : a.key.compareTo(b.key));
    final top20 = sorted.take(20).toList();
    final maxVal = top20.first.value.length;
    final allOne = maxVal == 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        if (allOne)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '모든 저자의 책을 1권씩 소장하고 있습니다',
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 13, height: 1.4),
            ),
          ),
        ...top20.map((e) {
          final authorBooks = e.value;
          return _AuthorBarRow(
            label: e.key,
            count: authorBooks.length,
            ratio: authorBooks.length / maxVal,
            onTap: () => _showModal(context, e.key, authorBooks),
          );
        }),
      ],
    );
  }

  void _showModal(
      BuildContext context, String author, List<Book> authorBooks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (sheetCtx, scrollController) => _AuthorBooksSheet(
          author: author,
          authorBooks: authorBooks,
          scrollController: scrollController,
          outerContext: context,
        ),
      ),
    );
  }
}

// ── 저자별 책 목록 모달 시트 ──────────────────────────────────────────────────

class _AuthorBooksSheet extends StatelessWidget {
  final String author;
  final List<Book> authorBooks;
  final ScrollController scrollController;
  final BuildContext outerContext;

  const _AuthorBooksSheet({
    required this.author,
    required this.authorBooks,
    required this.scrollController,
    required this.outerContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                '$author · ${authorBooks.length}권',
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
              itemCount: authorBooks.length,
              itemBuilder: (_, i) {
                final b = authorBooks[i];
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

// ── 저자 행 (탭 가능) ────────────────────────────────────────────────────────

class _AuthorBarRow extends StatelessWidget {
  final String label;
  final int count;
  final double ratio;
  final VoidCallback onTap;

  const _AuthorBarRow({
    required this.label,
    required this.count,
    required this.ratio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: const TextStyle(
                    color: AppColors.cream, fontSize: 12),
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
