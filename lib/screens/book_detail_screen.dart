// =============================================================================
// book_detail_screen.dart — 앨범 상세 (2B-1 재작성)
//   book 시절의 도서 상세를 앨범 애그리게이트 상세로 바꿨다.
//   파일명은 라우팅 참조를 줄이려고 유지하되 클래스는 AlbumDetailScreen.
//
// 표시 구조 = 3단 계층 (§3-1):
//   앨범 → 수록곡(Composition) → 악장(Movement)
//
// 연주자 표시는 "방식 2"(§3-2): 앨범 기본 연주자를 헤더에 한 번만 그리고,
//   수록곡은 override가 있을 때만 그 역할만 곡 아래 덧붙인다.
//   effectivePerformers()로 펼쳐 전부 반복 출력하지 않는다 — 무엇이 상속이고
//   무엇이 예외인지 화면에서 구분되지 않기 때문.
// =============================================================================

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/album.dart';
import '../models/work.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// PerformerRole 한글 라벨 (§3-2)
String _roleLabel(PerformerRole role) => switch (role) {
      PerformerRole.conductor => '지휘',
      PerformerRole.orchestra => '관현악',
      PerformerRole.soloist => '독주',
      PerformerRole.ensemble => '앙상블',
      PerformerRole.vocalist => '성악',
      PerformerRole.unknown => '연주',
    };

String _formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

class AlbumDetailScreen extends ConsumerWidget {
  final String albumId;
  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumAsync = ref.watch(albumDetailProvider(albumId));

    return albumAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.gold)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(
          child: Text('불러오기 실패: $e',
              style: const TextStyle(color: AppColors.red)),
        ),
      ),
      data: (album) {
        if (album == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('음반 정보')),
            body: const Center(
              child: Text('앨범을 찾을 수 없습니다',
                  style: TextStyle(color: AppColors.muted)),
            ),
          );
        }
        return _AlbumDetailBody(album: album);
      },
    );
  }
}

class _AlbumDetailBody extends ConsumerWidget {
  final Album album;
  const _AlbumDetailBody({required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compositions = [...album.compositions]
      ..sort((a, b) => a.seq.compareTo(b.seq));

    // 매칭된 정규 작품(§3-1a 정규명 표시). 로딩·실패는 빈 map으로 흘려보낸다 —
    // 표시를 거들 뿐이라 이것 때문에 상세를 스피너로 막지 않는다.
    final works = ref.watch(albumWorksProvider(album.id)).value ?? const {};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.cream,
            leading: _RoundAction(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 100, 14),
              title: Text(
                album.title,
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
                  _buildCover(album.coverUrl),
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
              // 편집 — 폼이 albumId로 로컬에서 다시 읽어 pre-fill 한다.
              // 저장 후 albumDetailProvider 무효화도 폼이 담당하므로
              // 여기서 돌아왔을 때 수정 결과가 바로 보인다.
              _RoundAction(
                icon: Icons.edit_outlined,
                tooltip: '수정',
                onPressed: () => context.push('/add?albumId=${album.id}'),
              ),
              _RoundAction(
                icon: Icons.delete_outline,
                color: AppColors.red,
                tooltip: '삭제',
                onPressed: () => _confirmDelete(context, ref),
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _MetaLine(album: album),
                const SizedBox(height: 12),
                _StatusRow(album: album),

                // 앨범 기본 연주자 — 수록곡이 상속하는 값. 여기 한 번만 그린다.
                if (album.defaultPerformers.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('연주'),
                  const SizedBox(height: 8),
                  ...album.defaultPerformers.map(
                    (p) => _PerformerLine(performer: p),
                  ),
                ],

                if ((album.location ?? '').isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('보관 위치'),
                  const SizedBox(height: 6),
                  Text(album.location!,
                      style: const TextStyle(color: AppColors.cream)),
                ],

                if ((album.review ?? '').isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('메모'),
                  const SizedBox(height: 6),
                  Text(album.review!,
                      style: const TextStyle(
                          color: AppColors.cream, height: 1.6)),
                ],

                const SizedBox(height: 24),
                const Divider(color: AppColors.dim),
                const SizedBox(height: 16),

                _SectionLabel('수록곡 ${compositions.length}곡'),
                const SizedBox(height: 12),
                if (compositions.isEmpty)
                  const Text('등록된 수록곡이 없습니다',
                      style: TextStyle(color: AppColors.muted, fontSize: 13))
                else
                  // 매칭된 Work는 별도 조회다(애그리게이트 밖의 참조 데이터).
                  // 아직 안 왔거나 실패하면 빈 map → 사용자가 적은 제목으로
                  // 그대로 그린다. 상세가 조인에 의존해 깨지지 않게 한다.
                  ...compositions.map(
                    (c) => _CompositionBlock(
                      composition: c,
                      work: works[c.workId],
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('음반 삭제',
            style: TextStyle(color: AppColors.cream)),
        content: Text(
          '「${album.title}」을(를) 삭제합니다.\n수록곡·악장·연주자 정보도 함께 사라집니다.',
          style: const TextStyle(color: AppColors.muted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소',
                style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // 목록은 Drift watch 기반이라 삭제만 하면 자동 갱신된다(invalidate 불필요).
      await ref.read(collectionRepositoryProvider).deleteAlbum(album.id);
      if (navigator.canPop()) navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
  }

  Widget _buildCover(String? url) {
    if (url == null || url.isEmpty) return _coverPlaceholder();
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => _coverPlaceholder(),
        errorWidget: (_, _, _) => _coverPlaceholder(),
      );
    }
    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _coverPlaceholder(),
    );
  }

  Widget _coverPlaceholder() => Container(
        color: AppColors.surface3,
        alignment: Alignment.center,
        child: Icon(Icons.album_outlined,
            size: 64, color: AppColors.gold.withValues(alpha: 0.4)),
      );
}

// ── 앨범 메타 (레이블 · 발매연도 · 포맷 · 디스크 수) ────────────────────────────

class _MetaLine extends StatelessWidget {
  final Album album;
  const _MetaLine({required this.album});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if ((album.label ?? '').isNotEmpty) album.label!,
      if (album.releaseYear != null) '${album.releaseYear}',
      if ((album.format ?? '').isNotEmpty) album.format!,
      if (album.discCount > 1) '${album.discCount}장 세트',
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join(' · '),
      style: const TextStyle(color: AppColors.gold, fontSize: 15),
    );
  }
}

// ── 소장 상태 + 확인 필요 배지 ─────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final Album album;
  const _StatusRow({required this.album});

  @override
  Widget build(BuildContext context) {
    final disposedAt = album.disposedAt;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (album.status == HoldingStatus.disposed && disposedAt != null)
          _Badge(
            icon: Icons.inventory_2_outlined,
            label:
                '처분됨 · ${disposedAt.year}년 ${disposedAt.month}월 ${disposedAt.day}일',
            color: AppColors.muted,
          )
        else
          const _Badge(
            icon: Icons.check_circle_outline,
            label: '소장 중',
            color: AppColors.muted,
          ),
        if (album.needsVerification)
          const _Badge(
            icon: Icons.help_outline,
            label: '확인 필요',
            color: AppColors.gold,
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

// ── 연주자 한 줄 ("지휘 · 카라얀") ──────────────────────────────────────────────

class _PerformerLine extends StatelessWidget {
  final Performer performer;

  /// 곡별 예외로 그릴 때 들여쓰기·색을 달리한다.
  final bool isOverride;
  const _PerformerLine({required this.performer, this.isOverride = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              _roleLabel(performer.role),
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              performer.name,
              style: TextStyle(
                color: isOverride ? AppColors.gold : AppColors.cream,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 수록곡 블록 (2단) + 악장 (3단) ─────────────────────────────────────────────

/// 수록곡 한 줄의 표시 구성 (§3-1a 표시 우선순위).
///
/// 우선순위:
///   1) 매칭된 Work의 정규명이 있으면 그것이 주 표시.
///   2) 없으면 사용자가 적은 제목.
///   3) 그것도 없으면(구 데이터·미입력) "작곡가 · 작품번호".
///
/// 사용자가 적은 제목은 매칭돼도 **버리지 않는다** — 발췌·편곡판 등 이 음반
/// 고유의 표기가 거기에만 있는 경우가 많다. 정규명과 다를 때만 `albumLabel`로
/// 내려 보존한다(같으면 같은 줄을 두 번 보여줄 이유가 없다).
///
/// `showMeta`는 주 표시가 이미 meta 그 자체인 경우(3번)를 걸러 같은 문자열이
/// 위아래로 겹쳐 보이는 걸 막는다.
typedef CompositionDisplayLines = ({
  String heading,
  String meta,
  String? albumLabel,
  bool showMeta,
});

CompositionDisplayLines compositionDisplayLines({
  required String composer,
  String? catalogNumber,
  String? userTitle,
  String? canonicalTitle,
}) {
  final title = (userTitle ?? '').trim();
  final canonical = (canonicalTitle ?? '').trim();
  final meta = [
    composer,
    if ((catalogNumber ?? '').trim().isNotEmpty) catalogNumber!.trim(),
  ].join(' · ');

  final heading =
      canonical.isNotEmpty ? canonical : (title.isNotEmpty ? title : meta);
  final albumLabel =
      (canonical.isNotEmpty && title.isNotEmpty && title != canonical)
          ? title
          : null;

  return (
    heading: heading,
    meta: meta,
    albumLabel: albumLabel,
    showMeta: meta.isNotEmpty && heading != meta,
  );
}

class _CompositionBlock extends StatelessWidget {
  final Composition composition;

  /// 매칭된 정규 작품. null = 미매칭이거나 참조 데이터를 아직 안 받은 상태.
  final Work? work;

  const _CompositionBlock({required this.composition, this.work});

  @override
  Widget build(BuildContext context) {
    final movements = [...composition.movements]
      ..sort((a, b) => a.seq.compareTo(b.seq));

    // 방식 2: override가 없으면 연주자 줄을 아예 그리지 않는다(헤더 값 상속).
    // 있으면 override에 담긴 역할만 — 상속받는 역할은 여기 다시 쓰지 않는다.
    final overrides = composition.hasPerformerOverride
        ? composition.performerOverrides!
        : const <Performer>[];

    final lines = compositionDisplayLines(
      composer: composition.composer,
      catalogNumber: composition.catalogNumber,
      userTitle: composition.title,
      canonicalTitle: work?.title,
    );
    final heading = lines.heading;
    final meta = lines.meta;
    final albumLabel = lines.albumLabel;
    final showMeta = lines.showMeta;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  heading,
                  style: const TextStyle(
                    color: AppColors.cream,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // 정규 작품과 이어진 곡 — 등록 폼의 "연결됨" 표시와 짝을 이룬다.
              if (work != null)
                const Padding(
                  padding: EdgeInsets.only(left: 6, top: 3),
                  child: Icon(Icons.link, size: 13, color: AppColors.gold),
                ),
              if (composition.confidence == Confidence.unverified)
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 2),
                  child: Icon(Icons.help_outline,
                      size: 14, color: AppColors.gold),
                ),
            ],
          ),

          // 주 표시가 제목류일 때만 작곡가 · 작품번호를 아래에 덧붙인다.
          if (showMeta)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                meta,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),

          // 정규명에 밀렸지만 버리지 않은 음반 고유 표기.
          if (albumLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '음반 표기: $albumLabel',
                style: const TextStyle(color: AppColors.dim, fontSize: 11),
              ),
            ),

          // 곡별 연주자 예외만.
          if (overrides.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: overrides
                    .map((p) =>
                        _PerformerLine(performer: p, isOverride: true))
                    .toList(),
              ),
            ),
          ],

          // 3단: 악장. 없으면 줄 자체를 생략.
          if (movements.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: movements
                    .map((m) => _MovementLine(movement: m))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MovementLine extends StatelessWidget {
  final Movement movement;
  const _MovementLine({required this.movement});

  @override
  Widget build(BuildContext context) {
    final duration = movement.durationSec;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              movement.title,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 12, height: 1.5),
            ),
          ),
          if (duration != null) ...[
            const SizedBox(width: 8),
            Text(
              _formatDuration(duration),
              style: const TextStyle(color: AppColors.dim, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 공용 소품 ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.gold,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// SliverAppBar 위에 얹는 반투명 원형 아이콘 버튼 (커버 위 가독성 확보).
class _RoundAction extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final VoidCallback onPressed;
  const _RoundAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        tooltip: tooltip,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(),
        iconSize: 22,
        onPressed: onPressed,
      ),
    );
  }
}
