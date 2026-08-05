// =============================================================================
// csv_service.dart — 앨범 CSV 내보내기 / 가져오기 (대 1-H)
//
// 용도 두 가지: 대량 등록(스프레드시트에서 만들어 한 번에)과 백업·이관.
// 그래서 **왕복(export → import)이 같은 데이터를 돌려주는 것**을 형식의 기준으로
// 삼는다 — 사람이 손으로 고치기 쉬운 것보다 이게 우선이다.
//
// 행 단위 = 수록곡. 앨범 열은 같은 앨범의 행마다 반복된다(스프레드시트에서
// 흔한 비정규화 형태 — 정렬·필터가 그대로 먹는다).
// 수록곡이 없는 앨범도 수록곡 열만 비운 행 하나로 남겨 왕복에서 사라지지 않게 한다.
//
// 한 칸에 여러 값을 담는 곳이 둘 있다(연주자·악장). CSV 자체가 중첩을 못 담아
// 어쩔 수 없이 쓰는 구분자이고, 그 한계는 아래 각 상수 주석에 적어 둔다.
// =============================================================================

import 'package:csv/csv.dart';

import '../models/album.dart';

/// 열 순서. **바꾸면 기존 CSV 가져오기가 깨진다** — 가져오기는 헤더 이름으로
/// 열을 찾으므로 순서 자체는 자유롭지만, 내보낸 파일을 손으로 다루는 사람이
/// 있으니 함부로 흔들지 않는다.
const List<String> kCsvHeader = [
  'album_id',
  'album_title',
  'label',
  'release_year',
  'format',
  'disc_count',
  'location',
  'acquired_at',
  'review',
  'performers',
  'composer',
  'work_title',
  'catalog_number',
  'disc_no',
  'track_from',
  'track_to',
  'movements',
];

/// 연주자 묶음 구분자. `역할:이름` 을 `;` 로 잇는다 (예: `conductor:Karajan;orchestra:BPO`).
/// 역할은 enum이라 안전하고, 이름에 `:` 가 있어도 **첫 번째** `:` 로만 잘라 살린다.
/// 이름에 `;` 가 들어가면 갈라진다 — 실제로 거의 없어 감수한다.
const String _multiSep = ';';

/// 악장 묶음. `트랙:제목` 을 `;` 로 잇는다. 트랙이 없으면 `:제목`.
/// 제목에 `:` 가 흔해서(예: `II. Andante: cantabile`) 트랙을 앞에 두고
/// 첫 번째 `:` 로만 자른다 — 제목 쪽 콜론은 그대로 보존된다.
const String _pairSep = ':';

// ── 내보내기 ────────────────────────────────────────────────────────────────

String buildAlbumCsv(List<Album> albums) {
  final rows = <List<String>>[kCsvHeader];
  for (final a in albums) {
    final albumCols = [
      a.id,
      a.title,
      a.label ?? '',
      a.releaseYear?.toString() ?? '',
      a.format ?? '',
      a.discCount.toString(),
      a.location ?? '',
      _dateToText(a.acquiredAt),
      a.review ?? '',
      _packPerformers(a.defaultPerformers),
    ];
    if (a.compositions.isEmpty) {
      rows.add([...albumCols, '', '', '', '', '', '', '']);
      continue;
    }
    final sorted = [...a.compositions]..sort((x, y) => x.seq.compareTo(y.seq));
    for (final c in sorted) {
      rows.add([
        ...albumCols,
        c.composer,
        c.title ?? '',
        c.catalogNumber ?? '',
        c.discNo?.toString() ?? '',
        c.trackFrom?.toString() ?? '',
        c.trackTo?.toString() ?? '',
        _packMovements(c.movements),
      ]);
    }
  }
  return const ListToCsvConverter().convert(rows);
}

String _packPerformers(List<Performer> ps) => ps
    .map((p) => '${p.role.name}$_pairSep${p.name}')
    .join(_multiSep);

String _packMovements(List<Movement> ms) {
  final sorted = [...ms]..sort((a, b) => a.seq.compareTo(b.seq));
  return sorted
      .map((m) => '${m.trackNo?.toString() ?? ''}$_pairSep${m.title}')
      .join(_multiSep);
}

String _dateToText(DateTime? d) => d == null
    ? ''
    : '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

// ── 가져오기 ────────────────────────────────────────────────────────────────

/// 가져오기 결과. 실패를 예외로 던지지 않고 경고 목록으로 돌려준다 —
/// 스프레드시트 한 줄이 이상하다고 나머지 200줄을 버릴 이유가 없다.
typedef CsvImportResult = ({
  List<Album> albums,
  int dataRows,
  List<String> warnings,
});

/// CSV 본문 → Album 애그리게이트 목록.
///
/// 식별: `album_id` 가 있으면 그대로 쓴다 — 백업을 다시 넣으면 같은 앨범을
/// **갱신**하지(중복 생성이 아니라) 만든다. 비어 있으면 제목 기준으로 묶고
/// 새 uuid를 발급한다.
///
/// 수록곡·악장 id는 언제나 새로 발급한다. saveAlbum이 하위를 통째 교체하므로
/// (§3-2) 하위 id를 보존할 이유가 없고, 보존하려면 열이 두 개 더 필요해진다.
CsvImportResult parseAlbumCsv(String content, {required String Function() newId}) {
  final warnings = <String>[];
  // 줄바꿈을 먼저 통일한다. 내보내기는 CRLF로 쓰고 스프레드시트도 대개 CRLF라,
  // eol을 '\n'으로 두면 각 줄 마지막 칸에 '\r'이 남는다. 지금은 cell()의 trim이
  // 걷어내 주지만 그건 우연에 기대는 것이라 입구에서 정리한다.
  final table = const CsvToListConverter(shouldParseNumbers: false)
      .convert(content.replaceAll('\r\n', '\n'), eol: '\n');
  if (table.isEmpty) {
    return (albums: const <Album>[], dataRows: 0, warnings: ['빈 파일입니다']);
  }

  // 헤더는 이름으로 찾는다 — 열 순서가 달라도, 모르는 열이 끼어 있어도 된다.
  final header = table.first.map((e) => e.toString().trim().toLowerCase()).toList();
  final idx = <String, int>{
    for (var i = 0; i < header.length; i++) header[i]: i,
  };
  if (!idx.containsKey('album_title')) {
    return (
      albums: const <Album>[],
      dataRows: 0,
      warnings: ['album_title 열이 없습니다 — 내보내기로 만든 형식인지 확인해 주세요'],
    );
  }

  String cell(List<dynamic> row, String name) {
    final i = idx[name];
    if (i == null || i >= row.length) return '';
    return row[i]?.toString().trim() ?? '';
  }

  // 같은 앨범의 행을 모은다. 입력 순서를 보존해야 수록곡 seq가 파일 순서와 같다.
  final order = <String>[];
  final grouped = <String, List<List<dynamic>>>{};

  for (var r = 1; r < table.length; r++) {
    final row = table[r];
    if (row.every((c) => (c?.toString().trim() ?? '').isEmpty)) continue;

    final title = cell(row, 'album_title');
    if (title.isEmpty) {
      warnings.add('${r + 1}행: album_title 이 비어 건너뜁니다');
      continue;
    }
    final id = cell(row, 'album_id');
    final key = id.isNotEmpty ? 'id:$id' : 'title:$title';
    if (!grouped.containsKey(key)) order.add(key);
    (grouped[key] ??= []).add(row);
  }

  final albums = <Album>[];
  var dataRows = 0;

  for (final key in order) {
    final rows = grouped[key]!;
    final first = rows.first;
    dataRows += rows.length;

    final compositions = <Composition>[];
    for (final row in rows) {
      final composer = cell(row, 'composer');
      final workTitle = cell(row, 'work_title');
      // 수록곡 열이 통째로 빈 행 = 수록곡 없는 앨범을 표현한 행. 경고 대상 아님.
      if (composer.isEmpty && workTitle.isEmpty) continue;
      if (composer.isEmpty) {
        warnings.add('「$workTitle」: composer 가 비어 이 수록곡을 건너뜁니다');
        continue;
      }
      compositions.add(Composition(
        id: newId(),
        composer: composer,
        title: workTitle.isEmpty ? null : workTitle,
        catalogNumber: _nullIfEmpty(cell(row, 'catalog_number')),
        discNo: int.tryParse(cell(row, 'disc_no')),
        trackFrom: int.tryParse(cell(row, 'track_from')),
        trackTo: int.tryParse(cell(row, 'track_to')),
        seq: compositions.length,
        movements: _unpackMovements(cell(row, 'movements'), newId),
        // 곡별 연주자 예외는 CSV로 다루지 않는다 — 앨범 기본값을 상속한다는
        // 뜻으로 null을 넣는다(빈 리스트가 아니다, §3-2).
        performerOverrides: null,
      ));
    }

    final rawId = cell(first, 'album_id');
    albums.add(Album(
      id: rawId.isEmpty ? newId() : rawId,
      title: cell(first, 'album_title'),
      label: _nullIfEmpty(cell(first, 'label')),
      releaseYear: int.tryParse(cell(first, 'release_year')),
      discCount: int.tryParse(cell(first, 'disc_count')) ?? 1,
      format: _nullIfEmpty(cell(first, 'format')),
      location: _nullIfEmpty(cell(first, 'location')),
      review: _nullIfEmpty(cell(first, 'review')),
      acquiredAt: DateTime.tryParse(cell(first, 'acquired_at')),
      defaultPerformers: _unpackPerformers(cell(first, 'performers'), newId),
      compositions: compositions,
    ));
  }

  return (albums: albums, dataRows: dataRows, warnings: warnings);
}

List<Performer> _unpackPerformers(String raw, String Function() newId) {
  if (raw.trim().isEmpty) return const [];
  final out = <Performer>[];
  for (final part in raw.split(_multiSep)) {
    final t = part.trim();
    if (t.isEmpty) continue;
    final sep = t.indexOf(_pairSep);
    // 역할이 없으면 unknown으로 받는다 — 이름만 적어 넣는 사용을 막지 않는다.
    final role = sep < 0 ? '' : t.substring(0, sep).trim();
    final name = sep < 0 ? t : t.substring(sep + 1).trim();
    if (name.isEmpty) continue;
    out.add(Performer(
      id: newId(),
      role: PerformerRole.fromString(role),
      name: name,
    ));
  }
  return out;
}

List<Movement> _unpackMovements(String raw, String Function() newId) {
  if (raw.trim().isEmpty) return const [];
  final out = <Movement>[];
  for (final part in raw.split(_multiSep)) {
    final t = part.trim();
    if (t.isEmpty) continue;
    final sep = t.indexOf(_pairSep);
    final track = sep < 0 ? '' : t.substring(0, sep).trim();
    final title = sep < 0 ? t : t.substring(sep + 1).trim();
    if (title.isEmpty) continue;
    out.add(Movement(
      id: newId(),
      seq: out.length,
      title: title,
      trackNo: int.tryParse(track),
    ));
  }
  return out;
}

String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();
