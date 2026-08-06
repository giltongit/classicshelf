// =============================================================================
// discogs_barcode_candidates_test.dart — 바코드 표기 후보 생성 (§17-28 §2-2)
//
// UPC-A(12자리)와 EAN-13(13자리)은 앞자리 0 하나 차이다. 스캐너가 준 자릿수와
// Discogs에 등록된 자릿수가 엇갈리면 같은 음반인데도 0건이 나온다.
// 이 후보 목록이 그 구간을 메운다.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mylibrary/services/discogs_service.dart';

void main() {
  test('첫 후보는 언제나 정규화한 원본이다', () {
    // 두 번째부터 걸리면 "포맷 불일치"였다는 뜻이라, 순서 자체가 진단 정보다.
    expect(discogsBarcodeCandidates('028947775782').first, '028947775782');
  });

  test('공백·하이픈 같은 인쇄 표기를 떼어낸다', () {
    // 실제 Discogs 등록값에 이런 표기가 섞여 있다.
    expect(discogsBarcodeCandidates('7 2064-24425-2 4').first, '720642442524');
  });

  test('UPC-A(12자리)는 앞에 0을 붙인 EAN-13도 시도한다', () {
    expect(discogsBarcodeCandidates('724381115022'),
        ['724381115022', '0724381115022']);
  });

  test('앞이 0인 EAN-13(13자리)은 0을 뗀 UPC-A도 시도한다', () {
    expect(discogsBarcodeCandidates('0724381115022'),
        ['0724381115022', '724381115022']);
  });

  test('앞이 0이 아닌 EAN-13은 변형이 없다 — 뗄 0이 없다', () {
    expect(discogsBarcodeCandidates('4053796003393'), ['4053796003393']);
  });

  test('같은 값이 두 번 들어가지 않는다', () {
    final c = discogsBarcodeCandidates('0000000000000');
    expect(c.length, c.toSet().length);
  });

  test('숫자가 하나도 없으면 빈 목록 — 검색을 아예 걸지 않는다', () {
    // 헛돌면 레이트리밋(25/min)만 축낸다.
    expect(discogsBarcodeCandidates('----'), isEmpty);
    expect(discogsBarcodeCandidates(''), isEmpty);
  });

  test('자릿수가 어정쩡하면 원본만 시도한다', () {
    // UPC-E(8자리)는 12자리로 펴야 Discogs와 맞지만 그 변환은 아직 없다.
    // 실제로 이 포맷이 스캔되는지를 [BARCODE] 로그로 먼저 확인한 뒤 판단한다.
    expect(discogsBarcodeCandidates('12345678'), ['12345678']);
  });

  group('검색 결과 바코드 대조 (verified 지표)', () {
    // Discogs의 barcode 검색은 완전 일치가 아니다 — 없는 바코드를 넣어도
    // 무관한 릴리스가 돌아온다(실측: "12345678" → 937건, 대조 일치 0건).
    // 그래서 "0건 = 미보유"가 성립하지 않고, 이 대조가 진짜 신호가 된다.

    test('인쇄 표기의 공백을 무시하고 같은 바코드로 본다', () {
      expect(
        discogsRowHasBarcode({
          'barcode': ['7 2064-24425-2 4'],
        }, '720642442524'),
        isTrue,
      );
    });

    test('UPC-A와 EAN-13의 앞자리 0 차이는 같은 것으로 본다', () {
      // 선행 0을 하나만 떼면 "0028947775782"와 "028947775782"가 어긋난다.
      expect(
        discogsRowHasBarcode({
          'barcode': ['0 28947 77578 2'],
        }, '0028947775782'),
        isTrue,
      );
      expect(
        discogsRowHasBarcode({
          'barcode': ['028947775782'],
        }, '28947775782'),
        isTrue,
      );
    });

    test('무관한 바코드는 걸러진다', () {
      expect(
        discogsRowHasBarcode({
          'barcode': ['4053796003393'],
        }, '720642442524'),
        isFalse,
      );
    });

    test('바코드 필드가 없거나 비면 false', () {
      expect(discogsRowHasBarcode(const {}, '720642442524'), isFalse);
      expect(
        discogsRowHasBarcode({'barcode': <String>[]}, '720642442524'),
        isFalse,
      );
    });

    test('부분 일치는 통과시키지 않는다', () {
      // Discogs 검색이 물어다 주는 노이즈가 정확히 이런 모양이다
      // (러너아웃 문자열에 숫자가 길게 박힌 릴리스).
      expect(
        discogsRowHasBarcode({
          'barcode': ['DT 005 - A 9999999999999999999999'],
        }, '9999999999999'),
        isFalse,
      );
    });
  });
}
