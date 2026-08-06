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

import '../models/album.dart';
import '../models/album_draft.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 진입점
// ─────────────────────────────────────────────────────────────────────────────

AlbumDraft mapDiscogsReleaseToDraft(Map<String, dynamic> j) {
  final releaseCredits = _parseCredits(j['extraartists']);

  return AlbumDraft(
    title: _nullIfEmpty(j['title'] as String?),
    label: _firstLabel(j['labels']),
    releaseYear: _year(j),
    discCount: _discCount(j),
    format: _format(j['formats']),
    barcode: _barcode(j['identifiers']),
    defaultPerformers: _performers(releaseCredits),
    compositions: _compositions(
      j['tracklist'],
      fallbackComposer: _composer(releaseCredits, j['artists']),
    ),
    sourceName: 'Discogs',
    sourceUrl: _nullIfEmpty(j['uri'] as String?),
  );
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
  'vocals', 'voice', 'soprano', 'mezzo-soprano', 'mezzo soprano', 'alto',
  'contralto', 'countertenor', 'counter-tenor', 'tenor', 'baritone',
  'bass-baritone', 'bass vocals', 'narrator', 'speaker',
};
// 독주 악기. 클래식에서 실제로 보이는 것 위주 — 없는 악기는 그냥 안 잡힐 뿐이라
// 사용자가 직접 넣으면 된다(잘못 잡는 것보다 낫다).
const _soloistRoles = {
  'soloist', 'piano', 'fortepiano', 'harpsichord', 'organ', 'celesta',
  'violin', 'viola', 'cello', 'violoncello', 'double bass', 'contrabass',
  'viola da gamba', 'lute', 'theorbo', 'guitar', 'harp', 'mandolin',
  'flute', 'recorder', 'oboe', 'oboe d\'amore', 'clarinet', 'bassoon',
  'horn', 'french horn', 'trumpet', 'trombone', 'tuba', 'cornet',
  'saxophone', 'piccolo', 'percussion', 'timpani', 'accordion',
};

List<DraftPerformer> _performers(_Credits credits) {
  final out = <DraftPerformer>[];
  final seen = <String>{}; // 역할+이름 중복(복수 역할 표기) 제거

  void take(Set<String> roles, PerformerRole target) {
    for (final entry in credits.entries) {
      if (!roles.contains(entry.key)) continue;
      for (final name in entry.value) {
        final key = '${target.value}|$name';
        if (seen.add(key)) {
          out.add(DraftPerformer(role: target.value, name: name));
        }
      }
    }
  }

  // 지휘자·악단이 목록 위쪽에 오도록 순서를 고정한다(폼에서 보이는 순서).
  take(_conductorRoles, PerformerRole.conductor);
  take(_orchestraRoles, PerformerRole.orchestra);
  take(_ensembleRoles, PerformerRole.ensemble);
  take(_soloistRoles, PerformerRole.soloist);
  take(_vocalistRoles, PerformerRole.vocalist);

  return out;
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
    final trackComposer = _composer(_parseCredits(t['extraartists']), t['artists']);
    final composer = trackComposer.isNotEmpty ? trackComposer : fallbackComposer;

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
    ));
  }

  return out;
}
