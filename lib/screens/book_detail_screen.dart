import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

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
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: '수정',
                onPressed: () => context.push('/add', extra: book),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.red),
                tooltip: '삭제',
                onPressed: () => _confirmDelete(context),
              ),
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

                ..._infoRows(book),

                if ((book.review ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '메모',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(book.review!, style: const TextStyle(color: AppColors.cream, height: 1.6)),
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

  List<Widget> _infoRows(Book b) {
    final pairs = <(String, String?)>[
      ('출판사',   b.publisher),
      ('출판연도', b.year),
      ('장르',    b.genre),
      ('책장 위치', b.location),
      ('ISBN',   b.isbn),
      ('총 페이지', b.pageCount?.toString()),
      ('청구기호', b.callNumber),
      ('매체',   b.medium == 'paper' ? '종이책'
               : b.medium == 'ebook' ? '전자책'
               : b.medium == 'audio' ? '오디오북'
               : b.medium),
    ];
    return pairs
        .where((p) => p.$2 != null && p.$2!.isNotEmpty)
        .map((p) => _InfoRow(label: p.$1, value: p.$2!))
        .toList();
  }

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
              book.copyWith(status: newStatus),
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
