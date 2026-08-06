// =============================================================================
// discogs_service.dart — Discogs API 조회 (아키텍처 v10 §5 메타데이터 파이프라인)
//
// 바코드 → 릴리스 후보 목록 → 릴리스 상세 → AlbumDraft. 두 번의 GET이 전부다.
//
// ── 법적 제약 (Discogs API Terms of Use) ──────────────────────────────────────
//  1. 이미지는 Restricted Data — 상업적 사용 금지.
//     응답 JSON에 images/thumb/cover_image가 **요청하지 않아도 딸려 온다**.
//     이 파일은 그 키들을 한 번도 읽지 않는다. 커버는 사용자 촬영
//     (cover_photo_service.dart)만 쓴다. 파서에 이미지 필드를 추가하지 말 것.
//  2. 6시간 이상 캐시 금지 · 서비스 제공에 필요한 기간 이상 저장 금지.
//     그래서 이 서비스는 **어떤 캐시도 두지 않는다**(메모리 캐시조차 없다).
//     조회 결과는 호출자의 화면 상태로만 살아 있고, 사용자가 최종 저장하는 건
//     Discogs 원본이 아니라 폼에서 확인·보정한 우리 자체 Album 데이터다.
//     여기에 Drift 테이블이나 SharedPreferences를 붙이지 말 것.
//  3. 출처 표기 의무. AlbumDraft.sourceName/sourceUrl로 화면까지 전달한다
//     (설정 화면의 고정 문구는 settings_screen.dart).
//
// ── 인증 ─────────────────────────────────────────────────────────────────────
// 토큰이 필요 없다. /database/search·/releases 모두 미인증 200으로 응답한다
// (실측 확인). 그래서 앱 바이너리에 토큰을 심지 않는다 — 유출 리스크가 아예
// 없는 쪽을 택했다. 대신 미인증 레이트리밋이 25 req/min이고(인증 시 60),
// 스캔 한 건당 요청 2회라 실사용에는 충분하다. 429는 아래에서 안내로 바꾼다.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/album_draft.dart';
import 'discogs_mapper.dart';

/// Discogs가 요구하는 식별 가능한 User-Agent. 값이 비면 차단될 수 있다.
const _userAgent = 'ClassicShelf/1.0 +https://github.com/giltongit/classicshelf';

const _host = 'api.discogs.com';

/// 후보 목록에 한 번에 보여줄 개수. 바코드 하나에 릴리스가 수백 건씩(전 세계
/// 프레싱) 잡히는 게 정상이라, 전부 그리면 목록이 무의미해진다.
/// 화면이 "더 보기"로 이만큼씩 늘린다.
const kDiscogsPageSize = 20;

/// 조회 실패를 화면에 그대로 보여줄 수 있는 형태로 감싼다.
/// 원인별로 문구가 달라야 사용자가 다음 행동을 안다(재시도 / 수동 입력).
class DiscogsException implements Exception {
  final String message;
  const DiscogsException(this.message);

  @override
  String toString() => message;
}

/// 후보 목록의 한 줄. 상세 조회 전이라 트랙 정보는 아직 없다.
/// 이미지 필드(thumb/cover_image)는 의도적으로 담지 않는다(제약 1).
class DiscogsMatch {
  final int id;
  final String title;
  final String? year;
  final String? country;
  final String? label;
  final String? catNo;

  /// 'CD · Box Set' 처럼 이어 붙인 표시용 문자열.
  final String? format;

  const DiscogsMatch({
    required this.id,
    required this.title,
    this.year,
    this.country,
    this.label,
    this.catNo,
    this.format,
  });

  /// 후보 줄에서 제목 아래 한 줄로 보여줄 부가 정보.
  String get subtitle => [
        if (year != null && year!.isNotEmpty && year != '0') year!,
        if (country != null && country!.isNotEmpty) country!,
        if (label != null && label!.isNotEmpty) label!,
        if (catNo != null && catNo!.isNotEmpty) catNo!,
      ].join(' · ');

  factory DiscogsMatch.fromJson(Map<String, dynamic> j) {
    // label은 같은 이름이 여러 번(디스크 수만큼) 반복되는 일이 흔하다 — 첫 값만.
    final labels = (j['label'] as List?)?.whereType<String>().toList();
    final formats = (j['format'] as List?)?.whereType<String>().toList();
    return DiscogsMatch(
      id: (j['id'] as num).toInt(),
      title: discogsCleanSearchTitle(j['title'] as String? ?? '(제목 없음)'),
      year: j['year']?.toString(),
      country: j['country'] as String?,
      label: (labels == null || labels.isEmpty) ? null : labels.first,
      catNo: j['catno'] as String?,
      format: (formats == null || formats.isEmpty) ? null : formats.join(' · '),
    );
  }
}

class DiscogsService {
  final http.Client _client;

  DiscogsService({http.Client? client}) : _client = client ?? http.Client();

  /// 바코드로 릴리스 후보를 찾는다. 결과 순서는 Discogs가 준 순서를 그대로 둔다
  /// (자체 정렬을 하면 어떤 기준으로 골라야 할지 근거가 없다).
  ///
  /// 바코드는 표기 흔들림이 심하다("7 2064-24425-2 4" vs "720642442524").
  /// 검색은 정규화한 숫자열로 하고, 그래도 0건이면 원문으로 한 번 더 시도한다.
  Future<List<DiscogsMatch>> searchByBarcode(String barcode) async {
    final normalized = barcode.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
    var results = await _search(normalized);

    // EAN-13은 앞자리 0이 붙기도 하고 빠지기도 한다 — 양쪽을 한 번씩 더 본다.
    if (results.isEmpty && normalized.length == 12) {
      results = await _search('0$normalized');
    } else if (results.isEmpty && normalized.startsWith('0')) {
      results = await _search(normalized.substring(1));
    }
    return results;
  }

  Future<List<DiscogsMatch>> _search(String barcode) async {
    final uri = Uri.https(_host, '/database/search', {
      'barcode': barcode,
      // master는 트랙·바코드를 갖지 않는다 — 상세 조회가 불가능하므로 제외.
      'type': 'release',
      'per_page': '100',
    });

    final json = await _getJson(uri);
    final results = json['results'];
    if (results is! List) return const [];

    return results
        .whereType<Map<String, dynamic>>()
        .where((r) => r['type'] == 'release' && r['id'] is num)
        .map(DiscogsMatch.fromJson)
        .toList();
  }

  /// 릴리스 상세 → 폼에 바로 넣을 수 있는 초안.
  Future<AlbumDraft> fetchRelease(int releaseId) async {
    final json = await _getJson(Uri.https(_host, '/releases/$releaseId'));
    return mapDiscogsReleaseToDraft(json);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    http.Response res;
    try {
      res = await _client
          .get(uri, headers: const {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[DISCOGS] 네트워크 실패 $uri: $e');
      throw const DiscogsException('네트워크에 연결할 수 없습니다. 잠시 후 다시 시도해 주세요');
    }

    if (res.statusCode == 429) {
      // 미인증 25 req/min. 사용자가 연속으로 스캔했을 때만 볼 화면이라
      // 재시도 대신 잠깐 기다리라고 안내한다.
      throw const DiscogsException('조회 요청이 많습니다. 1분 후 다시 시도해 주세요');
    }
    if (res.statusCode == 404) {
      throw const DiscogsException('해당 음반 정보를 찾을 수 없습니다');
    }
    if (res.statusCode != 200) {
      debugPrint('[DISCOGS] HTTP ${res.statusCode} $uri');
      throw DiscogsException('음반 정보 조회 실패 (${res.statusCode})');
    }

    try {
      // Discogs 응답은 UTF-8이다. res.body는 charset 미명시 시 latin-1로 읽어
      // 독일어·프랑스어 곡명이 깨진다(클래식에서 특히 잦다) — 직접 디코드한다.
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const DiscogsException('음반 정보 형식이 올바르지 않습니다');
      }
      return decoded;
    } on DiscogsException {
      rethrow;
    } catch (e) {
      debugPrint('[DISCOGS] 파싱 실패 $uri: $e');
      throw const DiscogsException('음반 정보를 읽지 못했습니다');
    }
  }

  void dispose() => _client.close();
}
