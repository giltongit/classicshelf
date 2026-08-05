// =============================================================================
// collection_repository.dart — 리포지토리 인터페이스
//   book_repository.dart 를 대체. 화면·프로바이더는 이 인터페이스만 알며
//   Drift / Supabase 존재를 모른다.
//
// book 대비 핵심 변화 (클라이언트 UUID · 애그리게이트):
//   · localId↔supabaseId 이중 식별자 소멸 → 단일 String id(클라 UUID).
//   · BookInsertResult(promote 매핑) 소멸 → 표지가 생성 즉시 uuid 경로.
//   · 저장 단위 = Album 애그리게이트(수록곡·악장·연주자 포함) 통째.
//   · 충돌 해결 = Album 단위 LWW(판단 1) → 하위는 "replace-children"으로 통째 동기화.
// =============================================================================

import '../models/album.dart';
import '../models/album_filter.dart';
import '../models/album_summary.dart';
import '../models/wishlist_entry.dart';
import '../models/work.dart';

/// flush 결과 통계. book의 FlushSyncResult에서 promote(inserted 매핑)를 제거.
/// 클라이언트 UUID라 "새로 얻은 서버 id" 개념이 없으므로 insert 목록이 불필요.
typedef FlushResult = ({
  int totalItems,
  int succeeded,
  int dnsFailures,
});

/// syncFromRemote(원격→로컬) 결과 통계. 화면(당겨서 새로고침)이 표시한다.
///   fetched        : 서버에서 받은 앨범 수
///   applied        : 로컬에 반영(upsert + 하위 replace)한 앨범 수
///   skippedPending : sync_queue에 미전송 변경이 있어 덮어쓰지 않고 건너뛴 앨범 수
typedef SyncResult = ({
  int fetched,
  int applied,
  int skippedPending,
});

/// 참조 데이터(Works) 동기화 결과. 화면이 표시한다.
typedef WorksSyncResult = ({int works, int aliases});

/// 필터 시트 선택지 — 이미 등록된 데이터에서 뽑은 distinct 값.
/// composer·conductor 필터는 **정확 일치**(§6-3 쿼리)라 자유 텍스트로 받으면
/// 한 글자만 달라도 0건이 된다. 있는 값 중에서 고르게 하려고 별도로 뽑는다.
/// (Works 시드가 들어오면 자동완성으로 대체 가능 — 그때까지의 대안)
/// periods는 **사용자가 매칭한 수록곡이 참조하는 work의 시대**만 담는다.
/// works 전체(2만여 건)에서 뽑으면 대부분 0건인 칩이 생겨, composer/conductor와
/// 달리 "고를 수 있는데 결과가 없는" 선택지가 된다. 있는 것만 보여준다.
typedef FilterFacets = ({
  List<String> composers,
  List<String> conductors,
  List<String> periods,
});

/// 위시 자동 해소 감지(§17-21)가 대조하는 "소장 중인 수록곡" 한 줄.
/// 앨범 애그리게이트를 앨범 수만큼 조립하지 않으려고 평면 뷰로 뽑는다 —
/// 매칭에 필요한 건 workId·composer·title 셋과, 사용자에게 보여줄 앨범 제목뿐이다.
typedef CompositionKey = ({
  String albumId,
  String albumTitle,
  String? workId,
  String composer,
  String? title,
});

/// 저장된 애그리게이트 반환값. book처럼 서버 id를 되돌려줄 필요가 없어
/// 도메인 Album을 그대로 반환한다(로컬=원격 동일 id).
abstract interface class CollectionRepository {
  // ── 조회 ────────────────────────────────────────────────────────────────
  /// 목록·필터용 경량 뷰. 애그리게이트 하위까지 조립하지 않는다(§6-1 목록 성능).
  Future<List<AlbumSummary>> getAlbumSummaries(AlbumFilter filter);

  /// 반응형 목록 — Drift .watch()로 관련 테이블 변경 시 자동 방출.
  Stream<List<AlbumSummary>> watchAlbumSummaries(AlbumFilter filter);

  /// 단일 앨범 애그리게이트(상세·편집용). 없으면 null.
  Future<Album?> getAlbum(String albumId);

  /// 필터 시트 선택지(작곡가·지휘자). 등록된 데이터에서 distinct.
  Future<FilterFacets> getFilterFacets();

  // ── 참조 데이터(Works) ────────────────────────────────────────────────────
  /// 로컬 works 행 수. 0이면 아직 참조 데이터를 안 받았다는 뜻(앱 시작 자동 동기화 판단).
  Future<int> localWorksCount();

  /// 등록 폼 작곡가 자동완성 — 로컬 works의 composer 부분일치(distinct).
  Future<List<String>> suggestComposers(String query, {int limit = 20});

  /// 등록 폼 작품 자동완성 — 해당 작곡가의 works 중 제목 부분일치.
  /// popular·recommended를 먼저 올린다(§3-7 자동완성 순위).
  Future<List<Work>> suggestWorks(String composer, String query,
      {int limit = 30});

  /// 정규 작품 단건 조회(id → Work). 매칭된 수록곡의 정규명 표시용(§3-1a).
  /// 로컬에 없는 id는 결과에서 빠진다 — 참조 데이터를 아직 안 받았을 수 있다.
  Future<Map<String, Work>> getWorksByIds(Iterable<String> ids);

  /// 원격 works/work_aliases → 로컬 Drift 벌크 미러링.
  /// 참조 데이터는 사용자 소유가 아니라 공용 읽기 전용이므로 sync_queue와 무관하다
  /// (올릴 로컬 변경이 없다). 통째로 upsert하면 끝.
  Future<WorksSyncResult> syncWorksFromRemote();

  /// 희망 목록(독립 애그리게이트). 등록순(최신 위).
  Future<List<WishItem>> getWishlist();

  /// 반응형 희망 목록 — watchAlbumSummaries와 같은 Drift .watch() 패턴.
  Stream<List<WishItem>> watchWishlist();

  /// 소장 중(disposed_at is null)인 앨범의 모든 수록곡을 매칭 키로 평면 조회.
  /// 위시 "지금 확인"(백필)이 쓴다 — 이 기능이 생기기 전에 등록한 앨범은
  /// 저장 직후 감지를 거친 적이 없으므로 한 번은 전량 대조가 필요하다.
  /// 처분한 앨범은 뺀다: 더는 소장하지 않으니 위시가 여전히 유효하다.
  Future<List<CompositionKey>> getCompositionMatchKeys();

  // ── 쓰기 (애그리게이트 단위) ──────────────────────────────────────────────
  /// 앨범 애그리게이트를 통째로 저장(신규/수정 공용).
  /// Drift 트랜잭션으로 albums upsert + 하위 replace 후,
  /// 온라인이면 Supabase 반영, 오프라인/실패면 sync_queue 적재.
  /// 반환: 저장된 Album(로컬=원격 동일 id).
  Future<Album> saveAlbum(Album album);

  /// 앨범 애그리게이트 삭제(하위 cascade는 로컬·원격 각각 처리).
  Future<void> deleteAlbum(String albumId);

  /// 희망 항목 저장/삭제(독립 루트).
  Future<WishItem> saveWishItem(WishItem item);
  Future<void> deleteWishItem(String wishId);

  // ── 원격 동기화 ──────────────────────────────────────────────────────────
  /// Supabase 전체 조회 → Drift 미러링(id 기준 upsert). 초기 로그인/전체 새로고침.
  /// sync_queue에 미전송 변경이 있는 앨범은 건너뛴다(오프라인 편집 유실 방지).
  /// 서버 데이터는 로컬에 넣기만 하고, 도메인 조립은 로컬 read(getAlbum 등)가 맡는다.
  Future<SyncResult> syncFromRemote();

  /// sync_queue를 entityTable 우선순위 + 방향(insert/delete)에 따라 flush.
  Future<FlushResult> flushSyncQueue();

  /// 로컬에 있으나 원격에 없는 앨범을 동일 id로 재삽입(원격 유실 복원).
  Future<void> reconcileLocalOnlyToRemote();

  Future<int> pendingQueueCount();

  // ── 표지 ────────────────────────────────────────────────────────────────
  /// Storage 업로드 완료 후 cover_url을 Drift + Supabase(또는 큐)에 반영.
  /// book과 달리 [albumId]는 항상 최종 uuid(로컬=원격). localId 문자열 분기 없음.
  Future<void> updateCoverUrl(String albumId, String storageUrl);
}
