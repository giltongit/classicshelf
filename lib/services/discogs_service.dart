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

/// 한 바코드로 시도해 볼 표기 후보를 순서대로 만든다.
///
/// 왜 필요한가: 같은 음반이라도 표기가 흔들린다.
///   · 인쇄 표기에 공백·하이픈이 섞인다 — "7 2064-24425-2 4"
///   · 미국반은 UPC-A(12자리), 그 외는 EAN-13(13자리)인데 둘은 앞자리 `0`
///     하나 차이다. 스캐너가 준 자릿수와 Discogs에 등록된 자릿수가 엇갈리면
///     같은 음반인데도 0건이 나온다(§17-28 "포맷 불일치").
///
/// 첫 원소는 언제나 정규화한 원본이다 — 두 번째부터 걸리면 포맷 불일치였다는
/// 뜻이라, 호출자가 그걸로 실패 원인을 가른다.
List<String> discogsBarcodeCandidates(String raw) {
  final normalized = raw.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
  if (normalized.isEmpty) return const [];

  final out = [normalized];

  void add(String c) {
    if (c.isNotEmpty && !out.contains(c)) out.add(c);
  }

  // UPC-A(12) → EAN-13: 앞에 0을 붙인 게 같은 바코드다.
  if (normalized.length == 12) add('0$normalized');
  // EAN-13(13)인데 앞이 0 → UPC-A로 등록돼 있을 수 있다.
  if (normalized.length == 13 && normalized.startsWith('0')) {
    add(normalized.substring(1));
  }

  return out;
}

class DiscogsService {
  final http.Client _client;

  DiscogsService({http.Client? client}) : _client = client ?? http.Client();

  /// 바코드로 릴리스 후보를 찾는다. 결과 순서는 Discogs가 준 순서를 그대로 둔다
  /// (자체 정렬을 하면 어떤 기준으로 골라야 할지 근거가 없다).
  ///
  /// 후보 표기를 순서대로 넣어 보고 처음 걸리는 걸 쓴다 —
  /// 자세한 규칙은 [discogsBarcodeCandidates].
  Future<List<DiscogsMatch>> searchByBarcode(String barcode) async {
    final candidates = discogsBarcodeCandidates(barcode);
    if (candidates.isEmpty) {
      debugPrint('[DISCOGS] 검색 건너뜀 — 정규화 후 남는 값 없음 raw="$barcode"');
      return const [];
    }

    for (var i = 0; i < candidates.length; i++) {
      final results = await _search(candidates[i]);
      if (results.isEmpty) continue;
      if (i > 0) {
        // 원본으로는 0건이었는데 변형으로 걸렸다 = 포맷 불일치(§2-4 분류).
        debugPrint('[DISCOGS] retry(normalized)=${candidates[i]} '
            'items=${results.length} (원본 "${candidates.first}" 는 0건)');
      }
      return results;
    }

    debugPrint('[DISCOGS] 후보 ${candidates.length}종 모두 0건 — '
        '${candidates.join(" / ")}');
    return const [];
  }

  Future<List<DiscogsMatch>> _search(String barcode) async {
    final uri = Uri.https(_host, '/database/search', {
      'barcode': barcode,
      // master는 트랙·바코드를 갖지 않는다 — 상세 조회가 불가능하므로 제외.
      'type': 'release',
      'per_page': '100',
    });

    final res = await _getJson(uri);
    final raw = res.json['results'];
    final list = raw is List ? raw : const [];

    final rows = list
        .whereType<Map<String, dynamic>>()
        .where((r) => r['type'] == 'release' && r['id'] is num)
        .toList();
    final kept = rows.map(DiscogsMatch.fromJson).toList();

    // 진단용(§2-1).
    //   total    — Discogs가 센 전체 건수. items와 다르면 우리 필터가 걸러낸 것.
    //   verified — 결과에 실린 바코드가 실제로 우리가 물어본 값과 같은 건수.
    //
    // verified가 필요한 이유: Discogs의 barcode 검색은 완전 일치가 아니다.
    // 없는 바코드("9999999999999")를 넣어도 무관한 릴리스가 14건 돌아온다
    // (실측). 그래서 "0건 = 미보유"가 성립하지 않는다 — items는 많은데
    // verified가 0이면 그게 진짜 미보유 신호다(§2-4 분류의 핵심 지표).
    final total = (res.json['pagination'] as Map?)?['items'];
    final verified = rows.where((r) => discogsRowHasBarcode(r, barcode)).length;

    debugPrint('[DISCOGS] query=$barcode status=${res.status} '
        'items=${kept.length} verified=$verified'
        '${total != null && total != kept.length ? ' total=$total' : ''}');

    return kept;
  }

  /// 릴리스 상세 → 폼에 바로 넣을 수 있는 초안.
  Future<AlbumDraft> fetchRelease(int releaseId) async {
    final res = await _getJson(Uri.https(_host, '/releases/$releaseId'));
    return mapDiscogsReleaseToDraft(res.json);
  }

  Future<({int status, Map<String, dynamic> json})> _getJson(Uri uri) async {
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
      debugPrint('[DISCOGS] status=429 레이트리밋 $uri');
      throw const DiscogsException('조회 요청이 많습니다. 1분 후 다시 시도해 주세요');
    }
    if (res.statusCode == 404) {
      debugPrint('[DISCOGS] status=404 $uri');
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
      return (status: res.statusCode, json: decoded);
    } on DiscogsException {
      rethrow;
    } catch (e) {
      debugPrint('[DISCOGS] 파싱 실패 $uri: $e');
      throw const DiscogsException('음반 정보를 읽지 못했습니다');
    }
  }

  void dispose() => _client.close();
}


/// 검색 결과 한 줄이 실제로 이 바코드를 달고 있는지.
///
/// 결과 JSON의 barcode 배열에는 인쇄 표기가 그대로 들어 있어서
/// ("7 2064-24425-2 4") 숫자만 남겨 비교한다. UPC-A/EAN-13은 앞자리 0
/// 차이뿐이므로 **선행 0을 전부** 떼어 같은 자리에 맞춘다 — 하나만 떼면
/// "0028947775782"와 "028947775782"가 서로 다른 값이 되어 버린다.
///
/// 부분 일치는 통과시키지 않는다. Discogs 검색이 물어다 주는 노이즈가
/// 정확히 그 모양이라(러너아웃에 숫자가 길게 박힌 릴리스), 부분 일치를
/// 허용하면 대조 지표가 의미를 잃는다.
bool discogsRowHasBarcode(Map<String, dynamic> row, String query) {
  String canon(String s) =>
      s.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0+'), '');

  final want = canon(query);
  if (want.isEmpty) return false;

  final barcodes = (row['barcode'] as List?)?.whereType<String>() ?? const [];
  return barcodes.any((b) => canon(b) == want);

}
