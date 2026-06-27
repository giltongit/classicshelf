import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'book_filter_sheet.dart';

class BookListScreen extends ConsumerWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(filteredBooksProvider);
    final filter = ref.watch(bookFilterProvider);

    void openFilterSheet() {
      final allLocations = (ref.read(booksProvider).value ?? [])
          .map((b) => b.location)
          .whereType<String>()
          .where((l) => l.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => BookFilterSheet(
          current: ref.read(bookFilterProvider),
          allLocations: allLocations,
          onApply: (f) => ref.read(bookFilterProvider.notifier).update(f),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 도서관'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: '바코드 스캔',
            onPressed: () => context.push('/scan'),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: '필터',
                onPressed: openFilterSheet,
              ),
              if (filter.activeCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppColors.gold,
                    child: Text(
                      '${filter.activeCount}',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.bg),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '책 추가',
            onPressed: () => context.push('/add'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.gold,
        backgroundColor: AppColors.surface2,
        onRefresh: () async {
          await ref.read(bookRepositoryProvider).syncFromRemote();
          ref.invalidate(booksProvider);
          try {
            await ref.read(booksProvider.future);
          } catch (_) {}
        },
        child: booksAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 200),
              Center(
                child: Text(
                  '불러오기 실패: $e',
                  style: const TextStyle(color: AppColors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          data: (books) {
            if (books.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 160),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          filter.isEmpty
                              ? Icons.menu_book_outlined
                              : Icons.search_off_rounded,
                          size: 56,
                          color: AppColors.dim,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          filter.isEmpty
                              ? '책이 없습니다'
                              : '필터 조건에 맞는 책이 없습니다',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (filter.isEmpty)
                          const Text(
                            '위에서 당겨 동기화하거나 + 버튼으로 추가하세요',
                            style: TextStyle(
                                color: AppColors.dim, fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: books.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, i) => _BookCard(book: books[i]),
            );
          },
        ),
      ),
    );
  }
}

class _BookCard extends ConsumerWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.push('/books/${book.localId}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _CoverThumb(coverUrl: book.coverUrl, title: book.title),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      book.author,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StatusBadge(status: book.status),
                            if (book.location?.isNotEmpty == true) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.bookmarks_outlined,
                                  size: 12, color: AppColors.muted),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 100),
                                child: Text(
                                  book.location!,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.muted),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(
                          width: 40,
                          height: 26,
                          child: Transform.scale(
                            scale: 0.65,
                            alignment: Alignment.centerRight,
                            child: Switch(
                              value: book.priorityRead,
                              onChanged: (_) async {
                                await ref
                                    .read(bookRepositoryProvider)
                                    .togglePriorityRead(book.localId!);
                                ref.invalidate(booksProvider);
                              },
                              activeThumbColor: AppColors.gold,
                              activeTrackColor:
                                  AppColors.gold.withValues(alpha: 0.3),
                              inactiveThumbColor: AppColors.muted,
                              inactiveTrackColor:
                                  AppColors.muted.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.dim, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final String? coverUrl;
  final String title;
  const _CoverThumb({required this.coverUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 52,
        height: 72,
        child: _buildCoverChild(coverUrl, title),
      ),
    );
  }

  Widget _buildCoverChild(String? url, String title) {
    if (url == null) return _placeholder(title);
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(title),
        errorWidget: (_, _, _) => _placeholder(title),
      );
    }
    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(title),
    );
  }

  Widget _placeholder(String title) {
    final ch = title.isNotEmpty ? title[0] : '?';
    return Container(
      color: AppColors.surface3,
      alignment: Alignment.center,
      child: Text(
        ch,
        style: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      'owned'    => ('소장', AppColors.gold,  AppColors.goldSubtle),
      'wishlist' => ('희망', AppColors.muted, AppColors.mutedSubtle),
      'rental'   => ('대여', const Color(0xFF5B7FA6), const Color(0x265B7FA6)),
      _          => ('기타', AppColors.muted, AppColors.mutedSubtle),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
