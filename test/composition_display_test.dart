// =============================================================================
// 수록곡 표시 우선순위 (§3-1a)
//   Work 매칭이 붙으면서 "무엇을 주 표시로 올리는가"가 분기를 갖게 됐다.
//   핵심은 매칭돼도 사용자가 적은 제목을 버리지 않는다는 것 — 발췌·편곡판 등
//   음반 고유 표기가 거기에만 있는 경우가 많다.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:mylibrary/screens/book_detail_screen.dart';

void main() {
  test('매칭 없음 + 제목 있음 → 제목이 주 표시, meta는 부가', () {
    final r = compositionDisplayLines(
      composer: 'J.S. Bach',
      catalogNumber: 'BWV 988',
      userTitle: '골드베르크 변주곡',
    );
    expect(r.heading, '골드베르크 변주곡');
    expect(r.meta, 'J.S. Bach · BWV 988');
    expect(r.showMeta, isTrue);
    expect(r.albumLabel, isNull);
  });

  test('매칭 없음 + 제목 없음 → meta가 주 표시, 아래 중복 없음', () {
    final r = compositionDisplayLines(
      composer: 'J.S. Bach',
      catalogNumber: 'BWV 988',
    );
    expect(r.heading, 'J.S. Bach · BWV 988');
    // 주 표시가 meta 자체이므로 같은 문자열을 아래 또 그리면 안 된다.
    expect(r.showMeta, isFalse);
    expect(r.albumLabel, isNull);
  });

  test('★ 매칭 있음 → 정규명이 주 표시, 사용자 표기는 보존된다', () {
    final r = compositionDisplayLines(
      composer: 'J.S. Bach',
      catalogNumber: 'BWV 988',
      userTitle: '골드베르크 (발췌)',
      canonicalTitle: 'Goldberg Variations',
    );
    expect(r.heading, 'Goldberg Variations');
    // 음반 고유 표기가 유실되지 않는다.
    expect(r.albumLabel, '골드베르크 (발췌)');
    expect(r.showMeta, isTrue);
  });

  test('매칭 있음 + 사용자 표기가 정규명과 같음 → 중복 줄 없음', () {
    final r = compositionDisplayLines(
      composer: 'J.S. Bach',
      userTitle: 'Goldberg Variations',
      canonicalTitle: 'Goldberg Variations',
    );
    expect(r.heading, 'Goldberg Variations');
    expect(r.albumLabel, isNull);
  });

  test('매칭 있음 + 사용자 제목 없음 → 정규명만', () {
    final r = compositionDisplayLines(
      composer: 'J.S. Bach',
      canonicalTitle: 'Goldberg Variations',
    );
    expect(r.heading, 'Goldberg Variations');
    expect(r.albumLabel, isNull);
    expect(r.meta, 'J.S. Bach');
    expect(r.showMeta, isTrue);
  });

  test('공백만 있는 값은 없는 것으로 본다', () {
    final r = compositionDisplayLines(
      composer: 'Mozart',
      catalogNumber: '   ',
      userTitle: '  ',
      canonicalTitle: '  ',
    );
    expect(r.heading, 'Mozart'); // meta로 폴백
    expect(r.meta, 'Mozart'); // 공백 catalogNumber가 ' · '로 붙지 않는다
    expect(r.showMeta, isFalse);
    expect(r.albumLabel, isNull);
  });
}
