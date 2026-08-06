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

  group('UPC-E 확장', () {
    // 규칙 검증: 무작위 20만건을 펼쳐 체크디지트를 대조했고(전 분기, 불일치 0),
    // 공개된 UPC-E/UPC-A 쌍 3건과도 일치했다.

    test('X6=0~2 — 세 번째 자리에 X6, 0 넷', () {
      expect(expandUpcE('04252614'), '042100005264');
    });

    test('X6=5~9 — 앞 다섯 자리 유지, 0 넷 뒤에 X6', () {
      expect(expandUpcE('01234565'), '012345000065');
      expect(expandUpcE('00641975'), '006419000075');
      expect(expandUpcE('02345673'), '023456000073');
    });

    test('X6=3 — 앞 세 자리 유지, 0 다섯', () {
      // 분기를 가르는 건 여섯 자리 중 **마지막** 자리다.
      expect(expandUpcE('01234531'), '012300000451');
    });

    test('X6=4 — 앞 네 자리 유지, 0 다섯', () {
      expect(expandUpcE('01234543'), '012340000053');
    });

    test('체크디지트가 안 맞으면 확장하지 않는다', () {
      // 8자리라고 다 UPC-E가 아니다 — EAN-8이거나 오인식일 수 있다.
      // 그런 값을 펼쳐 조회하면 엉뚱한 12자리를 묻게 된다.
      expect(expandUpcE('01234560'), isNull);
    });

    test('8자리가 아니면 null', () {
      expect(expandUpcE('123456789'), isNull);
      expect(expandUpcE('1234567'), isNull);
      expect(expandUpcE(''), isNull);
    });

    test('후보 목록에서 원본이 먼저, 확장형이 뒤에 온다', () {
      // 압축 표기 그대로 등록된 릴리스가 있으면 그쪽이 먼저 걸려야 한다.
      expect(discogsBarcodeCandidates('01234565'),
          ['01234565', '012345000065', '0012345000065']);
    });

    test('UPC-E가 아닌 8자리는 원본만 시도한다', () {
      expect(discogsBarcodeCandidates('12345678'), ['12345678']);
    });
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
