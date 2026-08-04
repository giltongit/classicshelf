import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// =============================================================================
// 클래식 음반 컬렉션 앱 — Drift 로컬 스키마 (아키텍처 v03 §3-6)
//   Supabase 마이그레이션 20260725052147_init_classical_schema.sql 의 1:1 미러.
//
// 식별자(§3-5 결정): 사용자 데이터 PK는 클라이언트 생성 UUID(text) 단일 키.
//   로컬·원격 동일 id → 오프라인 생성 시 자식이 부모 uuid를 즉시 참조, 동기화 시
//   id 재매핑 불필요. 서버는 클라이언트 제공 id를 허용(gen_random_uuid는 미지정 시 폴백).
//
// 타입 매핑(§3-5): uuid→TEXT, timestamptz/date→DateTime, jsonb→TEXT.
//
// 캐시 vs 로컬 고유 상태(§3-5):
//   · 캐시    : Works/WorkMovements/WorkAliases/Commentaries,
//               Albums/Compositions/Movements/Performers/Wishlist
//               → 스키마 변경 시 drop & Supabase 재동기화 가능
//   · 로컬 고유: SyncQueue(미전송 편집) → 정식 마이그레이션 필수
//
// FK: .references()는 스키마 문서화용으로 선언하되 SQLite FK 강제(PRAGMA)는 켜지 않는다.
//     무결성의 source of truth는 Supabase이며, 오프라인 삽입 순서 제약을 피한다.
// =============================================================================

// ── 참조 데이터 (캐시 · 읽기전용 시드) ─────────────────────────────────────────

@DataClassName('WorkData')
class Works extends Table {
  TextColumn get id => text()();                          // Open Opus / MusicBrainz id
  TextColumn get composer => text()();
  TextColumn get title => text()();                       // 원어 정규명
  TextColumn get catalogNumber => text().nullable()();    // BWV / K. / Op. (§3-3)
  TextColumn get musicalKey => text().nullable()();       // 조성
  TextColumn get genre => text().nullable()();            // Open Opus genre
  TextColumn get period => text().nullable()();           // 시대
  BoolColumn get popular => boolean().withDefault(const Constant(false))();
  BoolColumn get recommended =>
      boolean().withDefault(const Constant(false))();
  TextColumn get source => text().withDefault(const Constant('openopus'))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkMovementData')
class WorkMovements extends Table {                        // 표준 악장 (§3-1)
  TextColumn get workId => text().references(Works, #id)();
  IntColumn get seq => integer()();                       // 1, 2, 3…
  TextColumn get title => text()();                       // "II. Andante con moto"
  TextColumn get tempoMark => text().nullable()();
  @override
  Set<Column> get primaryKey => {workId, seq};
}

@DataClassName('WorkAliasData')
class WorkAliases extends Table {                          // 표기 변형 (§6-3)
  TextColumn get id => text()();                          // uuid
  TextColumn get workId => text().nullable().references(Works, #id)();
  TextColumn get composerKey => text().nullable()();      // 작곡가 단위 별칭
  TextColumn get alias => text()();
  TextColumn get language => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CommentaryData')
class Commentaries extends Table {                         // AI 해설 캐시 (§7)
  TextColumn get workId => text().references(Works, #id)();
  TextColumn get language => text()();                    // 캐시 키에 언어 필수
  TextColumn get body => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {workId, language};
}

// ── 사용자 컬렉션 ─────────────────────────────────────────────────────────────

@DataClassName('AlbumData')
class Albums extends Table {
  TextColumn get id => text()();                          // 클라이언트 uuid
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get label => text().nullable()();            // 레이블
  IntColumn get releaseYear => integer().nullable()();
  IntColumn get discCount => integer().withDefault(const Constant(1))();
  TextColumn get format => text().nullable()();           // CD / LP / SACD / digital
  TextColumn get barcode => text().nullable()();          // EAN-13 (중복 감지 §4-3)
  TextColumn get coverUrl => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get review => text().nullable()();
  DateTimeColumn get acquiredAt => dateTime().nullable()();
  DateTimeColumn get disposedAt => dateTime().nullable()(); // null=소장중
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CompositionData')
class Compositions extends Table {                         // 수록곡
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get albumId => text().references(Albums, #id)();
  TextColumn get workId =>
      text().nullable().references(Works, #id)();          // 미매칭 허용 (§3-4)
  TextColumn get title => text().nullable()();             // 자유 텍스트 제목
  TextColumn get composer => text()();
  TextColumn get catalogNumber => text().nullable()();
  IntColumn get discNo => integer().nullable()();
  IntColumn get trackFrom => integer().nullable()();
  IntColumn get trackTo => integer().nullable()();
  IntColumn get seq => integer().withDefault(const Constant(0))();
  TextColumn get confidence =>
      text().withDefault(const Constant('unverified'))();  // confirmed / unverified
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MovementData')
class Movements extends Table {                            // 실제 수록 악장 (§3-1)
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get compositionId => text().references(Compositions, #id)();
  IntColumn get seq => integer()();
  TextColumn get title => text()();
  IntColumn get trackNo => integer().nullable()();
  IntColumn get durationSec => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

// 연주자 상속 모델 (§3-2). role: conductor/orchestra/soloist/ensemble/vocalist.
// 음반 기본값 = AlbumPerformers. 곡별 예외 지정분만 CompositionPerformers에 저장.

@DataClassName('AlbumPerformerData')
class AlbumPerformers extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get albumId => text().references(Albums, #id)();
  TextColumn get role => text()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CompositionPerformerData')
class CompositionPerformers extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get compositionId => text().references(Compositions, #id)();
  TextColumn get role => text()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WishlistData')
class Wishlist extends Table {                             // 희망 목록 (§6-2)
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();                        // 'album' | 'work'
  // 확정 연결 — Works 시드(대 1-A)·자동 해소 감지가 붙는 이후 작업에서 채운다.
  // 지금은 보통 null이고, 위시는 아래 composer/title 자유 텍스트로 표현한다.
  TextColumn get albumId => text().nullable().references(Albums, #id)();
  TextColumn get workId => text().nullable().references(Works, #id)();
  // 자유 텍스트 (§3-1a compositions.title 선례와 동일 성격 — FK 없이도 표현 가능)
  TextColumn get composer => text().nullable()();
  TextColumn get title => text().nullable()();           // 작품명 또는 음반명
  IntColumn get priority => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

// ── 로컬 고유 상태 ────────────────────────────────────────────────────────────

/// 오프라인 동기화 큐. 계층 다중 테이블 대응 — entityTable로 대상 테이블을 구분.
/// operation: 'insert' | 'update' | 'delete'. payload: snake_case JSON 스냅샷.
@DataClassName('SyncQueueData')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityTable => text()();                 // 'albums' | 'compositions' | …
  TextColumn get entityId => text()();                    // 대상 행 uuid
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  // 참조 데이터
  Works,
  WorkMovements,
  WorkAliases,
  Commentaries,
  // 사용자 컬렉션
  Albums,
  Compositions,
  Movements,
  AlbumPerformers,
  CompositionPerformers,
  Wishlist,
  // 로컬 고유 상태
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        // 로컬은 캐시라 drop & 재동기화도 가능하지만(§3-5), 미전송 편집이
        // sync_queue에 남아 있을 수 있어 재생성하지 않고 컬럼만 더한다.
        onUpgrade: (m, from, to) async {
          // v2: compositions.title (Supabase 20260727080019_composition_title)
          if (from < 2) {
            await m.addColumn(compositions, compositions.title);
          }
          // v3: wishlist.composer/title (Supabase 20260804120000_wishlist_free_text)
          //   CHECK 제약 완화는 서버 쪽 이야기다 — 로컬은 FK 강제를 켜지 않으므로
          //   컬럼 추가만으로 충분하다.
          if (from < 3) {
            await m.addColumn(wishlist, wishlist.composer);
            await m.addColumn(wishlist, wishlist.title);
          }
        },
      );
}

QueryExecutor openDatabaseConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    // v03 전환: 구 도서 스키마(mylibrary.sqlite)와 분리된 새 캐시 파일.
    // 로컬은 캐시이므로 구 파일은 폐기해도 무손실(§3-5).
    final file = File(p.join(dbFolder.path, 'classicshelf.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
