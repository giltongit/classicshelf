// =============================================================================
// seed_works.dart — Open Opus 덤프 → Supabase works/work_aliases 적재 (대 1-A)
//
// 참조 데이터(§3-9) 3단계 하이브리드의 1단계. 재실행 가능한 관리 스크립트로
// 남긴다 — 덤프가 갱신되면 그냥 다시 돌리면 된다(§17-3의 메커니즘 절반).
//
// 실행:
//   dart run tool/seed_works.dart --dry-run --composers 5   # 미리보기
//   dart run tool/seed_works.dart --composers 5             # 소규모 적재
//   dart run tool/seed_works.dart                           # 전체 적재
//
// 자격증명: env/admin.json (gitignore된 env/*.json 규칙에 걸린다)
//   {
//     "SUPABASE_URL": "https://<ref>.supabase.co",
//     "SUPABASE_SERVICE_ROLE_KEY": "<service_role key>"
//   }
//   · 참조 테이블은 RLS가 SELECT만 허용(INSERT 정책 0)이라 service_role로
//     우회해야 한다(§12).
//   · 앱이 읽는 env/dev.json과 **분리**한다. dev.json은
//     --dart-define-from-file로 앱 빌드에 주입되므로, service_role 키를 거기
//     두면 클라이언트 바이너리에 딸려 들어갈 여지가 생긴다. 이 스크립트는
//     dart:io로 파일을 직접 읽으므로 dart-define이 필요 없다.
//   · 키를 인자·환경변수·로그로 흘리지 않는다. 아래 어디에도 출력하지 않는다.
//
// 라이선스: Open Opus 데이터는 퍼블릭 도메인(§2-0). MusicBrainz(§17-1)와 달리
//   필드별 검토가 필요 없다.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

const _dumpUrl = 'https://api.openopus.org/work/dump.json';
const _chunkSize = 500;

/// 결정론적 id의 네임스페이스. **이 값을 바꾸면 모든 work id가 바뀐다.**
/// compositions.work_id가 이 id를 참조하기 시작하면(대 2 Work 매칭) FK가
/// 끊어지므로 사실상 고정값으로 취급할 것(§3-2).
const _namespace = '6f1d5c9e-3a0b-4f52-9d84-1c7e2b8a4f60';

const _uuid = Uuid();

void main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final composerLimit = _intFlag(args, '--composers');

  // --dry-run은 전송하지 않으므로 자격증명을 요구하지 않는다(매핑만 확인).
  final creds = dryRun ? null : _readCredentials();

  stdout.writeln('▶ Open Opus 덤프 내려받는 중…');
  final dump = await _fetchDump();
  var composers = (dump['composers'] as List).cast<Map<String, dynamic>>();
  stdout.writeln('  작곡가 ${composers.length}명');

  if (composerLimit != null && composerLimit < composers.length) {
    composers = composers.take(composerLimit).toList();
    stdout.writeln('  → 상위 $composerLimit명만 처리(--composers)');
  }

  // ── 매핑 (§3-3) ──────────────────────────────────────────────────────────
  final works = <String, Map<String, dynamic>>{}; // id → row (id로 중복 제거)
  final aliases = <String, Map<String, dynamic>>{};
  var rawWorkCount = 0;
  var collisions = 0;

  for (final c in composers) {
    // complete_name이 사람이 읽는 정식 이름. 없으면 짧은 name으로 폴백.
    final composer = _str(c['complete_name']) ?? _str(c['name']);
    if (composer == null) continue;

    for (final w in (c['works'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final title = _str(w['title']);
      if (title == null) continue;
      rawWorkCount++;

      // 덤프에 안정적인 외부 id가 없어 (작곡가|작품명)에서 결정론적으로 만든다.
      // 같은 입력 → 같은 id → 재실행해도 upsert가 중복을 만들지 않는다(§3-2).
      final id = _uuid.v5(_namespace, '$composer|$title');
      if (works.containsKey(id)) {
        // 같은 작곡가에 같은 제목이 두 번 나오는 경우. 한 배치에 같은 키를
        // 두 번 보내면 PostgREST가 거부하므로("cannot affect row a second
        // time") 여기서 접어야 한다.
        collisions++;
        continue;
      }

      works[id] = {
        'id': id,
        'composer': composer,
        // 작품번호·조성은 별도 필드가 없다. title에 섞여 있어도 정규식으로
        // 뽑지 않는다 — 오탐 위험이 크고, 원문 보존이 §3-1a의 철학이다.
        'title': title,
        'genre': _str(w['genre']),
        'period': _str(c['epoch']), // 시대는 작곡가 단위 필드
        'popular': _flag(w['popular']),
        'recommended': _flag(w['recommended']),
        'source': 'openopus',
      };

      // searchterms는 대부분 빈 문자열이다. 값이 있을 때만 별칭으로 넣는다.
      final terms = _str(w['searchterms']);
      if (terms != null) {
        final aliasId = _uuid.v5(_namespace, 'alias|$id|$terms');
        aliases[aliasId] = {
          'id': aliasId,
          'work_id': id,
          'alias': terms,
        };
      }
    }
  }

  stdout
    ..writeln('▶ 매핑 완료')
    ..writeln('  원본 작품 $rawWorkCount건 → 고유 ${works.length}건'
        '${collisions > 0 ? ' (중복 $collisions건 접음)' : ''}')
    ..writeln('  별칭 ${aliases.length}건');

  if (dryRun) {
    stdout.writeln('\n▶ --dry-run: 전송하지 않고 샘플 3건만 출력\n');
    for (final row in works.values.take(3)) {
      stdout.writeln('  ${const JsonEncoder.withIndent('  ').convert(row)}');
    }
    return;
  }

  // ── 적재 ─────────────────────────────────────────────────────────────────
  final (:url, :key) = creds!;
  await _upsertAll(url, key, 'works', works.values.toList());
  if (aliases.isNotEmpty) {
    await _upsertAll(url, key, 'work_aliases', aliases.values.toList());
  }

  stdout.writeln('\n✅ 완료 — works ${works.length}건 / '
      'work_aliases ${aliases.length}건');
  stdout.writeln('   Table Editor에서 row count 확인할 것.');
}

// ── 적재 ────────────────────────────────────────────────────────────────────

Future<void> _upsertAll(
  String baseUrl,
  String key,
  String table,
  List<Map<String, dynamic>> rows,
) async {
  stdout.writeln('▶ $table 적재 — ${rows.length}건'
      ' ($_chunkSize건씩 ${(rows.length / _chunkSize).ceil()}회)');

  for (var i = 0; i < rows.length; i += _chunkSize) {
    final chunk = rows.sublist(
        i, i + _chunkSize > rows.length ? rows.length : i + _chunkSize);

    final res = await http.post(
      Uri.parse('$baseUrl/rest/v1/$table'),
      headers: {
        'apikey': key,
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
        // 결정론적 id라 재실행 시 insert가 아니라 update로 흡수된다.
        'Prefer': 'resolution=merge-duplicates,return=minimal',
      },
      body: jsonEncode(chunk),
    );

    if (res.statusCode >= 300) {
      // 본문에 키는 들어가지 않는다(요청 헤더에만 있음).
      stderr.writeln('\n✗ $table 청크 실패 (offset $i, '
          'HTTP ${res.statusCode})\n  ${res.body}');
      exit(1);
    }

    final done = i + chunk.length;
    stdout.write('\r  $done / ${rows.length}');
  }
  stdout.writeln();
}

// ── 입력 ────────────────────────────────────────────────────────────────────

Future<Map<String, dynamic>> _fetchDump() async {
  final res = await http.get(Uri.parse(_dumpUrl));
  if (res.statusCode != 200) {
    stderr.writeln('✗ 덤프 내려받기 실패: HTTP ${res.statusCode}');
    exit(1);
  }
  return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
}

({String url, String key}) _readCredentials() {
  final file = File('env/admin.json');
  if (!file.existsSync()) {
    stderr.writeln('''
✗ env/admin.json 이 없습니다.

  Supabase 대시보드 → Project Settings → API → service_role 키를 복사해
  아래 형태로 만드세요(env/*.json 은 gitignore 대상입니다):

  {
    "SUPABASE_URL": "https://bxjjychftwuaipmxsqyo.supabase.co",
    "SUPABASE_SERVICE_ROLE_KEY": "eyJ..."
  }

  service_role 키는 RLS를 전면 우회합니다. 커밋·공유 금지.
''');
    exit(1);
  }

  final j = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final url = _str(j['SUPABASE_URL']);
  final key = _str(j['SUPABASE_SERVICE_ROLE_KEY']);
  if (url == null || key == null) {
    stderr.writeln('✗ env/admin.json 에 SUPABASE_URL / '
        'SUPABASE_SERVICE_ROLE_KEY 가 필요합니다.');
    exit(1);
  }
  return (url: url.replaceAll(RegExp(r'/+$'), ''), key: key);
}

// ── 변환 ────────────────────────────────────────────────────────────────────

/// 빈 문자열·공백만인 값은 null로 접는다(덤프에 빈 문자열이 흔하다).
String? _str(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// Open Opus는 "0"/"1" 문자열로 준다.
bool _flag(Object? v) => v == true || v == 1 || v == '1';

int? _intFlag(List<String> args, String name) {
  final i = args.indexOf(name);
  if (i == -1 || i + 1 >= args.length) return null;
  return int.tryParse(args[i + 1]);
}
