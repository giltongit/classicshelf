// =============================================================================
// saveAlbum 하위 replace 회귀 테스트
//   편집으로 수록곡을 제거하면 그 수록곡의 movements/composition_performers도
//   함께 사라져야 한다. 로컬은 FK PRAGMA가 꺼져 있어 cascade가 없으므로,
//   compositions 삭제 *전에* 기존 id를 수집해야만 지울 수 있다.
//   (수집을 삭제 뒤로 두면 항상 빈 리스트가 되어 고아 행이 쌓였다)
// =============================================================================

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mylibrary/database/app_database.dart';
import 'package:mylibrary/models/album.dart';
import 'package:mylibrary/repositories/collection_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CollectionRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CollectionRepositoryImpl(
      supabase: SupabaseClient('http://localhost:54321', 'test-anon-key'),
      db: db,
    );
  });

  tearDown(() async => db.close());

  /// saveAlbum의 로컬 트랜잭션만 검증한다. 이후 원격 단계는 테스트 환경에
  /// connectivity 플러그인이 없어 예외로 끝나므로 삼킨다(로컬은 이미 커밋됨).
  Future<void> saveLocal(Album album) async {
    try {
      await repo.saveAlbum(album);
    } catch (_) {
      // 원격/큐 단계 실패는 이 테스트의 관심사가 아니다.
    }
  }

  Composition comp(String id, {required int seq}) => Composition(
        id: id,
        composer: 'Bach',
        seq: seq,
        movements: [
          Movement(id: '$id-m1', seq: 0, title: '$id Allegro'),
          Movement(id: '$id-m2', seq: 1, title: '$id Adagio'),
        ],
        performerOverrides: [
          Performer(id: '$id-p1', role: PerformerRole.soloist, name: 'Gould'),
        ],
      );

  test('수록곡을 제거하고 저장하면 그 하위(악장·연주자)가 고아로 남지 않는다',
      () async {
    const albumId = 'album-1';

    // ── 1) 수록곡 2개로 저장 ──
    await saveLocal(Album(
      id: albumId,
      title: 'Goldberg',
      compositions: [comp('c-A', seq: 0), comp('c-B', seq: 1)],
    ));

    expect((await db.select(db.compositions).get()).length, 2);
    expect((await db.select(db.movements).get()).length, 4);
    expect((await db.select(db.compositionPerformers).get()).length, 2);

    // ── 2) 수록곡 B를 제거하고 같은 앨범을 다시 저장 ──
    await saveLocal(Album(
      id: albumId,
      title: 'Goldberg',
      compositions: [comp('c-A', seq: 0)],
    ));

    final comps = await db.select(db.compositions).get();
    final moves = await db.select(db.movements).get();
    final perfs = await db.select(db.compositionPerformers).get();

    expect(comps.map((c) => c.id), ['c-A']);
    // 제거된 c-B의 하위가 남아 있으면 실패(수정 전 동작).
    expect(moves.map((m) => m.compositionId).toSet(), {'c-A'});
    expect(moves.length, 2);
    expect(perfs.map((p) => p.compositionId).toSet(), {'c-A'});
    expect(perfs.length, 1);
  });

  test('수록곡을 전부 제거하면 하위가 하나도 남지 않는다', () async {
    const albumId = 'album-2';

    await saveLocal(Album(
      id: albumId,
      title: 'Empty later',
      compositions: [comp('c-X', seq: 0)],
    ));
    expect((await db.select(db.movements).get()).length, 2);

    await saveLocal(const Album(id: albumId, title: 'Empty later'));

    expect(await db.select(db.compositions).get(), isEmpty);
    expect(await db.select(db.movements).get(), isEmpty);
    expect(await db.select(db.compositionPerformers).get(), isEmpty);
  });
}
