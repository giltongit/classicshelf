import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../utils/kdc_genre.dart';
import '../utils/my_tags.dart';

class BookDetailScreen extends ConsumerWidget {
  final int localId;
  const BookDetailScreen({super.key, required this.localId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);

    return booksAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(
          child: Text('불러오기 실패: $e', style: const TextStyle(color: AppColors.red)),
        ),
      ),
      data: (books) {
        final book = books.where((b) => b.localId == localId).firstOrNull;
        if (book == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('책 정보')),
            body: const Center(
              child: Text('책을 찾을 수 없습니다', style: TextStyle(color: AppColors.muted)),
            ),
          );
        }
        return _BookDetailBody(book: book, ref: ref);
      },
    );
  }
}

class _BookDetailBody extends StatelessWidget {
  final Book book;
  final WidgetRef ref;
  const _BookDetailBody({required this.book, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.cream,
            leading: Container(
              margin: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                iconSize: 22,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 100, 14),
              title: Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCover(book.coverUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: '수정',
                  onPressed: () => context.push('/add', extra: book),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  iconSize: 22,
                ),
              ),
              if (book.isActiveOwned || book.isDisposed)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(book.isDisposed
                        ? Icons.replay
                        : Icons.inventory_2_outlined),
                    tooltip: book.isDisposed ? '처분 취소' : '처분하기',
                    onPressed: () => book.isDisposed
                        ? _undispose(context, ref, book)
                        : _confirmDispose(context, ref, book),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    iconSize: 22,
                  ),
                ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                  tooltip: '삭제',
                  onPressed: () => _confirmDelete(context),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  iconSize: 22,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  book.author,
                  style: const TextStyle(color: AppColors.gold, fontSize: 15),
                ),
                const SizedBox(height: 16),

                _StatusToggleRow(book: book, ref: ref),

                if (book.isDisposed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(
                          '처분됨 · ${book.disposedAt!.year}년 ${book.disposedAt!.month}월 ${book.disposedAt!.day}일',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                if (book.isRead)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        const Text('읽은 책',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.dim),
                const SizedBox(height: 16),

                ..._infoRowsMain(book),

                if (book.isbn?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.local_library_outlined, size: 18),
                      label: const Text('가까운 도서관에서 이 책 찾아보기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        side: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => context.push(
                        '/search?tab=library&isbn=${Uri.encodeComponent(book.isbn!)}',
                      ),
                    ),
                  ),
                ],

                ..._infoRowsTail(book),

                if ((book.review ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '메모',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(book.review!, style: const TextStyle(color: AppColors.cream, height: 1.6)),
                ],

                if ((book.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '책 소개',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(book.description!,
                      style: const TextStyle(color: AppColors.cream, height: 1.6)),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(String? url) {
    if (url == null) return Container(color: AppColors.surface2);
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(color: AppColors.surface2),
        errorWidget: (_, _, _) => Container(color: AppColors.surface2),
      );
    }
    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(color: AppColors.surface2),
    );
  }

  // 장르까지 — [가까운 도서관에서 이 책 찾아보기] 버튼은 이 목록과 _infoRowsTail
  // 사이, 장르 바로 아래에 표시된다.
  List<Widget> _infoRowsMain(Book b) {
    final acquiredStr = b.acquiredAt != null
        ? '${b.acquiredAt!.year}년 ${b.acquiredAt!.month}월 ${b.acquiredAt!.day}일'
        : null;
    final pairs = <(String, String?)>[
      ('출판연도', b.year),
      ('출판사',   b.publisher),
      ('책 만난 날', acquiredStr),
      ('책장 위치', b.location),
      ('청구기호', b.callNumber),
      ('KDC',    b.kdc),
      ('DDC',    b.ddc),
      ('LC',     b.lc),
      ('ISBN',   b.isbn),
      ('매체',   b.medium == 'paper' ? '종이책'
               : b.medium == 'ebook' ? '전자책'
               : b.medium == 'audio' ? '오디오북'
               : b.medium),
    ];
    final rows = _filterInfoRows(pairs);

    // 장르는 "경로 + 내 분류 칩"을 한 줄에 얹으므로 _InfoRow로 표현할 수 없다.
    final path = kdcToGenre(b.kdc)?.pathLabel;
    final tags = parseMyTags(b.genre);
    if (path != null || tags.isNotEmpty) {
      rows.add(_GenreInfoRow(path: path, tags: tags));
    }
    return rows;
  }

  // 총 페이지 — 장르 아래 버튼 다음에 이어서 표시된다.
  List<Widget> _infoRowsTail(Book b) {
    final pairs = <(String, String?)>[
      ('총 페이지', b.pageCount?.toString()),
    ];
    return _filterInfoRows(pairs);
  }

  // map<Widget>: 반환 리스트에 _GenreInfoRow를 덧붙이므로 런타임 타입이
  // List<_InfoRow>로 좁혀지면 안 된다.
  List<Widget> _filterInfoRows(List<(String, String?)> pairs) => pairs
      .where((p) => p.$2 != null && p.$2!.isNotEmpty)
      .map<Widget>((p) => _InfoRow(label: p.$1, value: p.$2!))
      .toList();

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('책 삭제'),
        content: Text('"${book.title}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(bookRepositoryProvider).deleteBook(book);
    ref.invalidate(booksProvider);
    if (context.mounted) context.pop();
  }

  /// 처분(판매/기부/분실 등) 처리. status는 'owned'로 유지하고 disposedAt만
  /// 기록한다 (결정: disposed 상태 A안 — §25). 행 삭제가 아니라 이력 보존.
  Future<void> _confirmDispose(
      BuildContext context, WidgetRef ref, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('책 처분'),
        content: Text(
          '"${book.title}"을(를) 처분 처리하시겠습니까?\n'
          '서가 목록에서 기본적으로 숨겨지고, 필터에서 다시 볼 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.gold),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('처분'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(bookRepositoryProvider).updateBook(
          book.copyWith(disposedAt: DateTime.now()),
        );
    ref.invalidate(booksProvider);
  }

  /// 처분 취소(되돌리기). disposedAt만 지우면 원래 상태로 자동 복원된다.
  Future<void> _undispose(
      BuildContext context, WidgetRef ref, Book book) async {
    await ref.read(bookRepositoryProvider).updateBook(
          book.copyWith(disposedAt: null),
        );
    ref.invalidate(booksProvider);
  }
}

class _StatusToggleRow extends StatelessWidget {
  final Book book;
  final WidgetRef ref;
  const _StatusToggleRow({required this.book, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('상태', style: TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(width: 12),
        ToggleButtons(
          isSelected: [
            book.status == 'owned',
            book.status == 'wishlist',
            book.status == 'rental',
          ],
          onPressed: (i) async {
            final newStatus = ['owned', 'wishlist', 'rental'][i];
            if (newStatus == book.status) return;
            await ref.read(bookRepositoryProvider).updateBook(
              // 상태를 수동으로 바꾸는 시점엔 처분 이력도 함께 해제한다 —
              // 처분됨은 owned 책에만 의미가 있음 (결정: disposed 상태 §25)
              book.copyWith(status: newStatus, disposedAt: null),
            );
            ref.invalidate(booksProvider);
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: AppColors.bg,
          fillColor: AppColors.gold,
          color: AppColors.muted,
          borderColor: AppColors.dim,
          selectedBorderColor: AppColors.gold,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          constraints: const BoxConstraints(minHeight: 36, minWidth: 68),
          children: const [Text('소장'), Text('희망'), Text('대여')],
        ),
      ],
    );
  }
}

/// 장르 경로와 "내 분류" 칩을 한 줄에 얹는다. 예: `문학 > 한국소설 · #SF #디스토피아`
/// 미분류(kdc 없음)면 칩만 표시한다 (§26).
class _GenreInfoRow extends StatelessWidget {
  final String? path;
  final List<String> tags;
  const _GenreInfoRow({required this.path, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 76,
            child: Text('장르',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (path != null)
                  Text(path!,
                      style: const TextStyle(
                          color: AppColors.cream, fontSize: 13)),
                if (path != null && tags.isNotEmpty)
                  const Text('·',
                      style:
                          TextStyle(color: AppColors.muted, fontSize: 13)),
                ...tags.map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.dim),
                      ),
                      child: Text('#$t',
                          style: const TextStyle(
                              color: AppColors.gold, fontSize: 12)),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.cream, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
