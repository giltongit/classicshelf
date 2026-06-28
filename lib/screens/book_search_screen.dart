import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../models/book_search_result.dart';
import '../providers/providers.dart';
import '../services/book_search_service.dart';
import '../theme/app_theme.dart';

class BookSearchScreen extends ConsumerStatefulWidget {
  const BookSearchScreen({super.key});

  @override
  ConsumerState<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends ConsumerState<BookSearchScreen> {
  final _searchController = TextEditingController();
  List<BookSearchResult> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchBooks() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });
    try {
      final results = await BookSearchService().search(query);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppColors.cream),
          decoration: InputDecoration(
            hintText: '제목, 저자, ISBN...',
            hintStyle: const TextStyle(color: AppColors.muted),
            border: InputBorder.none,
            suffixIcon: ValueListenableBuilder(
              valueListenable: _searchController,
              builder: (_, v, _) => v.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.muted),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _results = []);
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _searchBooks(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.gold));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 12),
            TextButton(onPressed: _searchBooks, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text(
          '제목, 저자, ISBN으로 검색하세요',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: AppColors.dim.withValues(alpha: 0.5)),
      itemBuilder: (context, i) => _BookResultCard(result: _results[i]),
    );
  }
}

// ── _BookResultCard ─────────────────────────────────────────────────────────────

class _BookResultCard extends StatelessWidget {
  final BookSearchResult result;
  const _BookResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _CoverThumbnail(url: result.thumbnailUrl, width: 40, height: 56),
      title: Text(
        result.title,
        style: const TextStyle(color: AppColors.cream, fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [result.authors.join(', '), result.publisher ?? '']
            .where((s) => s.isNotEmpty)
            .join(' · '),
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _showDetailSheet(context),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => _BookDetailSheet(
          result: result,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

// ── _BookDetailSheet ────────────────────────────────────────────────────────────

class _BookDetailSheet extends ConsumerStatefulWidget {
  final BookSearchResult result;
  final ScrollController scrollController;

  const _BookDetailSheet({
    required this.result,
    required this.scrollController,
  });

  @override
  ConsumerState<_BookDetailSheet> createState() => _BookDetailSheetState();
}

class _BookDetailSheetState extends ConsumerState<_BookDetailSheet> {
  bool _descExpanded = false;
  bool _saving = false;
  String? _savedStatus;

  BookSearchResult get result => widget.result;

  Future<void> _saveBook(String status) async {
    final books = ref.read(booksProvider).asData?.value ?? [];
    final isDuplicate = books.any((b) =>
        (result.isbn13 != null &&
            result.isbn13!.isNotEmpty &&
            b.isbn == result.isbn13) ||
        (result.isbn10 != null &&
            result.isbn10!.isNotEmpty &&
            b.isbn == result.isbn10) ||
        (result.isbn13 == null &&
            result.isbn10 == null &&
            b.title == result.title &&
            b.author == result.authors.join(', ')));

    if (isDuplicate) {
      if (mounted) {
        setState(() => _savedStatus = books
            .firstWhere((b) =>
                (result.isbn13 != null && b.isbn == result.isbn13) ||
                (result.isbn10 != null && b.isbn == result.isbn10) ||
                (b.title == result.title))
            .status);
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(bookRepositoryProvider);
      final userId =
          ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';
      final r = result;

      await repo.addBook(Book(
        userId:      userId,
        title:       r.title,
        author:      r.authors.join(', '),
        isbn:        r.isbn13 ?? r.isbn10,
        coverUrl:    r.thumbnailUrl,
        description: r.description,
        status:      status,
        publisher:   r.publisher,
        year:        r.year,
        genre:       r.genre,
        medium:      'paper',
      ));

      ref.invalidate(booksProvider);
      if (mounted) setState(() { _saving = false; _savedStatus = status; });
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isbn = result.isbn13 ?? result.isbn10 ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _handle(),
                _bookInfo(isbn),
                const SizedBox(height: 12),
                if ((result.description?.isNotEmpty ?? false))
                  _descriptionSection(),
                const Divider(color: AppColors.dim),
                const SizedBox(height: 12),
                _actionSection(isbn),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.dim,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _bookInfo(String isbn) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CoverThumbnail(url: result.thumbnailUrl, width: 80, height: 112),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.title,
                style: const TextStyle(
                    color: AppColors.cream,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (result.authors.isNotEmpty)
                Text(
                  result.authors.join(', '),
                  style:
                      const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              if ((result.publisher?.isNotEmpty ?? false) ||
                  (result.publishedDate?.isNotEmpty ?? false))
                Text(
                  [result.publisher ?? '', result.publishedDate ?? '']
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style:
                      const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              if (isbn.isNotEmpty)
                Text(
                  'ISBN $isbn',
                  style: const TextStyle(color: AppColors.dim, fontSize: 11),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _descriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          result.description!,
          style: TextStyle(
            color: AppColors.cream.withValues(alpha: 0.8),
            fontSize: 13,
            height: 1.6,
          ),
          maxLines: _descExpanded ? null : 4,
          overflow:
              _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        TextButton(
          onPressed: () =>
              setState(() => _descExpanded = !_descExpanded),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppColors.gold,
          ),
          child: Text(_descExpanded ? '접기' : '더 보기'),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _actionSection(String isbn) {
    final books = ref.watch(booksProvider).asData?.value ?? [];
    final existing = books.where((b) =>
        (result.isbn13 != null && result.isbn13!.isNotEmpty &&
            b.isbn == result.isbn13) ||
        (result.isbn10 != null && result.isbn10!.isNotEmpty &&
            b.isbn == result.isbn10)).firstOrNull;

    if (_savedStatus != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                '서가에 추가했습니다 · ${_statusLabel(_savedStatus!)}',
                style: const TextStyle(color: AppColors.gold, fontSize: 14),
              ),
            ],
          ),
          if (isbn.isNotEmpty) ...[
            const SizedBox(height: 12),
            _libraryButton(isbn),
          ],
        ],
      );
    }

    if (existing != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이미 서가에 있습니다',
              style: TextStyle(color: AppColors.muted, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            _statusLabel(existing.status),
            style: const TextStyle(color: AppColors.gold, fontSize: 14),
          ),
          if (isbn.isNotEmpty) ...[
            const SizedBox(height: 12),
            _libraryButton(isbn),
          ],
        ],
      );
    }

    return Column(
      children: [
        if (_saving)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.muted,
                    side: const BorderSide(color: AppColors.dim),
                  ),
                  onPressed: () => _saveBook('wishlist'),
                  child: const Text('희망도서로 추가'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.bg,
                  ),
                  onPressed: () => _saveBook('owned'),
                  child: const Text('소장으로 추가'),
                ),
              ),
            ],
          ),
        if (isbn.isNotEmpty) ...[
          const SizedBox(height: 8),
          _libraryButton(isbn),
        ],
      ],
    );
  }

  Widget _libraryButton(String isbn) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        icon: const Icon(Icons.local_library_outlined, size: 16),
        label: const Text('가까운 도서관에서 이 책 찾아보기'),
        style: TextButton.styleFrom(foregroundColor: AppColors.gold),
        onPressed: () {
          final router = GoRouter.of(context);
          Navigator.of(context).pop();
          router.push('/search?isbn=$isbn');
        },
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'owned'    => '소장',
      'wishlist' => '희망도서',
      'rental'   => '대여 중',
      _          => status,
    };
  }
}

// ── _CoverThumbnail ─────────────────────────────────────────────────────────────

class _CoverThumbnail extends StatelessWidget {
  final String? url;
  final double width;
  final double height;

  const _CoverThumbnail(
      {this.url, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Icon(Icons.menu_book_outlined,
              size: 20, color: AppColors.gold),
        ),
      );
}
