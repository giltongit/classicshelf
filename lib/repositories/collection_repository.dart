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

  /// 희망 목록(독립 애그리게이트).
  Future<List<WishItem>> getWishlist();

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
