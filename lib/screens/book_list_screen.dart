// =============================================================================
// book_list_screen.dart — 앨범 목록 "서가" (2B-1 재작성)
//   파일명은 라우팅 참조를 줄이려고 유지, 클래스는 AlbumListScreen.
//
// 구독: albumSummariesProvider (StreamProvider, albumFilterProvider를 watch)
//   → 필터·정렬을 바꾸면 Drift 쿼리가 다시 돌고 스트림이 재방출된다.
//   화면에서 재정렬·재필터하지 않는다 — 그건 리포지토리 책임(§6-3).
//
// 이번 단계 범위: 목록 표시 + 정렬 + 검색어 + reactive 구독.
//   필터 시트(작곡가·시대·포맷·소장상태) UI는 아직 스텁.
// =============================================================================

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/album_filter.dart';
import '../models/album_summary.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

String _sortLabel(AlbumSort sort) => switch (sort) {
      AlbumSort.createdDesc => '등록순',
      AlbumSort.composerAsc => '작곡가순',
      AlbumSort.releaseYearDesc => '발매연도순',
      AlbumSort.titleAsc => '제목순',
    };

class AlbumListScreen extends ConsumerWidget {
  const AlbumListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumSummariesProvider);
    final filter = ref.watch(albumFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: ref.watch(libraryNameProvider).whenOrNull(
                  data: (name) => Text(name ?? '나의 컬렉션'),
                ) ??
            const Text('나의 컬렉션'),
        actions: [
          // TODO: 스캔·검색 (대 2)
          //   2A에서 /scan(바코드) · /book-search(외부 도서 검색) 라우트를 지웠다.
          //   클래식은 EAN-13 바코드 → 음반 메타 조회가 대응 기능이 된다.

          // 정렬 — 실제 동작. sort만 바꾸면 albumSummariesProvider가 재방출된다.
          PopupMenuButton<AlbumSort>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: '정렬',
            color: AppColors.surface2,
            initialValue: filter.sort,
            onSelected: (s) =>
                ref.read(albumFilterProvider.notifier).setSort(s),
            itemBuilder: (_) => AlbumSort.values
                .map(
                  (s) => PopupMenuItem<AlbumSort>(
                    value: s,
                    child: Text(
                      _sortLabel(s),
                      style: TextStyle(
                        color: s == filter.sort
                            ? AppColors.gold
                            : AppColors.cream,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          // TODO: 클래식 필터 시트 (§6-3) — 작곡가 · 시대 · 포맷 · 소장상태
          //   albumFilterProvider에 배선(composer/period/format/status/
          //   onlyNeedsVerification)은 이미 있고 리포지토리도 처리한다.
          //   빠진 건 시트 UI뿐이라, 붙일 때 화면 로직은 건드릴 필요 없다.
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: '필터',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('필터 준비 중 (§6-3, 2B-2 이후)')),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '음반 추가',
            onPressed: () => context.push('/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          const _LocalSearchBar(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.gold,
              backgroundColor: AppColors.surface2,
              // 당겨서 새로고침 = 서버 → 로컬 동기화.
              //   목록 자체는 Drift watch가 반영분을 자동으로 다시 그리므로
              //   여기서 invalidate하지 않는다. 미전송 변경이 있는 앨범은
              //   덮어쓰지 않고 건너뛰며, 그 수를 안내에 함께 보여준다.
              onRefresh: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final r = await ref
                      .read(collectionRepositoryProvider)
                      .syncFromRemote();
                  final pending = r.skippedPending > 0
                      ? ' (미전송 ${r.skippedPending}장은 보류)'
                      : '';
                  messenger.showSnackBar(
                    SnackBar(content: Text('${r.applied}장 동기화됨$pending')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('동기화 실패: $e')),
                  );
                }
              },
              child: albumsAsync.when(
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
                data: (albums) {
                  if (albums.isEmpty) {
                    return _EmptyState(filterIsEmpty: filter.isEmpty);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    itemCount: albums.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, i) =>
                        _AlbumCard(album: albums[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 빈 상태 ────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool filterIsEmpty;
  const _EmptyState({required this.filterIsEmpty});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 160),
        Center(
          child: Column(
            children: [
              Icon(
                filterIsEmpty
                    ? Icons.album_outlined
                    : Icons.search_off_rounded,
                size: 56,
                color: AppColors.dim,
              ),
              const SizedBox(height: 16),
              Text(
                filterIsEmpty ? '등록된 음반이 없습니다' : '조건에 맞는 음반이 없습니다',
                style:
                    const TextStyle(color: AppColors.muted, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (filterIsEmpty) ...[
                // 당겨서 동기화는 위 TODO대로 아직 안내만 띄운다 —
                // 안 되는 걸 권하지 않도록 문안에서 뺐다.
                const Text(
                  '+ 버튼으로 음반을 추가하세요',
                  style: TextStyle(color: AppColors.dim, fontSize: 13),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('음반 등록'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  onPressed: () => context.push('/add'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── 서가 로컬 검색창 ──────────────────────────────────────────────────────────
// AlbumFilter.query → 리포지토리에서 제목 ∪ 작곡가 부분일치로 처리된다.

class _LocalSearchBar extends ConsumerStatefulWidget {
  const _LocalSearchBar();

  @override
  ConsumerState<_LocalSearchBar> createState() => _LocalSearchBarState();
}

class _LocalSearchBarState extends ConsumerState<_LocalSearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _ctrl,
        style: const TextStyle(color: AppColors.cream),
        decoration: InputDecoration(
          hintText: '음반 제목, 작곡가로 검색...',
          hintStyle: const TextStyle(color: AppColors.muted),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.muted),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.muted),
                  onPressed: () {
                    _ctrl.clear();
                    setState(() {});
                    ref.read(albumFilterProvider.notifier).setQuery(null);
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onChanged: (v) {
          setState(() {});
          ref.read(albumFilterProvider.notifier).setQuery(v);
        },
      ),
    );
  }
}

// ── 앨범 카드 ──────────────────────────────────────────────────────────────────

class _AlbumCard extends StatelessWidget {
  final AlbumSummary album;
  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    final isDisposed = album.disposedAt != null;

    final meta = <String>[
      if ((album.format ?? '').isNotEmpty) album.format!,
      if (album.releaseYear != null) '${album.releaseYear}',
      if (album.compositionCount > 0) '${album.compositionCount}곡',
    ].join(' · ');

    return Opacity(
      // 처분한 음반은 목록에 남되 흐리게.
      opacity: isDisposed ? 0.5 : 1.0,
      child: Material(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.push('/albums/${album.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _CoverThumb(coverUrl: album.coverUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.title,
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
                        album.primaryComposer ?? '작곡가 미상',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12),
                      ),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          meta,
                          style: const TextStyle(
                              color: AppColors.dim, fontSize: 11),
                        ),
                      ],
                      if (isDisposed || album.needsVerification) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (isDisposed)
                              const _Chip(
                                label: '처분',
                                fg: AppColors.muted,
                                bg: AppColors.mutedSubtle,
                              ),
                            if (album.needsVerification)
                              const _Chip(
                                label: '확인 필요',
                                fg: AppColors.gold,
                                bg: AppColors.goldSubtle,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.dim, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  const _Chip({required this.label, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
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

// ── 커버 썸네일 (52×72) ────────────────────────────────────────────────────────
// placeholder는 상세(AlbumDetailScreen)와 같은 album_outlined로 통일.

class _CoverThumb extends StatelessWidget {
  final String? coverUrl;
  const _CoverThumb({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 52,
        height: 72,
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    final url = coverUrl;
    if (url == null || url.isEmpty) return _placeholder();
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

  Widget _placeholder() => Container(
        color: AppColors.surface3,
        alignment: Alignment.center,
        child: Icon(Icons.album_outlined,
            size: 24, color: AppColors.gold.withValues(alpha: 0.5)),
      );
}
