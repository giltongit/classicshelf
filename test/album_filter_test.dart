// =============================================================================
// 필터 축 회귀 테스트 (대 1-E)
//   필터 시트가 만든 AlbumFilter를 리포지토리가 실제로 어떻게 거르는지 고정한다.
//   화면(시트)은 값만 만들고 거르기·정렬은 전부 getAlbumSummaries 책임이므로,
//   회귀가 날 수 있는 곳은 여기다.
//
//   특히 두 가지를 못 박는다:
//     · 조합 필터는 **교집합**이다(합집합이 아니다) — narrow()의 intersection.
//     · 지휘자 facet은 앨범 기본값 ∪ 곡별 override 양쪽에서 모은다(§3-3).
//       필터 쿼리도 두 테이블을 ∪로 보므로 선택지와 검색 범위가 어긋나면 안 된다.
// =============================================================================

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mylibrary/database/app_database.dart';
import 'package:mylibrary/models/album.dart';
import 'package:mylibrary/models/album_filter.dart';
import 'package:mylibrary/repositories/collection_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CollectionRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = CollectionRepositoryImpl(
      supabase: SupabaseClient('http://localhost:54321', 'test-anon-key'),
      db: db,
    );

    /// 로컬 트랜잭션만 검증한다. 이후 원격 단계는 테스트 환경에 connectivity
    /// 플러그인이 없어 예외로 끝나므로 삼킨다(로컬은 이미 커밋됨).
    Future<void> saveLocal(Album a) async {
      try {
        await repo.saveAlbum(a);
      } catch (_) {
        // 원격/큐 단계 실패는 이 테스트의 관심사가 아니다.
      }
    }

    // A: 소장중 · CD · Beethoven · 지휘 Karajan(앨범 기본값) · confirmed
    await saveLocal(Album(
      id: 'A',
      title: 'Symphony No.5',
      format: 'CD',
      defaultPerformers: [
        Performer(id: 'A-p', role: PerformerRole.conductor, name: 'Karajan'),
      ],
      compositions: [
        Composition(
          id: 'A-c',
          composer: 'Beethoven',
          seq: 0,
          confidence: Confidence.confirmed,
        ),
      ],
    ));

    // B: 처분 · LP · Mozart · 지휘 Böhm(곡별 override) · unverified
    await saveLocal(Album(
      id: 'B',
      title: 'Requiem',
      format: 'LP',
      disposedAt: DateTime(2025, 1, 1),
      compositions: [
        Composition(
          id: 'B-c',
          composer: 'Mozart',
          seq: 0,
          confidence: Confidence.unverified,
          performerOverrides: [
            Performer(id: 'B-p', role: PerformerRole.conductor, name: 'Böhm'),
          ],
        ),
      ],
    ));
  });

  tearDown(() async => db.close());

  Future<List<String>> ids(AlbumFilter f) async =>
      (await repo.getAlbumSummaries(f)).map((s) => s.id).toList();

  test('facet: 작곡가·지휘자 distinct (지휘자는 앨범기본 ∪ 곡별override)', () async {
    final f = await repo.getFilterFacets();
    expect(f.composers, ['Beethoven', 'Mozart']);
    // 앨범 기본값(Karajan)과 곡별 override(Böhm)가 모두 잡혀야 한다.
    expect(f.conductors, ['Karajan', 'Böhm']..sort());
  });

  test('축별 단독 필터', () async {
    expect(await ids(AlbumFilter.empty), unorderedEquals(['A', 'B']));
    expect(await ids(const AlbumFilter(status: HoldingStatus.owned)), ['A']);
    expect(await ids(const AlbumFilter(status: HoldingStatus.disposed)), ['B']);
    expect(await ids(const AlbumFilter(format: 'CD')), ['A']);
    expect(await ids(const AlbumFilter(format: 'LP')), ['B']);
    expect(await ids(const AlbumFilter(composer: 'Beethoven')), ['A']);
    expect(await ids(const AlbumFilter(composer: 'Mozart')), ['B']);
    expect(await ids(const AlbumFilter(conductor: 'Karajan')), ['A']);
    expect(await ids(const AlbumFilter(conductor: 'Böhm')), ['B']);
    expect(await ids(const AlbumFilter(onlyNeedsVerification: true)), ['B']);
  });

  test('조합 필터 — 교집합이지 합집합이 아니다', () async {
    expect(
      await ids(const AlbumFilter(
          status: HoldingStatus.owned, composer: 'Beethoven')),
      ['A'],
    );
    // 소장중인 건 A인데 작곡가는 B의 것 → 교집합 없음.
    // 합집합으로 잘못 구현되면 여기서 2건이 나온다.
    expect(
      await ids(
          const AlbumFilter(status: HoldingStatus.owned, composer: 'Mozart')),
      isEmpty,
    );
    expect(
      await ids(const AlbumFilter(format: 'CD', conductor: 'Karajan')),
      ['A'],
    );
  });

  test('검색어와 필터 동시 적용', () async {
    expect(await ids(const AlbumFilter(query: 'symphony')), ['A']);
    // 검색어는 맞지만 필터가 배제 → 0건.
    expect(
      await ids(const AlbumFilter(
          query: 'symphony', status: HoldingStatus.disposed)),
      isEmpty,
    );
    // 검색어는 제목 ∪ 작곡가에 걸린다.
    expect(await ids(const AlbumFilter(query: 'mozart')), ['B']);
  });

  test('activeCount / clearedForSheet — 검색어·정렬 보존', () {
    const f = AlbumFilter(
      query: 'symphony',
      sort: AlbumSort.titleAsc,
      status: HoldingStatus.owned,
      format: 'CD',
      composer: 'Beethoven',
      conductor: 'Karajan',
      onlyNeedsVerification: true,
    );
    // 뱃지는 시트가 다루는 축만 센다 — query·sort는 별도 UI라 제외.
    expect(f.activeCount, 5);

    final cleared = f.clearedForSheet();
    expect(cleared.activeCount, 0);
    expect(cleared.query, 'symphony'); // 검색창과 어긋나지 않게 보존
    expect(cleared.sort, AlbumSort.titleAsc);
  });
}
