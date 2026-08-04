// =============================================================================
// collection_repository_impl.dart — 구현 (WRITE 경로)
//   이 파일은 (A) 인터페이스 + write 경로 범위. flush 디스패치 본체는 다음 차례.
//
// book_repository_impl.dart 에서 계승/변경:
//   · 낙관적 쓰기 패턴(Drift 먼저 → 온라인 Supabase → 실패 큐) 계승.
//   · _enqueue를 entityTable/entityId 기반으로 일반화.
//   · localId↔supabaseId backfill·promote 로직 제거(클라 UUID).
//   · 오프라인 userId 공백 → flush 시 보정하는 패턴은 계승(오프라인 세션 없음 대비).
//   · 저장 단위를 Album 애그리게이트로: 하위는 "replace-children"(판단 1: Album LWW).
// =============================================================================

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/album.dart';
import '../models/album_filter.dart';
import '../models/model_utils.dart';
import '../models/album_summary.dart';
import '../models/wishlist_entry.dart';
import '../database/app_database.dart';
import 'collection_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 동기화 순서 상수 — flush의 FK 정합 (판단: entityTable 우선순위 + 방향 분리)
//   insert/update: 부모 → 자식 (낮은 순위 먼저)
//   delete       : 자식 → 부모 (역순)
//   같은 테이블 내: createdAt asc (SyncQueue.id autoIncrement가 tiebreaker)
// ─────────────────────────────────────────────────────────────────────────────

/// entityTable → 계층 순위. 낮을수록 상위(부모).
/// 오프라인 삽입 시 부모가 먼저 서버에 들어가야 자식 FK가 성립.
const Map<String, int> kEntityOrder = {
  'albums': 0,
  'compositions': 1,
  'movements': 2,
  'album_performers': 1, // 앨범 직속 → compositions와 동급(앨범만 있으면 됨)
  'composition_performers': 2, // 수록곡 직속 → movements와 동급
  'wishlist': 0, // 독립 루트(work/album 참조는 이미 존재 가정)
};

int _entityRank(String table) => kEntityOrder[table] ?? 99;

/// 동기화 작업 종류.
class SyncOp {
  static const insert = 'insert';
  static const update = 'update';
  static const delete = 'delete';

  /// 애그리게이트 하위 통째 교체(판단 1: Album LWW).
  /// payload에 해당 앨범의 전체 하위 스냅샷을 담아 서버가 replace 처리.
  static const replaceChildren = 'replace_children';
}

/// flush 중 세션이 없어 user_id를 보정할 수 없을 때 던진다.
/// _processGroup이 이를 잡아 그룹을 보존·스킵한다(실패로 계수하지 않음).
class _NoSessionUserException implements Exception {}

class CollectionRepositoryImpl implements CollectionRepository {
  final SupabaseClient _supabase;
  final AppDatabase _db;
  final Uuid _uuid;

  CollectionRepositoryImpl({
    required SupabaseClient supabase,
    required AppDatabase db,
    Uuid? uuid,
  })  : _supabase = supabase,
        _db = db,
        _uuid = uuid ?? const Uuid();

  String newId() => _uuid.v4();

  // ===========================================================================
  // 쓰기 — 애그리게이트 저장
  // ===========================================================================

  @override
  Future<Album> saveAlbum(Album album) async {
    final userId = _currentUserId();
    debugPrint('[SAVE] ▶ saveAlbum id=${album.id} title="${album.title}"');

    // ── 1) 로컬 트랜잭션: albums upsert + 하위 replace ──
    // Album 단위 LWW이므로 하위는 개별 diff하지 않고 통째 교체한다.
    await _db.transaction(() async {
      // albums upsert
      await _db.into(_db.albums).insertOnConflictUpdate(
            _albumToCompanion(album, userId),
          );

      // 하위 replace: 기존 삭제 후 재삽입.
      // movements/composition_performers는 compositions FK로 묶이나,
      // 로컬 FK PRAGMA를 끈 상태(스키마 결정)라 cascade가 자동 적용되지 않는다.
      // → 이 앨범에 속한 composition id들을 모아 명시적으로 지운다.
      // 수집은 반드시 compositions 삭제 *전에* — 삭제 후면 기존 id를 못 읽어
      // 이번 편집에서 제거된 수록곡의 하위가 고아로 남는다.
      // (_applyRemoteAlbumToLocal의 하위 replace와 같은 순서)
      final oldCompIds = await _albumCompositionIds(album.id);
      final allCompIds = {
        ...oldCompIds,
        ...album.compositions.map((c) => c.id),
      }.toList();
      if (allCompIds.isNotEmpty) {
        await (_db.delete(_db.movements)
              ..where((t) => t.compositionId.isIn(allCompIds)))
            .go();
        await (_db.delete(_db.compositionPerformers)
              ..where((t) => t.compositionId.isIn(allCompIds)))
            .go();
      }
      await (_db.delete(_db.compositions)
            ..where((t) => t.albumId.equals(album.id)))
          .go();
      await (_db.delete(_db.albumPerformers)
            ..where((t) => t.albumId.equals(album.id)))
          .go();

      // 앨범 기본 연주자 재삽입
      for (final p in album.defaultPerformers) {
        await _db.into(_db.albumPerformers).insert(
              _albumPerformerCompanion(p, album.id, userId),
            );
      }

      // 수록곡 + 악장 + 곡별 연주자 재삽입
      for (final c in album.compositions) {
        await _db.into(_db.compositions).insert(
              _compositionToCompanion(c, album.id, userId),
            );
        for (final m in c.movements) {
          await _db.into(_db.movements).insert(
                _movementToCompanion(m, c.id, userId),
              );
        }
        if (c.hasPerformerOverride) {
          for (final p in c.performerOverrides!) {
            await _db.into(_db.compositionPerformers).insert(
                  _compositionPerformerCompanion(p, c.id, userId),
                );
          }
        }
      }
    });
    debugPrint('[SAVE] Drift 트랜잭션 완료 id=${album.id}');

    // ── 2) 원격 반영 또는 큐 적재 ──
    if (await _isOnline()) {
      try {
        await _pushAlbumToRemote(album, userId);
        debugPrint('[SAVE] ◀ Supabase 반영 성공 id=${album.id}');
        return album;
      } catch (e, st) {
        debugPrint('[SAVE] Supabase 실패 → 큐 적재: $e\n$st');
        await _enqueueAlbum(album, userId);
        return album;
      }
    } else {
      debugPrint('[SAVE] 오프라인 → 큐 적재 id=${album.id}');
      await _enqueueAlbum(album, userId);
      return album;
    }
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    // 로컬 삭제(하위 명시적 cascade — PRAGMA off)
    final compIds = await _albumCompositionIds(albumId);
    await _db.transaction(() async {
      if (compIds.isNotEmpty) {
        await (_db.delete(_db.movements)
              ..where((t) => t.compositionId.isIn(compIds)))
            .go();
        await (_db.delete(_db.compositionPerformers)
              ..where((t) => t.compositionId.isIn(compIds)))
            .go();
      }
      await (_db.delete(_db.compositions)
            ..where((t) => t.albumId.equals(albumId)))
          .go();
      await (_db.delete(_db.albumPerformers)
            ..where((t) => t.albumId.equals(albumId)))
          .go();
      await (_db.delete(_db.albums)..where((t) => t.id.equals(albumId))).go();
    });

    if (await _isOnline()) {
      try {
        // 서버는 FK cascade가 켜져 있으므로 albums 한 번으로 하위까지 삭제됨.
        await _supabase.from('albums').delete().eq('id', albumId);
      } catch (e) {
        debugPrint('[DEL] Supabase 실패 → 큐: $e');
        await _enqueueRaw('albums', albumId, SyncOp.delete,
            jsonEncode({'id': albumId}));
      }
    } else {
      await _enqueueRaw('albums', albumId, SyncOp.delete,
          jsonEncode({'id': albumId}));
    }
  }

  @override
  Future<WishItem> saveWishItem(WishItem item) async {
    if (!item.isValid) {
      throw ArgumentError('WishItem 정합 위반: type=${item.type} '
          'albumId=${item.albumId} workId=${item.workId} '
          'composer=${item.composer} title=${item.title}');
    }
    final userId = _currentUserId();
    await _db.into(_db.wishlist).insertOnConflictUpdate(
          _wishToCompanion(item, userId),
        );

    if (await _isOnline()) {
      try {
        await _supabase.from('wishlist').upsert({
          ...item.toJson(),
          'user_id': userId,
        });
      } catch (e) {
        debugPrint('[WISH] Supabase 실패 → 큐: $e');
        await _enqueueRaw('wishlist', item.id, SyncOp.insert,
            jsonEncode({...item.toJson(), 'user_id': userId}));
      }
    } else {
      await _enqueueRaw('wishlist', item.id, SyncOp.insert,
          jsonEncode({...item.toJson(), 'user_id': userId}));
    }
    return item;
  }

  @override
  Future<void> deleteWishItem(String wishId) async {
    await (_db.delete(_db.wishlist)..where((t) => t.id.equals(wishId))).go();
    if (await _isOnline()) {
      try {
        await _supabase.from('wishlist').delete().eq('id', wishId);
      } catch (e) {
        await _enqueueRaw('wishlist', wishId, SyncOp.delete,
            jsonEncode({'id': wishId}));
      }
    } else {
      await _enqueueRaw('wishlist', wishId, SyncOp.delete,
          jsonEncode({'id': wishId}));
    }
  }

  // ===========================================================================
  // 원격 push 헬퍼 (온라인 저장 경로)
  //   Album LWW: 하위는 서버에서도 통째 replace.
  // ===========================================================================

  Future<void> _pushAlbumToRemote(Album album, String userId) async {
    // albums upsert
    await _supabase.from('albums').upsert({
      ...album.toJson(),
      'user_id': userId,
    });
    // 하위 replace — 온라인/flush 공유 함수.
    await _replaceAlbumChildrenRemote(
      albumId: album.id,
      userId: userId,
      defaultPerformers: album.defaultPerformers,
      compositions: album.compositions,
    );
  }

  /// 앨범 하위(기본 연주자·수록곡·악장·곡별 연주자) 통째 교체.
  ///   온라인 저장(_pushAlbumToRemote)과 flush(replace_children)가 공유한다.
  ///   온라인은 도메인 Album에서 직접, flush는 payload를 도메인으로 되돌려 넣는다.
  ///   서버 기존 하위 삭제 후 재삽입. movements/composition_performers는
  ///   compositions cascade(서버 FK on)로 함께 삭제되므로 명시 삭제하지 않는다.
  Future<void> _replaceAlbumChildrenRemote({
    required String albumId,
    required String userId,
    required List<Performer> defaultPerformers,
    required List<Composition> compositions,
  }) async {
    await _supabase.from('compositions').delete().eq('album_id', albumId);
    await _supabase.from('album_performers').delete().eq('album_id', albumId);

    final compRows = <Map<String, dynamic>>[];
    final moveRows = <Map<String, dynamic>>[];
    final compPerfRows = <Map<String, dynamic>>[];
    for (final c in compositions) {
      compRows.add({...c.toJson(), 'album_id': albumId, 'user_id': userId});
      for (final m in c.movements) {
        moveRows
            .add({...m.toJson(), 'composition_id': c.id, 'user_id': userId});
      }
      if (c.hasPerformerOverride) {
        for (final p in c.performerOverrides!) {
          compPerfRows.add(
              {...p.toJson(), 'composition_id': c.id, 'user_id': userId});
        }
      }
    }
    final albumPerfRows = defaultPerformers
        .map((p) => {...p.toJson(), 'album_id': albumId, 'user_id': userId})
        .toList();

    if (compRows.isNotEmpty) {
      await _supabase.from('compositions').insert(compRows);
    }
    if (moveRows.isNotEmpty) {
      await _supabase.from('movements').insert(moveRows);
    }
    if (albumPerfRows.isNotEmpty) {
      await _supabase.from('album_performers').insert(albumPerfRows);
    }
    if (compPerfRows.isNotEmpty) {
      await _supabase.from('composition_performers').insert(compPerfRows);
    }
  }

  // ===========================================================================
  // 큐 적재 — 일반화된 _enqueue
  //   애그리게이트 저장 시: albums 1건(upsert) + child replace 1건.
  //   개별 행을 20개 쌓지 않는다(판단 1과 일관).
  // ===========================================================================

  Future<void> _enqueueAlbum(Album album, String userId) async {
    // 1) albums 행
    await _enqueueRaw(
      'albums',
      album.id,
      SyncOp.insert, // upsert 의미. flush가 서버 upsert로 처리.
      jsonEncode({...album.toJson(), 'user_id': userId}),
    );
    // 2) 하위 전체 스냅샷(replace-children)
    await _enqueueRaw(
      'compositions', // entityTable은 대표값. flush가 replace_children으로 분기.
      album.id,
      SyncOp.replaceChildren,
      jsonEncode(_childrenSnapshot(album, userId)),
    );
  }

  /// 하위 전체를 payload로 직렬화(서버 replace용).
  Map<String, dynamic> _childrenSnapshot(Album album, String userId) {
    return {
      'album_id': album.id,
      'user_id': userId,
      'album_performers': album.defaultPerformers
          .map((p) => {...p.toJson(), 'album_id': album.id, 'user_id': userId})
          .toList(),
      'compositions': album.compositions.map((c) {
        return {
          ...c.toJson(),
          'album_id': album.id,
          'user_id': userId,
          'movements': c.movements
              .map((m) =>
                  {...m.toJson(), 'composition_id': c.id, 'user_id': userId})
              .toList(),
          'composition_performers': (c.performerOverrides ?? [])
              .map((p) =>
                  {...p.toJson(), 'composition_id': c.id, 'user_id': userId})
              .toList(),
        };
      }).toList(),
    };
  }

  /// 저수준 큐 삽입 — entityTable/entityId/operation/payload.
  Future<void> _enqueueRaw(
    String entityTable,
    String entityId,
    String operation,
    String payload,
  ) async {
    await _db.into(_db.syncQueue).insert(
          SyncQueueCompanion.insert(
            entityTable: entityTable,
            entityId: entityId,
            operation: operation,
            payload: payload,
          ),
        );
    final n = await pendingQueueCount();
    debugPrint('[QUEUE] 적재: $entityTable/$operation id=$entityId (큐 $n건)');
  }

  // ===========================================================================
  // 조회 — (A) 범위에서는 최소 구현. 상세 조립은 read 경로 차례에서 확장.
  // ===========================================================================

  @override
  Future<List<AlbumSummary>> getAlbumSummaries(AlbumFilter f) async {
    // ── 1) albums: SQL로 거를 수 있는 단순 축(status/format) 적용 ──
    final albumQ = _db.select(_db.albums);
    if (f.status == HoldingStatus.owned) {
      albumQ.where((t) => t.disposedAt.isNull());
    } else if (f.status == HoldingStatus.disposed) {
      albumQ.where((t) => t.disposedAt.isNotNull());
    }
    if (f.format != null) {
      albumQ.where((t) => t.format.equals(f.format!));
    }
    final albums = await albumQ.get();
    if (albums.isEmpty) return const [];
    final albumIds = albums.map((a) => a.id).toList();

    // ── 2) 하위 compositions 일괄 조회 (N+1 회피: 앨범 루프 없이 IN 한 번) ──
    final comps = await (_db.select(_db.compositions)
          ..where((t) => t.albumId.isIn(albumIds)))
        .get();
    final compsByAlbum = <String, List<CompositionData>>{};
    for (final c in comps) {
      (compsByAlbum[c.albumId] ??= []).add(c);
    }

    // ── 3) 조인 기반 필터 → 허용 album id 집합 교집합 ──
    Set<String>? allow; // null = 제약 없음
    void narrow(Set<String> s) =>
        allow = allow == null ? s : allow!.intersection(s);

    // composer: 해당 작곡가 곡을 가진 앨범 (로드된 comps로 계산)
    if (f.composer != null) {
      narrow(comps
          .where((c) => c.composer == f.composer)
          .map((c) => c.albumId)
          .toSet());
    }
    // onlyNeedsVerification: unverified 곡 보유 앨범 (§4-5)
    if (f.onlyNeedsVerification) {
      narrow(comps
          .where((c) => c.confidence == 'unverified')
          .map((c) => c.albumId)
          .toSet());
    }
    // period: work 조인(work.period). works 시드가 없으면 매칭 0.
    if (f.period != null) {
      final workIds =
          comps.where((c) => c.workId != null).map((c) => c.workId!).toSet();
      if (workIds.isEmpty) {
        narrow(<String>{});
      } else {
        final works = await (_db.select(_db.works)
              ..where((t) =>
                  t.id.isIn(workIds.toList()) & t.period.equals(f.period!)))
            .get();
        final okWorks = works.map((w) => w.id).toSet();
        narrow(comps
            .where((c) => c.workId != null && okWorks.contains(c.workId))
            .map((c) => c.albumId)
            .toSet());
      }
    }
    // conductor: album_performers ∪ composition_performers (role='conductor')
    if (f.conductor != null) {
      final apRows = await (_db.select(_db.albumPerformers)
            ..where((t) =>
                t.albumId.isIn(albumIds) &
                t.role.equals('conductor') &
                t.name.equals(f.conductor!)))
          .get();
      final apAlbums = apRows.map((r) => r.albumId).toSet();

      final compIds = comps.map((c) => c.id).toList();
      final cpRows = compIds.isEmpty
          ? const <CompositionPerformerData>[]
          : await (_db.select(_db.compositionPerformers)
                ..where((t) =>
                    t.compositionId.isIn(compIds) &
                    t.role.equals('conductor') &
                    t.name.equals(f.conductor!)))
              .get();
      final compToAlbum = {for (final c in comps) c.id: c.albumId};
      final cpAlbums = cpRows
          .map((r) => compToAlbum[r.compositionId])
          .whereType<String>()
          .toSet();
      narrow({...apAlbums, ...cpAlbums});
    }
    // query: title ∪ composer 부분일치(OR). // TODO: FTS5 trigram (대 1-E)
    if (f.query != null && f.query!.trim().isNotEmpty) {
      final ql = f.query!.trim().toLowerCase();
      final titleHits = albums
          .where((a) => a.title.toLowerCase().contains(ql))
          .map((a) => a.id);
      final composerHits = comps
          .where((c) => c.composer.toLowerCase().contains(ql))
          .map((c) => c.albumId);
      narrow({...titleHits, ...composerHits});
    }

    // ── 4) 필터 적용 ──
    final filtered =
        albums.where((a) => allow == null || allow!.contains(a.id)).toList();

    // ── 5) 정렬 ──
    _sortAlbumData(filtered, compsByAlbum, f.sort);

    // ── 6) AlbumSummary 조립 (집계는 compsByAlbum에서) ──
    return filtered.map((a) {
      final cs = compsByAlbum[a.id] ?? const <CompositionData>[];
      return AlbumSummary(
        id: a.id,
        title: a.title,
        label: a.label,
        releaseYear: a.releaseYear,
        format: a.format,
        coverUrl: a.coverUrl,
        disposedAt: a.disposedAt,
        primaryComposer: _primaryComposer(cs),
        compositionCount: cs.length,
        needsVerification: cs.any((c) => c.confidence == 'unverified'),
      );
    }).toList();
  }

  @override
  Future<FilterFacets> getFilterFacets() async {
    // 작곡가 — 수록곡에만 있다.
    final composerQ = _db.selectOnly(_db.compositions)
      ..addColumns([_db.compositions.composer])
      ..groupBy([_db.compositions.composer]);
    final composers = (await composerQ.get())
        .map((r) => r.read(_db.compositions.composer))
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet() // groupBy 이후지만 trim 때문에 다시 겹칠 수 있다
        .toList()
      ..sort();

    // 지휘자 — 앨범 기본값과 곡별 override 두 곳에 흩어져 있다(§3-3). 합집합.
    //   필터 쿼리(getAlbumSummaries)도 두 테이블을 ∪로 보므로 선택지도 같아야 한다.
    final apQ = _db.selectOnly(_db.albumPerformers)
      ..addColumns([_db.albumPerformers.name])
      ..where(_db.albumPerformers.role.equals(PerformerRole.conductor.value))
      ..groupBy([_db.albumPerformers.name]);
    final cpQ = _db.selectOnly(_db.compositionPerformers)
      ..addColumns([_db.compositionPerformers.name])
      ..where(
          _db.compositionPerformers.role.equals(PerformerRole.conductor.value))
      ..groupBy([_db.compositionPerformers.name]);

    final conductors = <String>{
      ...(await apQ.get())
          .map((r) => r.read(_db.albumPerformers.name))
          .whereType<String>(),
      ...(await cpQ.get())
          .map((r) => r.read(_db.compositionPerformers.name))
          .whereType<String>(),
    }.map((s) => s.trim()).where((s) => s.isNotEmpty).toSet().toList()
      ..sort();

    return (composers: composers, conductors: conductors);
  }

  // ===========================================================================
  // 참조 데이터(Works) — 원격 → 로컬 벌크 미러링
  //   §3-6상 캐시라 sync_queue를 타지 않는다(사용자가 고치는 데이터가 아니라
  //   올릴 로컬 변경이 없다). 통째로 받아 upsert하면 끝이고, 실패해도 다음
  //   기동/수동 버튼에서 다시 받으면 된다.
  // ===========================================================================

  /// PostgREST 한 번에 받을 행 수. 서버 기본 상한이 1000이라 그보다 크게 잡아도
  /// 소용없다 — 상한을 넘겨 요청하면 조용히 잘린 결과가 온다(24,760건을 한 번에
  /// 요청하면 1000건만 오고 성공처럼 보인다). 반드시 range로 나눠 받는다.
  static const _worksPageSize = 1000;

  @override
  Future<int> localWorksCount() async {
    final q = _db.selectOnly(_db.works)..addColumns([_db.works.id.count()]);
    return (await q.getSingle()).read(_db.works.id.count()) ?? 0;
  }

  @override
  Future<WorksSyncResult> syncWorksFromRemote() async {
    final workRows = await _fetchAllPaged('works',
        'id,composer,title,catalog_number,musical_key,genre,period,'
        'popular,recommended,source');
    final aliasRows =
        await _fetchAllPaged('work_aliases', 'id,work_id,composer_key,alias,language');

    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.works,
        workRows.map((r) => WorksCompanion(
              id: Value(r['id'] as String),
              composer: Value(r['composer'] as String),
              title: Value(r['title'] as String),
              catalogNumber: Value(r['catalog_number'] as String?),
              musicalKey: Value(r['musical_key'] as String?),
              genre: Value(r['genre'] as String?),
              period: Value(r['period'] as String?),
              popular: Value((r['popular'] as bool?) ?? false),
              recommended: Value((r['recommended'] as bool?) ?? false),
              source: Value((r['source'] as String?) ?? 'openopus'),
            )),
      );
      b.insertAllOnConflictUpdate(
        _db.workAliases,
        aliasRows.map((r) => WorkAliasesCompanion(
              id: Value(r['id'] as String),
              workId: Value(r['work_id'] as String?),
              composerKey: Value(r['composer_key'] as String?),
              alias: Value(r['alias'] as String),
              language: Value(r['language'] as String?),
            )),
      );
    });

    debugPrint('[WORKS] 동기화 완료 — works ${workRows.length}건 / '
        'aliases ${aliasRows.length}건');
    return (works: workRows.length, aliases: aliasRows.length);
  }

  /// range로 끝까지 긁어온다. 마지막 페이지는 요청 크기보다 작게 온다.
  Future<List<Map<String, dynamic>>> _fetchAllPaged(
      String table, String columns) async {
    final out = <Map<String, dynamic>>[];
    var from = 0;
    while (true) {
      final page = await _supabase
          .from(table)
          .select(columns)
          .range(from, from + _worksPageSize - 1);
      out.addAll(page.map((r) => Map<String, dynamic>.from(r)));
      if (page.length < _worksPageSize) break;
      from += _worksPageSize;
    }
    return out;
  }

  @override
  Stream<List<AlbumSummary>> watchAlbumSummaries(AlbumFilter filter) {
    // albums 테이블 변경에 반응. write 경로는 저장 시 트랜잭션에 albums upsert
    // (updatedAt 갱신)를 항상 포함하므로, 하위(수록곡·연주자) 변경도 albums touch를
    // 동반한다 → albums watch만으로 목록이 최신화된다.
    return _db
        .select(_db.albums)
        .watch()
        .asyncMap((_) => getAlbumSummaries(filter));
  }

  @override
  Future<Album?> getAlbum(String albumId) async {
    final a = await (_db.select(_db.albums)..where((t) => t.id.equals(albumId)))
        .getSingleOrNull();
    if (a == null) return null;

    // 기본 연주자(음반 기본값)
    final apRows = await (_db.select(_db.albumPerformers)
          ..where((t) => t.albumId.equals(albumId)))
        .get();
    final defaultPerformers = apRows
        .map((r) => Performer(
            id: r.id, role: PerformerRole.fromString(r.role), name: r.name))
        .toList();

    // 수록곡 (seq 순)
    final compRows = await (_db.select(_db.compositions)
          ..where((t) => t.albumId.equals(albumId))
          ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
        .get();
    final compIds = compRows.map((c) => c.id).toList();

    // 악장 일괄 (seq 순) — N+1 회피
    final moveRows = compIds.isEmpty
        ? const <MovementData>[]
        : await (_db.select(_db.movements)
              ..where((t) => t.compositionId.isIn(compIds))
              ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
            .get();
    final movesByComp = <String, List<Movement>>{};
    for (final m in moveRows) {
      (movesByComp[m.compositionId] ??= []).add(Movement(
        id: m.id,
        seq: m.seq,
        title: m.title,
        trackNo: m.trackNo,
        durationSec: m.durationSec,
      ));
    }

    // 곡별 연주자 일괄 — 행이 있는 곡만 map에 등장(없으면 부재 → null 조립).
    final cpRows = compIds.isEmpty
        ? const <CompositionPerformerData>[]
        : await (_db.select(_db.compositionPerformers)
              ..where((t) => t.compositionId.isIn(compIds)))
            .get();
    final overridesByComp = <String, List<Performer>>{};
    for (final p in cpRows) {
      (overridesByComp[p.compositionId] ??= []).add(Performer(
        id: p.id,
        role: PerformerRole.fromString(p.role),
        name: p.name,
      ));
    }

    final compositions = compRows
        .map((c) => Composition(
              id: c.id,
              workId: c.workId,
              title: c.title,
              composer: c.composer,
              catalogNumber: c.catalogNumber,
              discNo: c.discNo,
              trackFrom: c.trackFrom,
              trackTo: c.trackTo,
              seq: c.seq,
              confidence: Confidence.fromString(c.confidence),
              movements: movesByComp[c.id] ?? const [],
              // 결정적 원칙(상속 미전개): composition_performers 행이 없으면
              // null(=상속)로 둔다. 앨범 기본값을 여기서 복사해 채우지 않는다.
              // 상속 계산은 화면이 effectivePerformers로 도메인에서 수행 →
              // null(상속)과 명시 override 구분이 재저장까지 보존된다.
              performerOverrides: overridesByComp[c.id],
            ))
        .toList();

    return Album(
      id: a.id,
      title: a.title,
      label: a.label,
      releaseYear: a.releaseYear,
      discCount: a.discCount,
      format: a.format,
      barcode: a.barcode,
      coverUrl: a.coverUrl,
      location: a.location,
      review: a.review,
      acquiredAt: a.acquiredAt,
      disposedAt: a.disposedAt,
      defaultPerformers: defaultPerformers,
      compositions: compositions,
    );
  }

  // ── read 헬퍼 ──
  /// 대표 작곡가 = seq 최소 수록곡의 composer. 비면 null.
  String? _primaryComposer(List<CompositionData> cs) {
    if (cs.isEmpty) return null;
    var min = cs.first;
    for (final c in cs) {
      if (c.seq < min.seq) min = c;
    }
    return min.composer;
  }

  void _sortAlbumData(
    List<AlbumData> albums,
    Map<String, List<CompositionData>> compsByAlbum,
    AlbumSort sort,
  ) {
    switch (sort) {
      case AlbumSort.createdDesc:
        albums.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case AlbumSort.composerAsc:
        albums.sort((a, b) {
          final ca =
              _primaryComposer(compsByAlbum[a.id] ?? const []) ?? '￿';
          final cb =
              _primaryComposer(compsByAlbum[b.id] ?? const []) ?? '￿';
          return ca.toLowerCase().compareTo(cb.toLowerCase());
        });
      case AlbumSort.releaseYearDesc:
        albums
            .sort((a, b) => (b.releaseYear ?? -1).compareTo(a.releaseYear ?? -1));
      case AlbumSort.titleAsc:
        albums.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
  }

  /// 등록순(최신 위). 정렬을 쿼리에 두어 조회·구독 양쪽이 같은 순서를 낸다.
  SimpleSelectStatement<$WishlistTable, WishlistData> _wishlistQuery() =>
      _db.select(_db.wishlist)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

  WishItem _wishFromRow(WishlistData r) => WishItem(
        id: r.id,
        type: WishType.fromString(r.type),
        albumId: r.albumId,
        workId: r.workId,
        composer: r.composer,
        title: r.title,
        priority: r.priority,
        note: r.note,
        createdAt: r.createdAt,
      );

  @override
  Future<List<WishItem>> getWishlist() async {
    final rows = await _wishlistQuery().get();
    return rows.map(_wishFromRow).toList();
  }

  @override
  Stream<List<WishItem>> watchWishlist() =>
      _wishlistQuery().watch().map((rows) => rows.map(_wishFromRow).toList());

  // ===========================================================================
  // flush / 원격 동기화 — (A) 범위 밖. 다음 단계에서 구현.
  // ===========================================================================

  @override
  Future<FlushResult> flushSyncQueue() async {
    final rows = await (_db.select(_db.syncQueue)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    final totalItems = rows.length;
    if (rows.isEmpty) {
      debugPrint('[QUEUE] flush: 0건');
      return (totalItems: 0, succeeded: 0, dnsFailures: 0);
    }
    debugPrint('[QUEUE] flush 시작: $totalItems건');

    var dnsFailures = 0;

    // 방향 분리 — 업서트(부모→자식)와 삭제(자식→부모)를 별도 패스로.
    final upserts = rows.where((r) => r.operation != SyncOp.delete).toList();
    final deletes = rows.where((r) => r.operation == SyncOp.delete).toList();

    // Pass 1: 업서트 — entityId 그룹, 그룹/그룹내 rank 오름차순.
    final upsertGroups = _groupByEntity(upserts);
    _sortGroups(upsertGroups, ascending: true);
    for (final group in upsertGroups) {
      dnsFailures += await _processGroup(group, ascending: true);
    }

    // Pass 2: 삭제 — entityId 그룹, rank 내림차순(자식 먼저).
    final deleteGroups = _groupByEntity(deletes);
    _sortGroups(deleteGroups, ascending: false);
    for (final group in deleteGroups) {
      dnsFailures += await _processGroup(group, ascending: false);
    }

    final remaining = await pendingQueueCount();
    final succeeded = totalItems - remaining;
    debugPrint('[QUEUE] flush 완료: 성공 $succeeded / 남음 $remaining / DNS $dnsFailures');
    return (
      totalItems: totalItems,
      succeeded: succeeded,
      dnsFailures: dnsFailures,
    );
  }

  // ── flush 내부 ─────────────────────────────────────────────────────────────

  /// entityId 기준 그룹핑. 삽입 순서(id asc) 보존.
  List<List<SyncQueueData>> _groupByEntity(List<SyncQueueData> items) {
    final map = <String, List<SyncQueueData>>{};
    for (final it in items) {
      (map[it.entityId] ??= []).add(it);
    }
    return map.values.toList();
  }

  int _groupMinRank(List<SyncQueueData> g) => g
      .map((e) => _entityRank(e.entityTable))
      .reduce((a, b) => a < b ? a : b);

  int _groupMaxRank(List<SyncQueueData> g) => g
      .map((e) => _entityRank(e.entityTable))
      .reduce((a, b) => a > b ? a : b);

  /// 그룹 간 정렬. 업서트는 min rank 오름차순(부모 먼저),
  /// 삭제는 max rank 내림차순(자식 먼저). 동순위는 첫 id로 안정화.
  void _sortGroups(List<List<SyncQueueData>> groups, {required bool ascending}) {
    groups.sort((a, b) {
      final int c;
      if (ascending) {
        c = _groupMinRank(a).compareTo(_groupMinRank(b));
      } else {
        c = _groupMaxRank(b).compareTo(_groupMaxRank(a));
      }
      if (c != 0) return c;
      return a.first.id.compareTo(b.first.id);
    });
  }

  /// 그룹(동일 entityId) 처리. 결정 2: 하나라도 실패하면 그룹 전체 보존(무삭제),
  /// 전부 성공해야 그룹의 큐 항목을 삭제. 반환: DNS 실패면 1, 아니면 0.
  ///
  /// 모든 작업이 멱등(upsert / delete-then-insert / PATCH / delete)이라,
  /// 부분 성공 후 보존→재시도해도 서버 상태가 어긋나지 않는다.
  Future<int> _processGroup(
    List<SyncQueueData> group, {
    required bool ascending,
  }) async {
    // 그룹 내부 rank 정렬 (동순위는 id로 안정화).
    final items = [...group]..sort((a, b) {
        final ra = _entityRank(a.entityTable);
        final rb = _entityRank(b.entityTable);
        final c = ascending ? ra.compareTo(rb) : rb.compareTo(ra);
        if (c != 0) return c;
        return ascending ? a.id.compareTo(b.id) : b.id.compareTo(a.id);
      });

    try {
      for (final item in items) {
        await _applyQueueItem(item);
      }
      for (final item in items) {
        await _deleteQueueItem(item.id);
      }
      return 0;
    } on _NoSessionUserException {
      debugPrint('[QUEUE] user_id 미해결(미로그인) → 그룹 보존·스킵 '
          'entityId=${group.first.entityId}');
      return 0;
    } catch (e, st) {
      debugPrint('[QUEUE] 그룹 실패(보존) entityId=${group.first.entityId}: $e\n$st');
      return _isDnsError(e) ? 1 : 0;
    }
  }

  /// 큐 항목 1건을 operation별로 서버에 반영.
  Future<void> _applyQueueItem(SyncQueueData item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    switch (item.operation) {
      case SyncOp.insert: // 클라 UUID → upsert(충돌 시 update)
        await _supabase.from(item.entityTable).upsert({
          ...payload,
          'user_id': _requireUserId(payload),
        });
      case SyncOp.update:
        final patch = Map<String, dynamic>.from(payload)..remove('id');
        if (patch.isNotEmpty) {
          await _supabase
              .from(item.entityTable)
              .update(patch)
              .eq('id', item.entityId);
        }
      case SyncOp.replaceChildren:
        final userId = _requireUserId(payload);
        final parsed = _parseChildrenSnapshot(payload);
        await _replaceAlbumChildrenRemote(
          albumId: parsed.albumId,
          userId: userId,
          defaultPerformers: parsed.defaultPerformers,
          compositions: parsed.compositions,
        );
      case SyncOp.delete:
        final id = (payload['id'] as String?) ?? item.entityId;
        // 서버 FK cascade가 하위를 함께 삭제.
        await _supabase.from(item.entityTable).delete().eq('id', id);
      default:
        debugPrint('[QUEUE] 알 수 없는 op: ${item.operation} — 스킵(삭제 대상)');
    }
  }

  /// payload의 user_id가 비어 있으면 현재 세션으로 보정. 세션도 없으면 예외.
  String _requireUserId(Map<String, dynamic> payload) {
    final pid = payload['user_id'] as String?;
    if (pid != null && pid.isNotEmpty) return pid;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) throw _NoSessionUserException();
    return uid;
  }

  /// replace_children payload(_childrenSnapshot 출력)를 도메인 하위로 역직렬화.
  ({
    String albumId,
    String userId,
    List<Performer> defaultPerformers,
    List<Composition> compositions,
  }) _parseChildrenSnapshot(Map<String, dynamic> snap) {
    final albumId = snap['album_id'] as String;
    final userId = (snap['user_id'] as String?) ?? '';
    final defaultPerformers = ((snap['album_performers'] as List?) ?? const [])
        .map((e) => Performer.fromJson(e as Map<String, dynamic>))
        .toList();
    final compositions = ((snap['compositions'] as List?) ?? const []).map((e) {
      final cj = e as Map<String, dynamic>;
      final movements = ((cj['movements'] as List?) ?? const [])
          .map((m) => Movement.fromJson(m as Map<String, dynamic>))
          .toList();
      final overrides = ((cj['composition_performers'] as List?) ?? const [])
          .map((p) => Performer.fromJson(p as Map<String, dynamic>))
          .toList();
      return Composition.fromJson(cj,
          movements: movements, performerOverrides: overrides);
    }).toList();
    return (
      albumId: albumId,
      userId: userId,
      defaultPerformers: defaultPerformers,
      compositions: compositions,
    );
  }

  Future<void> _deleteQueueItem(int id) async {
    await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(id))).go();
  }

  static bool _isDnsError(Object e) {
    final s = e.toString();
    return s.contains('Failed host lookup') ||
        s.contains('No address associated with hostname');
  }

  // ===========================================================================
  // read/sync 경로 — 원격 → 로컬 미러링 + 원격 유실 복원
  //
  //   원칙: 서버 데이터는 로컬에 upsert만 한다. 원격 JSON에서 도메인을 조립해
  //   화면에 바로 주는 경로를 만들지 않는다 — 조립은 getAlbum/getAlbumSummaries
  //   한 곳에 갇혀 있어야 로컬/원격 출처가 같은 결과를 낸다.
  //   충돌 규칙은 write 경로와 동일하게 Album 단위 LWW + replace-children.
  // ===========================================================================

  /// PostgREST 중첩 select — albums + 하위 전체를 한 번에.
  static const String _remoteAlbumSelect =
      '*, album_performers(*), compositions(*, movements(*), '
      'composition_performers(*))';

  /// sync_queue에 올라온 앨범 id 집합 = 미전송 로컬 변경 보호 대상.
  /// entityId는 항상 앨범 id(하위 replace_children 스냅샷도 entityId=album.id).
  /// wishlist는 독립 루트라 앨범 보호와 무관 → 제외.
  Future<Set<String>> _pendingAlbumIds() async {
    final rows = await _db.select(_db.syncQueue).get();
    return rows
        .where((r) => r.entityTable != 'wishlist')
        .map((r) => r.entityId)
        .toSet();
  }

  /// 내 albums + 하위 전체 조회. RLS(user_id = auth.uid())가 이미 걸려 있지만
  /// 의도를 드러내려고 .eq를 명시한다.
  Future<List<Map<String, dynamic>>> _fetchRemoteAlbums(String userId) async {
    final rows = await _supabase
        .from('albums')
        .select(_remoteAlbumSelect)
        .eq('user_id', userId);
    return rows.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  @override
  Future<SyncResult> syncFromRemote() async {
    final userId = _currentUserId();
    if (userId.isEmpty) {
      debugPrint('[SYNC] 세션 없음 → 스킵');
      return (fetched: 0, applied: 0, skippedPending: 0);
    }

    // pending을 원격 조회보다 먼저 읽는다: 조회 중 새로 쌓인 큐 항목은
    // 다음 sync가 잡으면 되지만, 이미 쌓여 있던 항목을 놓치면 덮어쓴다.
    final pending = await _pendingAlbumIds();
    final remote = await _fetchRemoteAlbums(userId);

    var applied = 0;
    var skipped = 0;
    for (final row in remote) {
      final albumId = row['id'] as String?;
      if (albumId == null) continue;
      if (pending.contains(albumId)) {
        // 미전송 로컬 변경 보존 — flush가 서버로 올린 뒤 다음 sync에서 수신된다.
        skipped++;
        continue;
      }
      await _applyRemoteAlbumToLocal(row, userId);
      applied++;
    }

    debugPrint('[SYNC] 수신 ${remote.length}건 / 반영 $applied / '
        '보류 스킵 $skipped');
    return (
      fetched: remote.length,
      applied: applied,
      skippedPending: skipped,
    );
  }

  /// 서버 앨범 1건(하위 포함) → 로컬 upsert + 하위 replace.
  /// saveAlbum의 로컬 트랜잭션과 같은 패턴이며, 입력만 도메인이 아니라
  /// snake_case Map이다(→ 도메인으로 되돌린 뒤 기존 Companion 매퍼 재사용).
  Future<void> _applyRemoteAlbumToLocal(
    Map<String, dynamic> row,
    String fallbackUserId,
  ) async {
    final rowUserId = row['user_id'] as String?;
    final userId =
        (rowUserId != null && rowUserId.isNotEmpty) ? rowUserId : fallbackUserId;
    final album = _albumFromRemoteRow(row);

    await _db.transaction(() async {
      // albums upsert — 서버 타임스탬프를 그대로 보존한다(로컬 now()로 덮지 않음).
      await _db.into(_db.albums).insertOnConflictUpdate(
            _albumToCompanion(
              album,
              userId,
              createdAt: parseDate(row['created_at']),
              updatedAt: parseDate(row['updated_at']),
            ),
          );

      // 하위 replace. 로컬 FK PRAGMA가 꺼져 있어 cascade가 없으므로
      // movements/composition_performers는 composition id로 명시 삭제한다.
      // (삭제된 수록곡의 악장까지 지우려면 compositions 삭제 *전에* 기존 id를 모은다)
      final oldCompIds = await _albumCompositionIds(album.id);
      final allCompIds = {
        ...oldCompIds,
        ...album.compositions.map((c) => c.id),
      }.toList();
      if (allCompIds.isNotEmpty) {
        await (_db.delete(_db.movements)
              ..where((t) => t.compositionId.isIn(allCompIds)))
            .go();
        await (_db.delete(_db.compositionPerformers)
              ..where((t) => t.compositionId.isIn(allCompIds)))
            .go();
      }
      await (_db.delete(_db.compositions)
            ..where((t) => t.albumId.equals(album.id)))
          .go();
      await (_db.delete(_db.albumPerformers)
            ..where((t) => t.albumId.equals(album.id)))
          .go();

      for (final p in album.defaultPerformers) {
        await _db.into(_db.albumPerformers).insert(
              _albumPerformerCompanion(p, album.id, userId),
            );
      }
      for (final c in album.compositions) {
        await _db.into(_db.compositions).insert(
              _compositionToCompanion(c, album.id, userId),
            );
        for (final m in c.movements) {
          await _db.into(_db.movements).insert(
                _movementToCompanion(m, c.id, userId),
              );
        }
        if (c.hasPerformerOverride) {
          for (final p in c.performerOverrides!) {
            await _db.into(_db.compositionPerformers).insert(
                  _compositionPerformerCompanion(p, c.id, userId),
                );
          }
        }
      }
    });
  }

  /// 중첩 select 응답 1행 → 도메인 Album. 로컬 upsert 직전 단계일 뿐,
  /// 이 결과가 화면으로 새어 나가지는 않는다(조립 경로는 getAlbum 하나).
  Album _albumFromRemoteRow(Map<String, dynamic> row) {
    final defaultPerformers = _mapList(row['album_performers'])
        .map(Performer.fromJson)
        .toList();

    final compositions = _mapList(row['compositions']).map((cj) {
      final movements = _mapList(cj['movements']).map(Movement.fromJson).toList()
        ..sort((a, b) => a.seq.compareTo(b.seq));
      final overrideRows = _mapList(cj['composition_performers']);
      return Composition.fromJson(
        cj,
        movements: movements,
        // 행이 없으면 null(=앨범 기본값 상속). 빈 리스트로 만들면 "명시적 override
        // 없음"과 구분이 흐려지므로 null을 유지한다(getAlbum과 동일 규칙).
        performerOverrides: overrideRows.isEmpty
            ? null
            : overrideRows.map(Performer.fromJson).toList(),
      );
    }).toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));

    return Album.assemble(
      albumJson: row,
      defaultPerformers: defaultPerformers,
      compositions: compositions,
    );
  }

  /// 중첩 select의 자식 배열 → `List<Map<String, dynamic>>`.
  List<Map<String, dynamic>> _mapList(dynamic v) {
    if (v is! List) return const [];
    return v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<void> reconcileLocalOnlyToRemote() async {
    final userId = _currentUserId();
    if (userId.isEmpty) {
      debugPrint('[RECONCILE] 세션 없음 → 스킵');
      return;
    }

    final localRows = await _db.select(_db.albums).get();
    final localIds = localRows.map((a) => a.id).toSet();
    if (localIds.isEmpty) return;

    final remoteRows =
        await _supabase.from('albums').select('id').eq('user_id', userId);
    final remoteIds = remoteRows.map((r) => r['id'] as String).toSet();
    final pending = await _pendingAlbumIds();

    // 대상 = 로컬에만 있는 앨범 − 큐에 있는 앨범.
    //   · 서버에 이미 있으면 건드리지 않는다(보수적 — 서버가 최신일 수 있다).
    //   · 큐에 있으면 flush가 올린다(중복 업로드 방지).
    final targets = localIds.difference(remoteIds).difference(pending);
    if (targets.isEmpty) {
      debugPrint('[RECONCILE] 복원 대상 없음 (로컬 ${localIds.length} / '
          '원격 ${remoteIds.length} / 큐 ${pending.length})');
      return;
    }

    var restored = 0;
    for (final id in targets) {
      // 로컬에서 애그리게이트 조립 — 기존 read 경로 재사용.
      final album = await getAlbum(id);
      if (album == null) continue;
      try {
        await _pushAlbumToRemote(album, userId);
        restored++;
      } catch (e) {
        // 1건 실패가 나머지를 막지 않게 한다. 다음 기동에서 다시 시도된다.
        debugPrint('[RECONCILE] 복원 실패 id=$id: $e');
      }
    }
    debugPrint('[RECONCILE] 복원 $restored / 대상 ${targets.length}건');
  }

  @override
  Future<void> updateCoverUrl(String albumId, String storageUrl) async {
    // book의 int.tryParse 분기 없이 항상 uuid. 낙관적 쓰기 재사용.
    final existing = await (_db.select(_db.albums)
          ..where((t) => t.id.equals(albumId)))
        .getSingleOrNull();
    if (existing == null) {
      debugPrint('[COVER] 로컬 앨범 없음 → 스킵 id=$albumId');
      return;
    }
    // 멱등: 이미 원격 URL이면 스킵
    if (existing.coverUrl != null && existing.coverUrl!.startsWith('http')) {
      debugPrint('[COVER] 이미 원격 URL → 스킵 id=$albumId');
      return;
    }
    await (_db.update(_db.albums)..where((t) => t.id.equals(albumId)))
        .write(AlbumsCompanion(
      coverUrl: Value(storageUrl),
      updatedAt: Value(DateTime.now()),
    ));

    if (await _isOnline()) {
      try {
        await _supabase
            .from('albums')
            .update({'cover_url': storageUrl}).eq('id', albumId);
      } catch (e) {
        await _enqueueRaw('albums', albumId, SyncOp.update,
            jsonEncode({'id': albumId, 'cover_url': storageUrl}));
      }
    } else {
      await _enqueueRaw('albums', albumId, SyncOp.update,
          jsonEncode({'id': albumId, 'cover_url': storageUrl}));
    }
  }

  @override
  Future<int> pendingQueueCount() async {
    final rows = await _db.select(_db.syncQueue).get();
    return rows.length;
  }

  // ===========================================================================
  // 내부 헬퍼
  // ===========================================================================

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  /// 오프라인 생성 시 세션이 없을 수 있음(book의 resolvedUserId 패턴 계승).
  /// 빈 문자열이면 flush 시 보정한다.
  String _currentUserId() =>
      _supabase.auth.currentUser?.id ?? '';

  Future<List<String>> _albumCompositionIds(String albumId) async {
    final rows = await (_db.select(_db.compositions)
          ..where((t) => t.albumId.equals(albumId)))
        .get();
    return rows.map((r) => r.id).toList();
  }

  // ── 도메인 → Drift Companion 변환 ──
  // 주의: sync 필드(updatedAt)는 여기서 now()로 갱신(Album LWW 기준).
  //       하위 테이블엔 updatedAt이 없다(스키마상 albums에만 존재).

  /// [createdAt]/[updatedAt]은 원격 미러링 전용 — 서버 타임스탬프를 그대로 옮긴다.
  /// 로컬 쓰기 경로는 넘기지 않으며, 그때 updatedAt은 now()(Album LWW 기준)다.
  /// createdAt 미지정 시 absent → 신규는 DB 기본값, 기존 행은 값 보존.
  AlbumsCompanion _albumToCompanion(
    Album a,
    String userId, {
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AlbumsCompanion(
        id: Value(a.id),
        userId: Value(userId),
        title: Value(a.title),
        label: Value(a.label),
        releaseYear: Value(a.releaseYear),
        discCount: Value(a.discCount),
        format: Value(a.format),
        barcode: Value(a.barcode),
        coverUrl: Value(a.coverUrl),
        location: Value(a.location),
        review: Value(a.review),
        acquiredAt: Value(a.acquiredAt),
        disposedAt: Value(a.disposedAt),
        createdAt:
            createdAt == null ? const Value.absent() : Value(createdAt),
        updatedAt: Value(updatedAt ?? DateTime.now()),
      );

  CompositionsCompanion _compositionToCompanion(
          Composition c, String albumId, String userId) =>
      CompositionsCompanion(
        id: Value(c.id),
        userId: Value(userId),
        albumId: Value(albumId),
        workId: Value(c.workId),
        title: Value(c.title),
        composer: Value(c.composer),
        catalogNumber: Value(c.catalogNumber),
        discNo: Value(c.discNo),
        trackFrom: Value(c.trackFrom),
        trackTo: Value(c.trackTo),
        seq: Value(c.seq),
        confidence: Value(c.confidence.value),
      );

  MovementsCompanion _movementToCompanion(
          Movement m, String compositionId, String userId) =>
      MovementsCompanion(
        id: Value(m.id),
        userId: Value(userId),
        compositionId: Value(compositionId),
        seq: Value(m.seq),
        title: Value(m.title),
        trackNo: Value(m.trackNo),
        durationSec: Value(m.durationSec),
      );

  AlbumPerformersCompanion _albumPerformerCompanion(
          Performer p, String albumId, String userId) =>
      AlbumPerformersCompanion(
        id: Value(p.id),
        userId: Value(userId),
        albumId: Value(albumId),
        role: Value(p.role.value),
        name: Value(p.name),
      );

  CompositionPerformersCompanion _compositionPerformerCompanion(
          Performer p, String compositionId, String userId) =>
      CompositionPerformersCompanion(
        id: Value(p.id),
        userId: Value(userId),
        compositionId: Value(compositionId),
        role: Value(p.role.value),
        name: Value(p.name),
      );

  WishlistCompanion _wishToCompanion(WishItem w, String userId) =>
      WishlistCompanion(
        id: Value(w.id),
        userId: Value(userId),
        type: Value(w.type.value),
        albumId: Value(w.albumId),
        workId: Value(w.workId),
        composer: Value(w.composer),
        title: Value(w.title),
        priority: Value(w.priority),
        note: Value(w.note),
        // createdAt은 넘기지 않는다 — DB 기본값(currentDateAndTime)에 맡긴다.
        // 재저장(upsert) 시에도 Value.absent()라 기존 등록일이 보존된다.
      );
}
