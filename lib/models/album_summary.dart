// =============================================================================
// album_summary.dart — 목록 화면용 경량 뷰 모델
//   목록은 앨범 100개를 그릴 때 하위(수록곡·악장)까지 조립하면 무겁다.
//   저장·상세는 Album 애그리게이트(album.dart)를, 목록은 이 헤더 뷰를 쓴다.
//
//   이 모델은 저장 대상이 아니다(toJson 없음). 리포지토리가 albums 테이블 +
//   집계(수록곡 수, 대표 작곡가 등)를 조회해 만든다.
// =============================================================================

import 'album.dart' show HoldingStatus;
import 'model_utils.dart';

class AlbumSummary {
  final String id;
  final String title;
  final String? label;
  final int? releaseYear;
  final String? format;
  final String? coverUrl;
  final DateTime? disposedAt;

  /// 목록 표시용 집계값 (리포지토리가 조인/카운트로 채움).
  final String? primaryComposer; // 대표 작곡가 (첫 수록곡 등)
  final int compositionCount; // 수록곡 수
  final bool needsVerification; // 미확인 필드 보유 여부(§6-1 배지)

  const AlbumSummary({
    required this.id,
    required this.title,
    this.label,
    this.releaseYear,
    this.format,
    this.coverUrl,
    this.disposedAt,
    this.primaryComposer,
    this.compositionCount = 0,
    this.needsVerification = false,
  });

  HoldingStatus get status =>
      disposedAt == null ? HoldingStatus.owned : HoldingStatus.disposed;

  /// albums 행 + 집계 필드로 조립. 집계는 리포지토리가 별도 계산해 넘긴다.
  factory AlbumSummary.fromRow(
    Map<String, dynamic> albumJson, {
    String? primaryComposer,
    int compositionCount = 0,
    bool needsVerification = false,
  }) =>
      AlbumSummary(
        id: albumJson['id'] as String,
        title: albumJson['title'] as String,
        label: albumJson['label'] as String?,
        releaseYear: albumJson['release_year'] as int?,
        format: albumJson['format'] as String?,
        coverUrl: albumJson['cover_url'] as String?,
        disposedAt: parseDate(albumJson['disposed_at']),
        primaryComposer: primaryComposer,
        compositionCount: compositionCount,
        needsVerification: needsVerification,
      );
}
