import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_background_notifier.dart';
import '../models/book.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Book? _wishlistBook;
  bool _wishlistPicked = false;

  void _tryPickWishlist(List<Book> books) {
    if (_wishlistPicked) return;
    final wishlist = books.where((b) => b.status == 'wishlist').toList();
    if (wishlist.isNotEmpty) {
      _wishlistBook = wishlist[Random().nextInt(wishlist.length)];
      _wishlistPicked = true;
    } else if (books.isNotEmpty) {
      _wishlistPicked = true;
    }
  }

  void _startEditing(String? current) {
    final controller = TextEditingController(text: current ?? '');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('도서관 이름'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(
            hintText: '나의 도서관',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              Navigator.pop(ctx);
              ref.read(libraryNameProvider.notifier).setLibraryName(
                    name.isEmpty ? null : name,
                  );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = switch (ref.watch(booksProvider)) {
      AsyncData(:final value) => value,
      _ => <Book>[],
    };
    final libraryName = switch (ref.watch(libraryNameProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final imagePath = switch (ref.watch(homeBackgroundProvider)) {
      AsyncData(:final value) => value.current,
      _ => null,
    };

    _tryPickWishlist(books);

    // 오늘의 책: 미독 소장본 중 날짜 기반 랜덤
    final unreadOwned =
        books.where((b) => !b.isRead && b.status == 'owned').toList();
    Book? todayBook;
    if (unreadOwned.isNotEmpty) {
      final now = DateTime.now();
      final seed = now.year * 10000 + now.month * 100 + now.day;
      todayBook = unreadOwned[Random(seed).nextInt(unreadOwned.length)];
    }

    // N권 · D일째
    String subtitleText = '${books.length}권';
    if (books.isNotEmpty) {
      final dates =
          books.map((b) => b.createdAt).whereType<DateTime>().toList();
      if (dates.isNotEmpty) {
        final earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
        final days = DateTime.now().difference(earliest).inDays + 1;
        subtitleText += ' · $days일째';
      }
    }

    // 가장 많이 만난 저자 (2권 이상)
    final authorCounts = <String, int>{};
    for (final b in books) {
      final a = b.author.trim();
      if (a.isNotEmpty) authorCounts[a] = (authorCounts[a] ?? 0) + 1;
    }
    String? topAuthor;
    MapEntry<String, int>? best;
    for (final e in authorCounts.entries) {
      if (e.value >= 2 && (best == null || e.value > best.value)) best = e;
    }
    topAuthor = best?.key;

    final readCount = books.where((b) => b.isRead).length;
    final unreadCount = books.length - readCount;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 레이어 1: 배경
          if (imagePath != null)
            Image.file(File(imagePath), fit: BoxFit.cover)
          else
            const ColoredBox(color: AppColors.bg),
          // 레이어 2: 그라디언트 오버레이
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x990F0E0C),
                  Color(0xCC0F0E0C),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // 레이어 3: 콘텐츠
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(libraryName, subtitleText),
                  const SizedBox(height: 28),
                  if (todayBook != null) ...[
                    _TodayBookCard(book: todayBook),
                    const SizedBox(height: 16),
                  ],
                  _SummaryCard(
                    readCount: readCount,
                    unreadCount: unreadCount,
                    topAuthor: topAuthor,
                  ),
                  if (_wishlistBook != null) ...[
                    const SizedBox(height: 16),
                    _WishlistCard(book: _wishlistBook!),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String? libraryName, String subtitleText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: libraryName != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '나의 도서관',
                          style: TextStyle(
                              color: Color(0xFFAA9F8F), fontSize: 12),
                        ),
                        Text(
                          libraryName,
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      '나의 도서관',
                      style: TextStyle(
                          color: Color(0xFFAA9F8F),
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
            ),
            GestureDetector(
              onTap: () => _startEditing(libraryName),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.edit_outlined,
                    size: 16, color: Color(0xFFAA9F8F)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitleText,
          style: const TextStyle(color: Color(0xFFAA9F8F), fontSize: 12),
        ),
      ],
    );
  }
}

// ── 오늘의 책 카드 ─────────────────────────────────────────────────────────────

class _TodayBookCard extends StatelessWidget {
  final Book book;
  const _TodayBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xCC1A1915),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x33C8A96E), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/books/${book.localId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _HomeCoverThumb(coverUrl: book.coverUrl, title: book.title),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘의 책',
                      style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFFAA9F8F), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '오늘 이 책은 어떤가요?',
                      style: TextStyle(
                          color: Color(0xFFAA9F8F), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: AppColors.dim, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 요약 카드 ──────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int readCount;
  final int unreadCount;
  final String? topAuthor;
  const _SummaryCard({
    required this.readCount,
    required this.unreadCount,
    this.topAuthor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xCC1A1915),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x33C8A96E), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '읽음',
                      style: TextStyle(
                          color: Color(0xFFAA9F8F), fontSize: 11),
                    ),
                    Text(
                      '$readCount권',
                      style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '미독',
                      style: TextStyle(
                          color: Color(0xFFAA9F8F), fontSize: 11),
                    ),
                    Text(
                      '$unreadCount권',
                      style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            if (topAuthor != null) ...[
              const SizedBox(height: 10),
              Text(
                '가장 많이 만난 저자  $topAuthor',
                style: const TextStyle(
                    color: Color(0xFFAA9F8F), fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 기다린 지 오래된 책 카드 ───────────────────────────────────────────────────

class _WishlistCard extends StatelessWidget {
  final Book book;
  const _WishlistCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final waitDays =
        DateTime.now().difference(book.createdAt ?? DateTime.now()).inDays + 1;

    return Card(
      color: const Color(0xCC1A1915),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x33C8A96E), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/books/${book.localId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '기다린 지 오래된 책',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _HomeCoverThumb(
                      coverUrl: book.coverUrl, title: book.title),
                  const SizedBox(width: 14),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFFAA9F8F), fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$waitDays일째 기다리는 중',
                          style: const TextStyle(
                              color: Color(0xFFAA9F8F), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: AppColors.dim, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 커버 썸네일 (60×80) ────────────────────────────────────────────────────────

class _HomeCoverThumb extends StatelessWidget {
  final String? coverUrl;
  final String title;
  const _HomeCoverThumb({required this.coverUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 60,
        height: 80,
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    final url = coverUrl;
    if (url == null) return _placeholder();
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }
    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() {
    final ch = title.isNotEmpty ? title[0] : '?';
    return Container(
      color: AppColors.surface3,
      alignment: Alignment.center,
      child: Text(
        ch,
        style: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
    );
  }
}
