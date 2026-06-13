import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class BookListScreen extends ConsumerWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 서재'),
        actions: [
          // TODO: 검증용 임시 버튼들 — 5c-2 검증 후 제거.
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Remote vs Local 비교 (테스트)',
            onPressed: () async {
              await ref.read(bookRepositoryProvider).debugDumpRemoteVsLocal();
            },
          ),
          IconButton(
            icon: const Icon(Icons.storage_outlined),
            tooltip: '큐 상태 (테스트)',
            onPressed: () async {
              await ref.read(bookRepositoryProvider).debugDumpQueue();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: '큐 초기화 (테스트)',
            onPressed: () async {
              await ref.read(bookRepositoryProvider).clearSyncQueue();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: '로컬 전용 책 추가 (테스트)',
            onPressed: () async {
              await ref.read(bookRepositoryProvider).addLocalOnlyBook();
              ref.invalidate(booksProvider);
            },
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
                children: const [
                  SizedBox(height: 160),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.menu_book_outlined, size: 56, color: AppColors.dim),
                        SizedBox(height: 16),
                        Text(
                          '책이 없습니다',
                          style: TextStyle(color: AppColors.muted, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '위에서 당겨 동기화하거나 + 버튼으로 추가하세요',
                          style: TextStyle(color: AppColors.dim, fontSize: 13),
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

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
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
                    _StatusBadge(status: book.status),
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
    final owned = status == 'owned';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: owned ? AppColors.goldSubtle : AppColors.mutedSubtle,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: owned ? AppColors.gold : AppColors.muted,
          width: 0.5,
        ),
      ),
      child: Text(
        owned ? '소장' : '희망',
        style: TextStyle(
          color: owned ? AppColors.gold : AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
