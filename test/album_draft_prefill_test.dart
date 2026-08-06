// =============================================================================
// album_draft_prefill_test.dart — 초안 → 등록 폼 프리필 (대 2 자동입력)
//
// 확인하는 것: 바코드 조회 결과가 **기존 등록 폼에** 그대로 들어가는지.
// 새 화면을 만들지 않고 AddAlbumScreen을 재사용한 게 이 작업의 전제라,
// 폼이 초안을 받아 채우는 지점이 깨지면 자동입력 전체가 무의미해진다.
//
// 저장 경로(saveAlbum)는 건드리지 않았으므로 여기서 다시 보지 않는다 —
// save_album_replace_children_test.dart가 이미 지키고 있다.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylibrary/models/album_draft.dart';
import 'package:mylibrary/screens/add_book_screen.dart';

const _draft = AlbumDraft(
  title: 'The Symphonies',
  label: 'Deutsche Grammophon',
  releaseYear: 2008,
  discCount: 6,
  format: 'CD',
  barcode: '028947775782',
  defaultPerformers: [
    DraftPerformer(role: 'conductor', name: 'Herbert von Karajan'),
    DraftPerformer(role: 'orchestra', name: 'Berliner Philharmoniker'),
  ],
  compositions: [
    DraftComposition(
      composer: 'Ludwig van Beethoven',
      title: 'Symphony No. 1 In C Major, Op. 21',
      discNo: 1,
      trackFrom: 1,
      trackTo: 4,
      movements: [
        DraftMovement(title: 'Adagio Molto', trackNo: 1, durationSec: 465),
        DraftMovement(title: 'Andante Cantabile', trackNo: 2, durationSec: 364),
      ],
    ),
    DraftComposition(
      composer: 'Ludwig van Beethoven',
      title: 'Overture "Egmont", Op. 84',
      discNo: 1,
      trackFrom: 9,
      trackTo: 9,
    ),
  ],
  sourceName: 'Discogs',
  sourceUrl: 'https://www.discogs.com/release/2674825-The-Symphonies',
);

Future<void> _pump(WidgetTester tester, {AlbumDraft? draft}) async {
  // 폼은 긴 스크롤 한 장이라 기본 테스트 화면(800px)에서는 연주자·수록곡이
  // 화면 밖에 남아 위젯 트리에 올라오지 않는다. 세로로 넉넉한 화면을 준다.
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: AddAlbumScreen(draft: draft)),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('초안의 음반 기본정보가 폼에 들어간다', (tester) async {
    await _pump(tester, draft: _draft);

    expect(find.text('The Symphonies'), findsOneWidget);
    expect(find.text('Deutsche Grammophon'), findsOneWidget);
    expect(find.text('2008'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('연주자가 역할과 함께 들어간다', (tester) async {
    await _pump(tester, draft: _draft);

    expect(find.text('Herbert von Karajan'), findsOneWidget);
    expect(find.text('Berliner Philharmoniker'), findsOneWidget);
  });

  testWidgets('수록곡·악장이 카드로 들어간다', (tester) async {
    await _pump(tester, draft: _draft);

    // 수록곡 2곡 — 작곡가는 두 카드 모두 같은 값이라 2개가 잡힌다.
    expect(find.text('Ludwig van Beethoven'), findsNWidgets(2));
    expect(find.text('Symphony No. 1 In C Major, Op. 21'), findsOneWidget);
    expect(find.text('Overture "Egmont", Op. 84'), findsOneWidget);
  });

  testWidgets('출처 표기와 원본 링크가 폼 위에 뜬다 (§2-5 표기 의무)', (tester) async {
    await _pump(tester, draft: _draft);

    expect(find.text('Data provided by Discogs'), findsOneWidget);
    expect(find.text('원본'), findsOneWidget);
    expect(find.text('자동으로 채운 값입니다 — 저장 전에 확인해 주세요'), findsOneWidget);
  });

  testWidgets('초안 없이 열면 출처 표기가 없다 — 직접 입력에 Discogs 표기를 붙이지 않는다',
      (tester) async {
    await _pump(tester);

    expect(find.text('Data provided by Discogs'), findsNothing);
    expect(find.text('음반 등록'), findsOneWidget);
  });

  testWidgets('출처 링크가 없는 초안(조회 실패 후 바코드만)은 표기를 띄우지 않는다',
      (tester) async {
    // 일치하는 음반을 못 찾았을 때의 경로 — 바코드만 들고 빈 폼으로 간다.
    await _pump(tester, draft: const AlbumDraft(barcode: '028947775782'));

    expect(find.text('Data provided by Discogs'), findsNothing);
    // 수록곡이 없어도 빈 카드 하나로 입력을 이어갈 수 있어야 한다.
    expect(find.text('음반 등록'), findsOneWidget);
  });
}
