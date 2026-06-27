import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../models/book_search_result.dart';
import '../models/library_search_result.dart';
import '../providers/providers.dart';
import '../services/book_search_service.dart';
import '../services/library_search_service.dart';
import '../theme/app_theme.dart';

class UnifiedSearchScreen extends ConsumerStatefulWidget {
  final int initialTab;
  final String? initialIsbn;
  final String? initialQuery;

  const UnifiedSearchScreen({
    super.key,
    this.initialTab = 0,
    this.initialIsbn,
    this.initialQuery,
  });

  @override
  ConsumerState<UnifiedSearchScreen> createState() =>
      _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends ConsumerState<UnifiedSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  List<BookSearchResult> _bookResults = [];
  bool _bookLoading = false;
  String? _bookError;

  List<LibrarySearchResult> _libraryResults = [];
  bool _libraryLoading = false;
  String? _libraryError;
  String? _currentIsbn;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    if (widget.initialIsbn != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _switchToLibraryTab(isbn: widget.initialIsbn!);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchBooks(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _bookLoading = true;
      _bookError = null;
      _bookResults = [];
    });
    try {
      final results = await BookSearchService().search(query.trim());
      if (mounted) {
        setState(() {
          _bookResults = results;
          _bookLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bookError = e.toString();
          _bookLoading = false;
        });
      }
    }
  }

  Future<void> _searchLibraries({required String isbn}) async {
    final clean = isbn.replaceAll(RegExp(r'[\s\-]'), '');
    if (clean.isEmpty) return;
    setState(() {
      _libraryLoading = true;
      _libraryError = null;
      _libraryResults = [];
      _currentIsbn = clean;
    });

    if (_userPosition == null) {
      try {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm != LocationPermission.denied &&
            perm != LocationPermission.deniedForever) {
          _userPosition = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
            ),
          ).timeout(const Duration(seconds: 5));
        }
      } catch (_) {}
    }

    try {
      final results = await LibrarySearchService().searchByIsbn(clean);

      if (_userPosition != null) {
        for (final lib in results) {
          if (lib.lat != null && lib.lng != null) {
            lib.distanceKm = Geolocator.distanceBetween(
              _userPosition!.latitude,
              _userPosition!.longitude,
              lib.lat!,
              lib.lng!,
            ) / 1000;
          }
        }
        results.sort((a, b) {
          if (a.distanceKm == null && b.distanceKm == null) return 0;
          if (a.distanceKm == null) return 1;
          if (b.distanceKm == null) return -1;
          return a.distanceKm!.compareTo(b.distanceKm!);
        });
      }

      if (mounted) {
        setState(() {
          _libraryResults = results;
          _libraryLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _libraryError = e.toString();
          _libraryLoading = false;
        });
      }
    }
  }

  void _switchToLibraryTab({required String isbn}) {
    _tabController.animateTo(1);
    _searchController.text = isbn;
    _searchLibraries(isbn: isbn);
  }

  void _onSearch() {
    final q = _searchController.text.trim();
    if (_tabController.index == 0) {
      _searchBooks(q);
    } else {
      _searchLibraries(isbn: q);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialTab == 0 && widget.initialIsbn == null,
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
                        setState(() {
                          _bookResults = [];
                          _libraryResults = [];
                        });
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _onSearch(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '도서 검색'),
            Tab(text: '도서관 검색'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BookSearchTab(
            results: _bookResults,
            loading: _bookLoading,
            error: _bookError,
            onRetry: () => _searchBooks(_searchController.text),
            onSwitchToLibrary: _switchToLibraryTab,
          ),
          _LibrarySearchTab(
            results: _libraryResults,
            loading: _libraryLoading,
            error: _libraryError,
            onRetry: () => _searchLibraries(isbn: _currentIsbn ?? ''),
          ),
        ],
      ),
    );
  }
}

// ── _BookSearchTab ──────────────────────────────────────────────────────────────

class _BookSearchTab extends StatelessWidget {
  final List<BookSearchResult> results;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final void Function({required String isbn}) onSwitchToLibrary;

  const _BookSearchTab({
    required this.results,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onSwitchToLibrary,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.gold));
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    if (results.isEmpty) {
      return const Center(
        child: Text(
          '제목, 저자, ISBN으로 검색하세요',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: AppColors.dim.withValues(alpha: 0.5)),
      itemBuilder: (context, i) => _BookResultCard(
        result: results[i],
        onSwitchToLibrary: onSwitchToLibrary,
      ),
    );
  }
}

// ── _BookResultCard ─────────────────────────────────────────────────────────────

class _BookResultCard extends StatelessWidget {
  final BookSearchResult result;
  final void Function({required String isbn}) onSwitchToLibrary;

  const _BookResultCard({
    required this.result,
    required this.onSwitchToLibrary,
  });

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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _BookDetailSheet(
        result: result,
        onSwitchToLibrary: onSwitchToLibrary,
      ),
    );
  }
}

// ── _BookDetailSheet ────────────────────────────────────────────────────────────

class _BookDetailSheet extends ConsumerWidget {
  final BookSearchResult result;
  final void Function({required String isbn}) onSwitchToLibrary;

  const _BookDetailSheet({
    required this.result,
    required this.onSwitchToLibrary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider).asData?.value ?? [];
    final isbn = result.isbn13 ?? result.isbn10 ?? '';

    final existing = books.where((b) =>
        (result.isbn13 != null && result.isbn13!.isNotEmpty &&
            b.isbn == result.isbn13) ||
        (result.isbn10 != null && result.isbn10!.isNotEmpty &&
            b.isbn == result.isbn10)).firstOrNull;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.dim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CoverThumbnail(
                    url: result.thumbnailUrl, width: 80, height: 112),
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
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13),
                        ),
                      if ((result.publisher?.isNotEmpty ?? false) ||
                          (result.publishedDate?.isNotEmpty ?? false))
                        Text(
                          [result.publisher ?? '', result.publishedDate ?? '']
                              .where((s) => s.isNotEmpty)
                              .join(' · '),
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12),
                        ),
                      if (isbn.isNotEmpty)
                        Text(
                          'ISBN $isbn',
                          style: const TextStyle(
                              color: AppColors.dim, fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.dim),
            const SizedBox(height: 12),
            if (existing != null) ...[
              const Text('이미 서가에 있습니다',
                  style: TextStyle(color: AppColors.muted, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                _statusLabel(existing.status),
                style: const TextStyle(color: AppColors.gold, fontSize: 14),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.muted,
                        side: const BorderSide(color: AppColors.dim),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/add', extra: {
                          'result': result,
                          'status': 'wishlist',
                        });
                      },
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
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/add', extra: {
                          'result': result,
                          'status': 'owned',
                        });
                      },
                      child: const Text('소장으로 추가'),
                    ),
                  ),
                ],
              ),
              if (isbn.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: const Icon(Icons.local_library_outlined, size: 16),
                    label: const Text('도서관에서 찾기'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.gold),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onSwitchToLibrary(isbn: isbn);
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
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

// ── _LibrarySearchTab ───────────────────────────────────────────────────────────

class _LibrarySearchTab extends StatelessWidget {
  final List<LibrarySearchResult> results;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  const _LibrarySearchTab({
    required this.results,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.gold),
            SizedBox(height: 12),
            Text('도서관을 검색하는 중...',
                style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'ISBN으로 소장 도서관을 찾습니다\n도서 검색 탭에서 [도서관에서 찾기]를 눌러보세요',
            style: TextStyle(color: AppColors.muted, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: AppColors.dim.withValues(alpha: 0.5)),
      itemBuilder: (_, i) => _LibraryResultCard(lib: results[i]),
    );
  }
}

// ── _LibraryResultCard ──────────────────────────────────────────────────────────

class _LibraryResultCard extends StatelessWidget {
  final LibrarySearchResult lib;
  const _LibraryResultCard({required this.lib});

  @override
  Widget build(BuildContext context) {
    final dist = lib.distanceKm;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading:
          const Icon(Icons.local_library_outlined, color: AppColors.gold),
      title: Text(lib.libName,
          style: const TextStyle(color: AppColors.cream, fontSize: 14)),
      subtitle: Text(
        lib.address,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: dist != null
          ? Text(
              dist < 1
                  ? '${(dist * 1000).round()}m'
                  : '${dist.toStringAsFixed(1)}km',
              style:
                  const TextStyle(color: AppColors.muted, fontSize: 12),
            )
          : null,
    );
  }
}

// ── _CoverThumbnail (공용) ──────────────────────────────────────────────────────

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
