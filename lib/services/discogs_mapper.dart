// =============================================================================
// discogs_mapper.dart — Discogs 릴리스 JSON → AlbumDraft (§2-3 필드 매핑)
//
// 서비스(HTTP)와 분리한 이유: 매핑 규칙이 이 연동에서 가장 불확실한 부분이라
// 네트워크 없이 고정 JSON으로 규칙만 따로 검증·수정할 수 있어야 한다.
//
// ── 핵심 구조: tracklist는 평면 목록이 아니라 2단이다 (실측 확인) ─────────────
//   tracklist[]
//    ├ type_ "heading"  "Compact Disk 1"          → 디스크 구분선. 버린다.
//    ├ type_ "index"    "Symphony No. 1, Op. 21"  → 작품   = Composition
//    │   └ sub_tracks[] "1. Adagio Molto"         → 악장   = Movement
//    └ type_ "track"    "Overture Egmont, Op. 84" → 단악장 작품 = Composition
//   즉 Discogs의 index/sub_tracks가 우리 Composition/Movement와 1:1로 맞는다.
//
//   index 자체의 position은 대개 비어 있고, 디스크·트랙 번호는 sub_tracks의
//   position("1-9" = 1번 디스크 9번 트랙)에만 있다. 그래서 번호는 언제나
//   하위에서 끌어올린다.
//
// ── 이미지 금지 (Discogs API Terms) ──────────────────────────────────────────
//   응답에 images/thumb/cover_image가 딸려 오지만 이 파일은 읽지 않는다.
//   커버는 사용자 촬영본만 쓴다. 여기에 이미지 매핑을 추가하지 말 것.
//
// ── 못 채우면 비운다 ─────────────────────────────────────────────────────────
//   Discogs는 장르 불문 카탈로그라 클래식 크레딧 관행이 일정하지 않다.
//   규칙에 안 맞는 값은 억지로 끼워 넣지 않고 비워서 사용자에게 넘긴다
//   (§4-2 선택 입력 철학). 자동으로 채운 값은 화면에서 "확인 필요"로 뜬다.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../models/album.dart';
import '../models/album_draft.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 진입점
// ─────────────────────────────────────────────────────────────────────────────

AlbumDraft mapDiscogsReleaseToDraft(Map<String, dynamic> j) {
  // 매핑하지 못하고 버린 역할을 모아 마지막에 한 번만 찍는다(§2-2).
  // 역할별로 그때그때 찍으면 트랙 수만큼 같은 줄이 반복된다.
  final dropped = <String, int>{};

  final releaseCredits = _parseCredits(j['extraartists']);
  final albumPerformers = _performers(releaseCredits, dropped);

  final draft = AlbumDraft(
    title: _nullIfEmpty(j['title'] as String?),
    label: _firstLabel(j['labels']),
    releaseYear: _year(j),
    discCount: _discCount(j),
    format: _format(j['formats']),
    barcode: _barcode(j['identifiers']),
    defaultPerformers: albumPerformers,
    compositions: _compositions(
      j['tracklist'],
      fallbackComposer: _composer(releaseCredits, j['artists']),
      albumPerformers: albumPerformers,
      dropped: dropped,
    ),
    sourceName: 'Discogs',
    sourceUrl: _nullIfEmpty(j['uri'] as String?),
  );

  _logDroppedRoles(dropped);
  return draft;
}

/// 버린 역할을 빈도와 함께 남긴다. 매핑 테이블을 넓힐지 말지는 추측이 아니라
/// 실제로 무엇이 얼마나 버려지는지를 보고 정해야 한다.
void _logDroppedRoles(Map<String, int> dropped) {
  if (dropped.isEmpty) return;
  final sorted = dropped.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final summary = sorted.map((e) => '${e.key}×${e.value}').join(', ');
  debugPrint('[DISCOGS] 매핑하지 않은 역할: $summary');
}

// ─────────────────────────────────────────────────────────────────────────────
// 이름 정리
// ─────────────────────────────────────────────────────────────────────────────

/// Discogs 이름 표기 정리.
///   · 뒤에 붙는 `*` — 릴리스 표기가 정식 아티스트명과 다를 때의 표시
///     ("Beethoven*"). 이름의 일부가 아니다.
///   · ` (2)` — 동명이인 구분 번호 ("Richard Osborne (2)").
///
/// 곡 제목에는 쓰지 않는다 — "Symphony No. 5 (1808)"처럼 괄호+숫자가
/// 제목의 일부인 경우를 지워 버린다.
String discogsCleanName(String s) => s
    .replaceAll('*', '')
    .replaceAll(RegExp(r'\s*\(\d+\)'), '')
    .trim();

/// 검색 결과의 "아티스트 - 제목" 합본 문자열용. 여기서는 `*`만 떼고
/// 괄호 숫자는 남긴다 — "Symphony No. 5 (1808)"처럼 제목의 일부일 수 있다.
String discogsCleanSearchTitle(String s) => s.replaceAll('*', '').trim();

String? _nullIfEmpty(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 음반 기본정보
// ─────────────────────────────────────────────────────────────────────────────

String? _firstLabel(dynamic labels) {
  if (labels is! List) return null;
  for (final l in labels) {
    if (l is Map && l['name'] is String) {
      final name = discogsCleanName(l['name'] as String);
      if (name.isNotEmpty) return name;
    }
  }
  return null;
}

/// year가 0으로 오는 릴리스가 흔하다(실측 샘플 4건 중 3건).
/// 0이면 released("2008-01-01" / "2008")에서 앞 네 자리를 본다.
int? _year(Map<String, dynamic> j) {
  final y = j['year'];
  if (y is num && y > 0) return y.toInt();
  if (y is String) {
    final n = int.tryParse(y);
    if (n != null && n > 0) return n;
  }
  final released = j['released'];
  if (released is String && released.length >= 4) {
    final n = int.tryParse(released.substring(0, 4));
    if (n != null && n > 0) return n;
  }
  return null;
}

/// 실제 매체(디스크) 개수.
///
/// format_quantity는 상자까지 세어 부정확하다 — CD 5장 + Box Set 1 → 6.
/// 그래서 formats[]에서 상자류를 뺀 매체 항목의 qty만 본다.
const _containerFormats = {'box set', 'all media', 'shrink wrap'};

int? _discCount(Map<String, dynamic> j) {
  final formats = j['formats'];
  if (formats is! List) return null;

  var max = 0;
  for (final f in formats) {
    if (f is! Map) continue;
    final name = (f['name'] as String?)?.toLowerCase().trim() ?? '';
    if (name.isEmpty || _containerFormats.contains(name)) continue;
    final qty = int.tryParse((f['qty'] as String?) ?? '');
    if (qty != null && qty > max) max = qty;
  }
  return max > 0 ? max : null;
}

/// Discogs 포맷 어휘 → kAlbumFormats(CD/LP/SACD/digital).
/// Discogs는 매체명이 'Vinyl'이고 'LP'는 설명(descriptions)에 들어간다.
String? _format(dynamic formats) {
  if (formats is! List) return null;

  // 한 릴리스에 CD+SACD 하이브리드 같은 조합이 있어 우선순위를 둔다.
  // 위쪽이 더 구체적인 매체다.
  const priority = ['SACD', 'CD', 'LP', 'digital'];
  final found = <String>{};

  for (final f in formats) {
    if (f is! Map) continue;
    final name = (f['name'] as String?)?.toLowerCase().trim() ?? '';
    final descs = ((f['descriptions'] as List?) ?? const [])
        .whereType<String>()
        .map((d) => d.toLowerCase())
        .toSet();

    if (name == 'sacd' || descs.contains('sacd')) found.add('SACD');
    if (name == 'cd') found.add('CD');
    if (name == 'vinyl') found.add('LP');
    if (name == 'file' || name == 'digital') found.add('digital');
  }

  for (final p in priority) {
    if (found.contains(p)) return p;
  }
  return null;
}

/// identifiers에는 Matrix / Runout, Label Code, Rights Society 등이 섞여 있다.
/// type이 정확히 Barcode인 것만 고르고, 표기용 공백·하이픈은 떼서 숫자열로 만든다
/// ("7 2064-24425-2 4" → "720642442524") — 중복 감지(§4-3)가 문자열 비교라
/// 표기가 흔들리면 같은 음반을 못 알아본다.
String? _barcode(dynamic identifiers) {
  if (identifiers is! List) return null;
  for (final i in identifiers) {
    if (i is! Map) continue;
    if ((i['type'] as String?)?.toLowerCase() != 'barcode') continue;
    final raw = (i['value'] as String?) ?? '';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 8) return digits;
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// 크레딧 (extraartists) → 역할별 이름
// ─────────────────────────────────────────────────────────────────────────────

/// role 문자열 → 이름 목록. role은 아래 규칙으로 정규화해 담는다.
typedef _Credits = Map<String, List<String>>;

/// Discogs role 표기의 두 가지 성질을 처리한다:
///   · 대괄호 한정어 — "Engineer [Balance Engineer]", "Composed By [Uncredited]"
///   · 한 사람의 복수 역할 — "Conductor, Piano"
///     단 대괄호 **안**의 쉼표는 구분자가 아니다("Engineer [Tonmeister, Balance]").
List<String> _splitRoles(String role) {
  final parts = <String>[];
  final buf = StringBuffer();
  var depth = 0;

  for (final ch in role.split('')) {
    if (ch == '[') depth++;
    if (ch == ']') depth--;
    if (ch == ',' && depth == 0) {
      parts.add(buf.toString());
      buf.clear();
    } else {
      buf.write(ch);
    }
  }
  parts.add(buf.toString());

  return parts
      .map((p) => p.replaceAll(RegExp(r'\[[^\]]*\]'), '').trim().toLowerCase())
      .where((p) => p.isNotEmpty)
      .toList();
}

_Credits _parseCredits(dynamic extraartists) {
  final out = <String, List<String>>{};
  if (extraartists is! List) return out;

  for (final e in extraartists) {
    if (e is! Map) continue;
    final name = discogsCleanName((e['name'] as String?) ?? '');
    if (name.isEmpty) continue;
    for (final role in _splitRoles((e['role'] as String?) ?? '')) {
      (out[role] ??= []).add(name);
    }
  }
  return out;
}

// 역할 → PerformerRole 매핑. 여기 없는 역할(프로듀서·엔지니어·라이너노트 등)은
// 통째로 버린다. 허용 목록으로 두는 이유: 제작 크레딧 종류가 끝이 없어서
// 제외 목록으로는 관리가 안 되고, 잘못 들어온 이름 하나가 연주자 목록을 더럽히면
// 사용자가 지우는 수고가 채워 넣는 수고보다 크다.
const _conductorRoles = {'conductor', 'chorus master', 'choir master'};
const _orchestraRoles = {'orchestra', 'symphony orchestra'};
const _ensembleRoles = {
  'ensemble', 'choir', 'chorus', 'quartet', 'quintet', 'trio', 'string quartet',
};
const _vocalistRoles = {
  'vocals', 'voice', 'narrator', 'speaker',
};

/// 성악 역할은 Discogs에서 성부 뒤에 " Vocals"가 붙어 온다 —
/// "Soprano Vocals", "Tenor Vocals", "Mezzo-soprano Vocals", "Treble Vocals"…
/// 성부를 일일이 나열하는 대신 접미사로 잡는다. 실측 12개 릴리스에서 이 한 줄이
/// 놓치던 연주자 크레딧의 86%(285건)를 회수했고, 새로운 성부가 나와도 따라온다.
///
/// 접미사로 판정하는 게 안전한 이유: 악기명에는 이 접미사가 붙지 않는다.
/// (성부 이름만 단독으로 잡으면 "Soprano Saxophone"을 성악으로 오인한다.)
bool _isVocalRole(String role) => role.endsWith(' vocals');

// 독주 악기. 클래식에서 실제로 보이는 것 위주 — 없는 악기는 그냥 안 잡힐 뿐이라
// 사용자가 직접 넣으면 된다(잘못 잡는 것보다 낫다).
const _soloistRoles = {
  'soloist', 'piano', 'fortepiano', 'harpsichord', 'organ', 'celesta',
  'violin', 'viola', 'cello', 'violoncello', 'double bass', 'contrabass',
  'viola da gamba', 'viol', 'lute', 'theorbo', 'guitar', 'harp', 'mandolin',
  'flute', 'recorder', 'oboe', 'oboe d\'amore', 'clarinet', 'bassoon',
  'horn', 'french horn', 'trumpet', 'trombone', 'tuba', 'cornet',
  'saxophone', 'soprano saxophone', 'piccolo', 'percussion', 'timpani',
  'marimba', 'accordion', 'harmonica',
};

/// 연주자가 아닌 게 분명한 역할 — 버리되 로그에도 남기지 않는다.
/// 로그는 "매핑을 넓혀야 하나?" 판단용이라, 애초에 연주자가 아닌 것이 섞이면
/// 신호가 묻힌다. (Composed By는 작곡가 경로가 따로 가져간다.)
const _nonPerformerRoles = {
  'composed by', 'arranged by', 'orchestrated by', 'transcription by',
  'adapted by', 'producer', 'engineer', 'executive-producer', 'co-producer',
  'liner notes', 'photography by', 'art direction', 'design', 'artwork',
  'mastered by', 'mixed by', 'remastered by', 'recorded by', 'edited by',
  'lacquer cut by', 'management', 'booklet editor', 'translated by',
  'coordinator', 'compiled by', 'written-by', 'lyrics by', 'librettist',
};

/// 크레딧 → 연주자 목록. 허용 목록에 없는 역할은 버리고 [dropped]에 세어 둔다.
List<DraftPerformer> _performers(_Credits credits, Map<String, int> dropped) {
  final out = <DraftPerformer>[];
  final seen = <String>{}; // 역할+이름 중복(복수 역할 표기) 제거
  final matched = <String>{};

  void take(bool Function(String role) test, PerformerRole target) {
    for (final entry in credits.entries) {
      if (!test(entry.key)) continue;
      matched.add(entry.key);
      for (final name in entry.value) {
        final key = '${target.value}|$name';
        if (seen.add(key)) {
          out.add(DraftPerformer(role: target.value, name: name));
        }
      }
    }
  }

  // 지휘자·악단이 목록 위쪽에 오도록 순서를 고정한다(폼에서 보이는 순서).
  take(_conductorRoles.contains, PerformerRole.conductor);
  take(_orchestraRoles.contains, PerformerRole.orchestra);
  take(_ensembleRoles.contains, PerformerRole.ensemble);
  take(_soloistRoles.contains, PerformerRole.soloist);
  take((r) => _vocalistRoles.contains(r) || _isVocalRole(r),
      PerformerRole.vocalist);

  for (final entry in credits.entries) {
    if (matched.contains(entry.key)) continue;
    if (_nonPerformerRoles.contains(entry.key)) continue;
    dropped[entry.key] = (dropped[entry.key] ?? 0) + entry.value.length;
  }

  return out;
}

// ─────────────────────────────────────────────────────────────────────────────
// 곡별 연주자 override (§3-3 · §17-29)
// ─────────────────────────────────────────────────────────────────────────────

/// 트랙 크레딧을 앨범 기본값과 견줘, **다른 역할만** override로 돌려준다.
///
/// 규칙(§3-3 role 단위 병합과 같은 원칙):
///   · 트랙에 그 역할이 없으면        → 상속 (담지 않는다)
///   · 트랙 값이 앨범 기본값과 같으면 → 상속 (담지 않는다)
///   · 다르면                        → 그 역할의 트랙 값 전부를 담는다
///
/// 같은 값을 굳이 복사하지 않는 게 중요하다. 복사해 두면 상속이 끊겨서, 나중에
/// 앨범 기본 지휘자를 고쳐도 이 곡만 옛 이름으로 남는다.
///
/// 반환값이 비면 null — 빈 리스트가 아니다(§3-3: 행 없음 = 상속).
List<DraftPerformer>? _overridesFor(
  _Credits trackCredits,
  List<DraftPerformer> albumPerformers,
  Map<String, int> dropped,
) {
  final trackPerformers = _performers(trackCredits, dropped);
  if (trackPerformers.isEmpty) return null;

  Map<String, Set<String>> byRole(List<DraftPerformer> ps) {
    final m = <String, Set<String>>{};
    for (final p in ps) {
      (m[p.role] ??= <String>{}).add(p.name);
    }
    return m;
  }

  final albumByRole = byRole(albumPerformers);
  final trackByRole = byRole(trackPerformers);

  // 역할별로 앨범 기본값과 이름 집합을 통째로 비교한다. 한 역할에 연주자가
  // 여럿인 경우(독주 둘 등)가 있어 개별 이름이 아니라 집합끼리 견준다.
  final differing = trackByRole.entries
      .where((e) => !setEquals(albumByRole[e.key] ?? const <String>{}, e.value))
      .map((e) => e.key)
      .toSet();

  if (differing.isEmpty) return null;

  // _performers가 정한 역할 순서를 그대로 살린다.
  final out =
      trackPerformers.where((p) => differing.contains(p.role)).toList();
  return out.isEmpty ? null : out;
}

// ─────────────────────────────────────────────────────────────────────────────
// 작곡가
// ─────────────────────────────────────────────────────────────────────────────

/// 컴필레이션 자리표시자 — 작곡가 후보로 쓰면 안 된다.
const _placeholderArtists = {
  'various', 'various artists', 'unknown artist', 'no artist', 'v.a.',
};

/// 작곡가 결정 순서:
///   ① extraartists의 "Composed By" — 명시적 크레딧. 가장 믿을 만하다.
///   ② artists[0] — 클래식 릴리스는 관행상 메인 아티스트 크레딧이 작곡가이고
///      지휘자·악단은 extraartists로 빠진다(실측 샘플 4건 모두 작곡가 포함).
///      추정이므로 폼에서 "확인 필요"로 표시된다.
///   ③ 못 찾으면 빈 문자열 — 사용자가 채운다.
///
/// ②에서 Various 류 자리표시자는 거른다. 여러 작곡가의 컴필레이션인데
/// 전 곡을 "Various" 작곡으로 채우면 명백한 오답이 들어간다.
String _composer(_Credits credits, dynamic artists) {
  final composed = credits['composed by'];
  if (composed != null && composed.isNotEmpty) return composed.first;

  if (artists is List) {
    for (final a in artists) {
      if (a is! Map) continue;
      final name = discogsCleanName((a['name'] as String?) ?? '');
      if (name.isEmpty) continue;
      if (_placeholderArtists.contains(name.toLowerCase())) return '';
      return name;
    }
  }
  return '';
}

// ─────────────────────────────────────────────────────────────────────────────
// 트랙 → 수록곡 / 악장
// ─────────────────────────────────────────────────────────────────────────────

/// "1-9" → (디스크 1, 트랙 9) · "9" → (null, 9) · "A1"(LP 면 표기) → (null, null).
/// LP 면 표기를 억지로 숫자로 바꾸지 않는다 — A면 1번을 1번 트랙이라고 우기면
/// B면과 번호가 겹친다.
({int? disc, int? track}) _parsePosition(String? raw) {
  final s = (raw ?? '').trim();
  if (s.isEmpty) return (disc: null, track: null);

  final dual = RegExp(r'^(?:cd|disc)?\s*(\d+)\s*[-.]\s*(\d+)$', caseSensitive: false)
      .firstMatch(s);
  if (dual != null) {
    return (disc: int.tryParse(dual.group(1)!), track: int.tryParse(dual.group(2)!));
  }

  final single = RegExp(r'^(\d+)$').firstMatch(s);
  if (single != null) return (disc: null, track: int.tryParse(single.group(1)!));

  return (disc: null, track: null);
}

/// "7:45" → 465 · "1:07:45" → 4065(장대한 악장·오페라 막에서 나온다).
int? _parseDuration(String? raw) {
  final s = (raw ?? '').trim();
  if (s.isEmpty) return null;
  final parts = s.split(':');
  if (parts.length < 2 || parts.length > 3) return null;

  final nums = parts.map((p) => int.tryParse(p.trim())).toList();
  if (nums.any((n) => n == null)) return null;

  return parts.length == 2
      ? nums[0]! * 60 + nums[1]!
      : nums[0]! * 3600 + nums[1]! * 60 + nums[2]!;
}

List<DraftComposition> _compositions(
  dynamic tracklist, {
  required String fallbackComposer,
  required List<DraftPerformer> albumPerformers,
  required Map<String, int> dropped,
}) {
  if (tracklist is! List) return const [];

  final out = <DraftComposition>[];

  for (final t in tracklist) {
    if (t is! Map) continue;
    final type = (t['type_'] as String?) ?? 'track';

    // heading은 "Compact Disk 1" 같은 디스크 구분선이라 곡이 아니다.
    if (type == 'heading') continue;

    final title = (t['title'] as String?)?.trim() ?? '';
    if (title.isEmpty) continue;

    // 트랙 단위 크레딧이 있으면 릴리스 단위보다 우선한다 — 여러 작곡가가
    // 섞인 컴필레이션에서 곡마다 다른 작곡가를 잡아낸다.
    // 다악장 작품이라도 크레딧은 상위 index에 붙는다(실측: sub_tracks에만
    // 붙은 사례 0건/92건). 그래서 하위를 뒤지지 않고 여기 것만 본다.
    final trackCredits = _parseCredits(t['extraartists']);
    final trackComposer = _composer(trackCredits, t['artists']);
    final composer = trackComposer.isNotEmpty ? trackComposer : fallbackComposer;

    // 앨범 기본값과 다른 연주자만 곡별 override로 (§17-29).
    final overrides = _overridesFor(trackCredits, albumPerformers, dropped);

    final subs = (t['sub_tracks'] as List?)?.whereType<Map>().toList() ?? const [];

    if (subs.isEmpty) {
      // 단악장 작품(서곡·소품) — 자기 position이 곧 트랙 번호다.
      final pos = _parsePosition(t['position'] as String?);
      out.add(DraftComposition(
        composer: composer,
        title: title,
        discNo: pos.disc,
        trackFrom: pos.track,
        trackTo: pos.track,
        performerOverrides: overrides,
      ));
      continue;
    }

    // 다악장 작품 — 번호는 전부 하위 트랙에서 끌어올린다.
    final movements = <DraftMovement>[];
    int? disc;
    int? first;
    int? last;

    for (final s in subs) {
      final st = (s['title'] as String?)?.trim() ?? '';
      final pos = _parsePosition(s['position'] as String?);
      disc ??= pos.disc;
      if (pos.track != null) {
        first ??= pos.track;
        last = pos.track;
      }
      if (st.isEmpty) continue;
      movements.add(DraftMovement(
        title: st,
        trackNo: pos.track,
        durationSec: _parseDuration(s['duration'] as String?),
      ));
    }

    out.add(DraftComposition(
      composer: composer,
      title: title,
      discNo: disc,
      trackFrom: first,
      trackTo: last,
      movements: movements,
      performerOverrides: overrides,
    ));
  }

  return out;
}
