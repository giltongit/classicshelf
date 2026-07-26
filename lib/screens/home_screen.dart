import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_background_notifier.dart';
import '../models/album_summary.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(homeBackgroundProvider.notifier).reRandomize();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 홈은 서가 탭의 필터와 무관하게 컬렉션 전체를 집계해야 하므로
    // 무필터 프로바이더를 쓴다(필터 watch하는 albumSummariesProvider는 목록 전용).
    final summaries = switch (ref.watch(allAlbumSummariesProvider)) {
      AsyncData(:final value) => value,
      _ => const <AlbumSummary>[],
    };
    final libraryName = switch (ref.watch(libraryNameProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final imagePath = switch (ref.watch(homeBackgroundProvider)) {
      AsyncData(:final value) => value.current,
      _ => null,
    };

    // 처분한 음반은 홈 화면 전체에서 제외 (결정: disposed 상태 §25)
    final ownedAlbums =
        summaries.where((a) => a.disposedAt == null).toList();

    // 오늘의 음반: 소장 음반 중 날짜 기반 랜덤.
    // book의 '오늘의 책'은 희망도서(status='wishlist')에서 골랐지만
    // AlbumSummary의 상태는 owned/disposed뿐이라 소장분에서 고른다.
    AlbumSummary? todayAlbum;
    if (ownedAlbums.isNotEmpty) {
      final now = DateTime.now();
      final seed = now.year * 10000 + now.month * 100 + now.day;
      todayAlbum = ownedAlbums[Random(seed).nextInt(ownedAlbums.length)];
    }

    final compositionCount =
        ownedAlbums.fold<int>(0, (sum, a) => sum + a.compositionCount);

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
                  _buildHeader(libraryName),
                  const SizedBox(height: 28),
                  if (todayAlbum != null) ...[
                    _TodayAlbumCard(album: todayAlbum),
                    const SizedBox(height: 16),
                  ],
                  _SummaryCard(
                    totalCount: ownedAlbums.length,
                    compositionCount: compositionCount,
                  ),
                  // TODO: 클래식 재작성 (2B)
                  //   book의 '좀 오래 묵은 책' 카드를 제거했다.
                  //   미독(isRead) · 등록일(createdAt) 기준이었는데 AlbumSummary에는
                  //   둘 다 없다. 대체 후보: needsVerification(§6-1) 배지 요약.
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String? libraryName) {
    // 편집 기능은 설정 화면으로 이동. 홈은 표시 전용.
    // 작은 앱 이름 위 + 아래에 사용자가 설정한 컬렉션 이름.
    // TODO: 문안 — '클래식 서가'는 임시 표시명. 확정 시 AndroidManifest의
    //   android:label 과 함께 교체할 것 (pubspec name은 'mylibrary'로 별개 축).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '클래식 서가',
          style: TextStyle(
            color: Color(0xFFAA9F8F),
            fontSize: 12,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        Text(
          libraryName ?? '나의 컬렉션',
          style: const TextStyle(
            color: AppColors.cream,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 오늘의 음반 카드 ───────────────────────────────────────────────────────────

class _TodayAlbumCard extends StatelessWidget {
  final AlbumSummary album;
  const _TodayAlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (album.format != null && album.format!.isNotEmpty) album.format,
      if (album.label != null && album.label!.isNotEmpty) album.label,
      if (album.releaseYear != null) '${album.releaseYear}',
    ].join(' · ');

    return Card(
      color: const Color(0xCC1A1915),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x33C8A96E), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/albums/${album.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _HomeCoverThumb(coverUrl: album.coverUrl, title: album.title),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘의 음반',
                      style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      album.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      album.primaryComposer ?? '작곡가 미상',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFFAA9F8F), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle.isEmpty ? '오늘 이 음반은 어떤가요?' : subtitle,
                      style: const TextStyle(
                          color: Color(0xFFAA9F8F), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.dim, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 요약 카드 ──────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int totalCount;
  final int compositionCount;
  const _SummaryCard({
    required this.totalCount,
    required this.compositionCount,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(
                    color: AppColors.cream,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                children: [
                  const TextSpan(text: '전체 '),
                  TextSpan(
                    text: '$totalCount',
                    style: const TextStyle(color: Color(0xFFD4784A)),
                  ),
                  const TextSpan(text: '장'),
                ],
              ),
            ),
            // book의 '미독 N권'을 대체. AlbumSummary에 청취 여부가 없어
            // 집계 가능한 값 중 수록곡 총합을 쓴다.
            Text(
              '수록곡 $compositionCount곡',
              style: const TextStyle(
                  color: AppColors.gold, fontSize: 15),
            ),
          ],
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
