// =============================================================================
// discogs_mapper_test.dart — Discogs 응답 → AlbumDraft 매핑 규칙 (§2-3)
//
// 픽스처는 실제 Discogs 응답을 저장한 게 아니라, 실측으로 확인한 **구조**만
// 본떠 손으로 쓴 것이다. 조회 결과를 리포지토리에 쌓아 두지 않기 위해서다
// (Discogs API Terms의 캐시·보관 제한 — discogs_service.dart 상단 주석 참고).
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mylibrary/models/album_draft.dart';
import 'package:mylibrary/services/discogs_mapper.dart';

/// 잘 정리된 클래식 박스세트를 본뜬 응답.
///   · tracklist가 heading / index(+sub_tracks) / track 세 종류를 모두 포함
///   · extraartists에 Composed By·Conductor·Orchestra + 제작 크레딧이 섞임
///   · identifiers에 Barcode 말고도 Matrix / Runout, Label Code가 섞임
///   · formats에 Box Set(상자)과 CD(매체)가 함께 들어감
Map<String, dynamic> _boxSet() => {
      'title': 'The Symphonies',
      'year': 2008,
      'uri': 'https://www.discogs.com/release/1-The-Symphonies',
      'labels': [
        {'name': 'Deutsche Grammophon', 'catno': '477 7578'},
      ],
      'formats': [
        {'name': 'CD', 'qty': '6', 'descriptions': ['Compilation']},
        {'name': 'Box Set', 'qty': '1', 'descriptions': ['Reissue']},
      ],
      'identifiers': [
        {'type': 'Matrix / Runout', 'value': '00289 477 789-6 02'},
        {'type': 'Barcode', 'value': '0 28947 77578 2'},
        {'type': 'Label Code', 'value': 'LC 0173'},
      ],
      'artists': [
        {'name': 'Ludwig van Beethoven'},
        {'name': 'Herbert von Karajan'},
      ],
      'extraartists': [
        {'role': 'Composed By', 'name': 'Ludwig van Beethoven'},
        {'role': 'Conductor', 'name': 'Herbert von Karajan'},
        {'role': 'Orchestra', 'name': 'Berliner Philharmoniker'},
        {'role': 'Engineer [Tonmeister, Balance Engineer]', 'name': 'G. Hermanns'},
        {'role': 'Liner Notes [English]', 'name': 'Richard Osborne (2)'},
        {'role': 'Producer [Recording]', 'name': 'Michel Glotz'},
      ],
      'tracklist': [
        {'type_': 'heading', 'position': '', 'title': 'Compact Disk 1'},
        {
          'type_': 'index',
          'position': '',
          'title': 'Symphony No. 1 In C Major, Op. 21',
          'duration': '23:01',
          'sub_tracks': [
            {'position': '1-1', 'title': 'Adagio Molto', 'duration': '7:45'},
            {'position': '1-2', 'title': 'Andante Cantabile', 'duration': '6:04'},
            {'position': '1-3', 'title': 'Menuetto', 'duration': '3:35'},
          ],
        },
        {
          'type_': 'track',
          'position': '1-9',
          'title': 'Overture "Egmont", Op. 84',
          'duration': '8:19',
        },
        {
          'type_': 'index',
          'position': '',
          'title': 'Symphony No. 9, Op. 125',
          'sub_tracks': [
            {'position': '2-1', 'title': 'Allegro', 'duration': '1:07:45'},
          ],
        },
      ],
    };

void main() {
  group('음반 기본정보', () {
    test('제목·레이블·연도·출처를 옮긴다', () {
      final d = mapDiscogsReleaseToDraft(_boxSet());
      expect(d.title, 'The Symphonies');
      expect(d.label, 'Deutsche Grammophon');
      expect(d.releaseYear, 2008);
      expect(d.sourceName, 'Discogs');
      expect(d.sourceUrl, 'https://www.discogs.com/release/1-The-Symphonies');
      expect(d.hasAttribution, isTrue);
    });

    test('discCount는 상자를 빼고 매체 장수만 센다', () {
      // format_quantity(=7)를 쓰면 상자까지 세어 한 장 더 나온다.
      expect(mapDiscogsReleaseToDraft(_boxSet()).discCount, 6);
    });

    test('year가 0이면 released에서 연도를 찾는다', () {
      final j = _boxSet()
        ..['year'] = 0
        ..['released'] = '1994-05-17';
      expect(mapDiscogsReleaseToDraft(j).releaseYear, 1994);
    });

    test('year도 released도 없으면 비운다 — 0을 연도로 저장하지 않는다', () {
      final j = _boxSet()..['year'] = 0;
      expect(mapDiscogsReleaseToDraft(j).releaseYear, isNull);
    });

    test('바코드는 Barcode 항목만 골라 숫자만 남긴다', () {
      // Matrix / Runout이 먼저 오지만 그건 바코드가 아니다.
      expect(mapDiscogsReleaseToDraft(_boxSet()).barcode, '028947775782');
    });

    test('바코드가 없으면 비운다', () {
      final j = _boxSet()..['identifiers'] = [
        {'type': 'Label Code', 'value': 'LC 0173'},
      ];
      expect(mapDiscogsReleaseToDraft(j).barcode, isNull);
    });
  });

  group('포맷 어휘', () {
    String? formatOf(List<Map<String, dynamic>> formats) =>
        mapDiscogsReleaseToDraft(_boxSet()..['formats'] = formats).format;

    test('Vinyl → LP (Discogs는 매체명이 Vinyl, LP는 설명에 있다)', () {
      expect(formatOf([
        {'name': 'Vinyl', 'qty': '2', 'descriptions': ['LP', 'Album']},
      ]), 'LP');
    });

    test('CD → CD', () {
      expect(formatOf([
        {'name': 'CD', 'qty': '1', 'descriptions': <String>[]},
      ]), 'CD');
    });

    test('SACD 하이브리드는 더 구체적인 SACD를 고른다', () {
      expect(formatOf([
        {'name': 'CD', 'qty': '1', 'descriptions': <String>[]},
        {'name': 'SACD', 'qty': '1', 'descriptions': ['Hybrid']},
      ]), 'SACD');
    });

    test('File → digital', () {
      expect(formatOf([
        {'name': 'File', 'qty': '12', 'descriptions': ['FLAC']},
      ]), 'digital');
    });

    test('모르는 매체(Cassette)는 비운다 — 드롭다운에 없는 값을 넣지 않는다', () {
      expect(formatOf([
        {'name': 'Cassette', 'qty': '1', 'descriptions': <String>[]},
      ]), isNull);
    });
  });

  group('연주자 크레딧', () {
    test('Conductor·Orchestra만 남기고 제작 크레딧은 버린다', () {
      final d = mapDiscogsReleaseToDraft(_boxSet());
      expect(d.defaultPerformers.map((p) => '${p.role}:${p.name}'), [
        'conductor:Herbert von Karajan',
        'orchestra:Berliner Philharmoniker',
      ]);
      // 엔지니어·라이너노트·프로듀서가 연주자로 새어 들어오면 안 된다.
      expect(
        d.defaultPerformers.any((p) => p.name.contains('Osborne')),
        isFalse,
      );
    });

    test('한 사람의 복수 역할을 쉼표로 나눈다', () {
      final j = _boxSet()..['extraartists'] = [
        {'role': 'Conductor, Piano', 'name': 'Daniel Barenboim'},
      ];
      final d = mapDiscogsReleaseToDraft(j);
      expect(d.defaultPerformers.map((p) => p.role),
          containsAll(['conductor', 'soloist']));
    });

    test('대괄호 안의 쉼표는 역할 구분자가 아니다', () {
      // "Engineer [Tonmeister, Balance Engineer]"가 두 역할로 쪼개지면
      // "Balance Engineer"가 별도 역할이 되어 버린다.
      final d = mapDiscogsReleaseToDraft(_boxSet());
      expect(d.defaultPerformers.length, 2);
    });

    test('대괄호 한정어를 떼고 기본 역할로 인식한다', () {
      final j = _boxSet()..['extraartists'] = [
        {'role': 'Violin [Solo]', 'name': 'Anne-Sophie Mutter'},
      ];
      final d = mapDiscogsReleaseToDraft(j);
      expect(d.defaultPerformers.single.role, 'soloist');
    });

    test('이름의 동명이인 번호와 별표를 뗀다', () {
      final j = _boxSet()..['extraartists'] = [
        {'role': 'Conductor', 'name': 'Karajan* (2)'},
      ];
      expect(mapDiscogsReleaseToDraft(j).defaultPerformers.single.name,
          'Karajan');
    });

    test('크레딧이 아예 없으면 빈 목록 — 억지로 만들지 않는다', () {
      final j = _boxSet()..['extraartists'] = <dynamic>[];
      expect(mapDiscogsReleaseToDraft(j).defaultPerformers, isEmpty);
    });

    test('성부는 "* Vocals" 접미사로 잡는다', () {
      // 실측: Discogs는 Soprano Vocals / Tenor Vocals / Mezzo-soprano Vocals
      // 처럼 성부 뒤에 Vocals를 붙인다. 성부만 나열하면 전부 놓친다.
      final j = _boxSet()..['extraartists'] = [
        {'role': 'Soprano Vocals', 'name': 'Kiri Te Kanawa'},
        {'role': 'Tenor Vocals', 'name': 'Luciano Pavarotti'},
        {'role': 'Mezzo-soprano Vocals', 'name': 'Cecilia Bartoli'},
        {'role': 'Treble Vocals', 'name': 'Aled Jones'},
      ];
      final d = mapDiscogsReleaseToDraft(j);
      expect(d.defaultPerformers.length, 4);
      expect(d.defaultPerformers.every((p) => p.role == 'vocalist'), isTrue);
    });

    test('Soprano Saxophone은 성악이 아니라 독주로 간다', () {
      // 성부 이름만 단독으로 잡으면 이걸 성악으로 오인한다.
      final j = _boxSet()..['extraartists'] = [
        {'role': 'Soprano Saxophone', 'name': 'Jan Garbarek'},
      ];
      expect(mapDiscogsReleaseToDraft(j).defaultPerformers.single.role,
          'soloist');
    });
  });

  group('작곡가', () {
    test('Composed By가 있으면 그걸 쓴다', () {
      final d = mapDiscogsReleaseToDraft(_boxSet());
      expect(d.compositions.first.composer, 'Ludwig van Beethoven');
    });

    test('Composed By가 없으면 artists[0]로 채운다 (클래식 크레딧 관행)', () {
      final j = _boxSet()..['extraartists'] = [
        {'role': 'Conductor', 'name': 'Herbert von Karajan'},
      ];
      final d = mapDiscogsReleaseToDraft(j);
      expect(d.compositions.first.composer, 'Ludwig van Beethoven');
    });

    test('artists[0]이 Various면 비운다 — 컴필레이션 오탐 방지', () {
      final j = _boxSet()
        ..['extraartists'] = <dynamic>[]
        ..['artists'] = [
          {'name': 'Various'},
        ];
      final d = mapDiscogsReleaseToDraft(j);
      expect(d.compositions.first.composer, '');
    });

    test('컴필레이션은 트랙 artists가 곧 작곡가다 (연주자는 extraartists로 빠진다)', () {
      // 실측: Various 컴필레이션 12트랙 중 Composed By 태그가 붙은 건 1건뿐이고,
      // 나머지는 트랙 artists에 작곡가(Barber·Satie·Puccini…)가, extraartists에
      // 연주자(Conductor·Orchestra·Soprano Vocals)가 들어 있었다.
      // 릴리스 artists가 Various라 이 경로가 없으면 컴필레이션 전체가 빈칸이 된다.
      final j = _boxSet()
        ..['artists'] = [
          {'name': 'Various'},
        ]
        ..['extraartists'] = <dynamic>[]
        ..['tracklist'] = [
          {
            'type_': 'track',
            'position': '1-1',
            'title': 'Adagio For Strings',
            'artists': [
              {'name': 'Samuel Barber'},
            ],
            'extraartists': [
              {'role': 'Conductor', 'name': 'Leonard Slatkin'},
            ],
          },
        ];
      expect(mapDiscogsReleaseToDraft(j).compositions.single.composer,
          'Samuel Barber');
    });

    test('트랙별 Composed By가 릴리스 단위보다 우선한다', () {
      final j = _boxSet();
      (j['tracklist'] as List)[2] = {
        'type_': 'track',
        'position': '1-9',
        'title': 'Ave Maria',
        'extraartists': [
          {'role': 'Composed By', 'name': 'Franz Schubert'},
        ],
      };
      final d = mapDiscogsReleaseToDraft(j);
      final ave = d.compositions.firstWhere((c) => c.title == 'Ave Maria');
      expect(ave.composer, 'Franz Schubert');
      // 나머지 곡은 릴리스 단위 작곡가를 그대로 쓴다.
      expect(d.compositions.first.composer, 'Ludwig van Beethoven');
    });
  });

  group('수록곡 / 악장 — index·sub_tracks 2단 구조', () {
    test('heading은 곡이 아니라 디스크 구분선이라 버린다', () {
      final d = mapDiscogsReleaseToDraft(_boxSet());
      expect(d.compositions.map((c) => c.title), isNot(contains('Compact Disk 1')));
      expect(d.compositions.length, 3);
    });

    test('index → 수록곡, sub_tracks → 악장', () {
      final c = mapDiscogsReleaseToDraft(_boxSet()).compositions.first;
      expect(c.title, 'Symphony No. 1 In C Major, Op. 21');
      expect(c.movements.map((m) => m.title),
          ['Adagio Molto', 'Andante Cantabile', 'Menuetto']);
    });

    test('디스크·트랙 번호를 하위 트랙에서 끌어올린다', () {
      // index 자신의 position은 비어 있다 — 번호는 sub_tracks에만 있다.
      final c = mapDiscogsReleaseToDraft(_boxSet()).compositions.first;
      expect(c.discNo, 1);
      expect(c.trackFrom, 1);
      expect(c.trackTo, 3);
    });

    test('단악장 곡(track)은 자기 position이 곧 트랙 번호다', () {
      final c = mapDiscogsReleaseToDraft(_boxSet()).compositions[1];
      expect(c.title, 'Overture "Egmont", Op. 84');
      expect(c.movements, isEmpty);
      expect(c.discNo, 1);
      expect(c.trackFrom, 9);
      expect(c.trackTo, 9);
    });

    test('디스크가 넘어가도 각 곡이 자기 디스크 번호를 갖는다', () {
      final c = mapDiscogsReleaseToDraft(_boxSet()).compositions[2];
      expect(c.discNo, 2);
      expect(c.trackFrom, 1);
    });

    test('재생시간 mm:ss / h:mm:ss 를 초로 바꾼다', () {
      final d = mapDiscogsReleaseToDraft(_boxSet());
      expect(d.compositions.first.movements.first.durationSec, 7 * 60 + 45);
      // 1:07:45 — 오페라 막·대곡에서 나온다.
      expect(d.compositions[2].movements.first.durationSec, 4065);
    });

    test('LP 면 표기(A1)는 트랙 번호로 바꾸지 않는다', () {
      // A1을 1번으로 우기면 B면 첫 곡과 번호가 겹친다.
      final j = _boxSet()..['tracklist'] = [
        {'type_': 'track', 'position': 'A1', 'title': 'Prelude'},
        {'type_': 'track', 'position': 'B1', 'title': 'Fugue'},
      ];
      final d = mapDiscogsReleaseToDraft(j);
      expect(d.compositions.every((c) => c.trackFrom == null), isTrue);
      expect(d.compositions.every((c) => c.discNo == null), isTrue);
      // 곡 자체는 살아남아야 한다 — 번호만 모르는 것이지 곡이 없는 게 아니다.
      expect(d.compositions.map((c) => c.title), ['Prelude', 'Fugue']);
    });

    test('제목이 빈 트랙은 버린다', () {
      final j = _boxSet()..['tracklist'] = [
        {'type_': 'track', 'position': '1', 'title': '   '},
      ];
      expect(mapDiscogsReleaseToDraft(j).compositions, isEmpty);
    });

    test('곡 제목의 괄호 숫자는 남긴다 — 제목의 일부일 수 있다', () {
      final j = _boxSet()..['tracklist'] = [
        {'type_': 'track', 'position': '1', 'title': 'Symphony No. 5 (1808)'},
      ];
      expect(mapDiscogsReleaseToDraft(j).compositions.single.title,
          'Symphony No. 5 (1808)');
    });
  });

  group('곡별 연주자 override (§17-29)', () {
    /// 앨범 기본은 지휘 Karajan / 관현악 BPO. 트랙마다 크레딧을 갈아 끼운다.
    Map<String, dynamic> withTrackCredits(List<Map<String, dynamic>> credits) =>
        _boxSet()
          ..['extraartists'] = [
            {'role': 'Conductor', 'name': 'Herbert von Karajan'},
            {'role': 'Orchestra', 'name': 'Berliner Philharmoniker'},
          ]
          ..['tracklist'] = [
            {
              'type_': 'track',
              'position': '1-1',
              'title': 'Track',
              'extraartists': credits,
            },
          ];

    DraftComposition only(Map<String, dynamic> j) =>
        mapDiscogsReleaseToDraft(j).compositions.single;

    test('트랙에 크레딧이 없으면 상속 — override는 null', () {
      final c = only(withTrackCredits(const []));
      expect(c.performerOverrides, isNull);
    });

    test('앨범 기본값과 같으면 상속 — 같은 값을 복사하지 않는다', () {
      // 복사해 두면 상속이 끊겨서, 나중에 앨범 지휘자를 고쳐도 이 곡만 옛 값에 남는다.
      final c = only(withTrackCredits([
        {'role': 'Conductor', 'name': 'Herbert von Karajan'},
        {'role': 'Orchestra', 'name': 'Berliner Philharmoniker'},
      ]));
      expect(c.performerOverrides, isNull);
    });

    test('다른 역할만 override에 담는다 — 같은 역할은 상속으로 남긴다', () {
      // 지휘자만 다르고 악단은 같은 경우. 악단까지 담으면 상속이 끊긴다.
      final c = only(withTrackCredits([
        {'role': 'Conductor', 'name': 'Carlos Kleiber'},
        {'role': 'Orchestra', 'name': 'Berliner Philharmoniker'},
      ]));
      expect(c.performerOverrides!.map((p) => '${p.role}:${p.name}'),
          ['conductor:Carlos Kleiber']);
    });

    test('앨범에 없던 역할이 트랙에 있으면 override로 담는다', () {
      final c = only(withTrackCredits([
        {'role': 'Piano', 'name': 'Martha Argerich'},
      ]));
      expect(c.performerOverrides!.single.role, 'soloist');
      expect(c.performerOverrides!.single.name, 'Martha Argerich');
    });

    test('한 역할에 연주자가 여럿이면 집합끼리 비교한다', () {
      final j = _boxSet()
        ..['extraartists'] = [
          {'role': 'Piano', 'name': 'Martha Argerich'},
          {'role': 'Piano', 'name': 'Nelson Freire'},
        ]
        ..['tracklist'] = [
          {
            'type_': 'track',
            'position': '1-1',
            'title': '같은 두 사람',
            'extraartists': [
              // 순서만 다르고 구성은 같다 — 상속이어야 한다.
              {'role': 'Piano', 'name': 'Nelson Freire'},
              {'role': 'Piano', 'name': 'Martha Argerich'},
            ],
          },
          {
            'type_': 'track',
            'position': '1-2',
            'title': '한 사람만',
            'extraartists': [
              {'role': 'Piano', 'name': 'Martha Argerich'},
            ],
          },
        ];
      final cs = mapDiscogsReleaseToDraft(j).compositions;
      expect(cs[0].performerOverrides, isNull);
      // 구성이 줄었으면 다른 값이다 — override로 담아야 한다.
      expect(cs[1].performerOverrides!.length, 1);
    });

    test('Composed By는 연주자 override로 새어 들어가지 않는다', () {
      final c = only(withTrackCredits([
        {'role': 'Composed By', 'name': 'Franz Schubert'},
      ]));
      expect(c.performerOverrides, isNull);
      expect(c.composer, 'Franz Schubert');
    });

    test('매핑 안 되는 역할만 있으면 override는 null', () {
      // Performer·Strings 같은 모호한 역할은 버린다(§2-2) —
      // 버린 결과가 빈 리스트가 아니라 null이어야 상속이 유지된다.
      final c = only(withTrackCredits([
        {'role': 'Performer', 'name': '아무개'},
        {'role': 'Producer', 'name': '아무개2'},
      ]));
      expect(c.performerOverrides, isNull);
    });

    test('다악장 작품도 index의 크레딧으로 override를 만든다', () {
      final j = _boxSet()
        ..['extraartists'] = [
          {'role': 'Conductor', 'name': 'Herbert von Karajan'},
        ]
        ..['tracklist'] = [
          {
            'type_': 'index',
            'position': '',
            'title': 'Piano Concerto No. 1',
            'extraartists': [
              {'role': 'Conductor', 'name': 'Claudio Abbado'},
              {'role': 'Piano', 'name': 'Maurizio Pollini'},
            ],
            'sub_tracks': [
              {'position': '1-1', 'title': 'Allegro', 'duration': '20:00'},
            ],
          },
        ];
      final c = mapDiscogsReleaseToDraft(j).compositions.single;
      expect(c.movements.length, 1);
      expect(c.performerOverrides!.map((p) => '${p.role}:${p.name}'),
          ['conductor:Claudio Abbado', 'soloist:Maurizio Pollini']);
    });

    test('컴필레이션: 곡마다 다른 지휘자·독주자가 각자 override로 붙는다', () {
      final j = _boxSet()
        ..['artists'] = [
          {'name': 'Various'},
        ]
        // 컴필레이션은 릴리스 단위 연주자가 없는 게 보통이다.
        ..['extraartists'] = <dynamic>[]
        ..['tracklist'] = [
          {
            'type_': 'track',
            'position': '1-1',
            'title': 'Adagio For Strings',
            'artists': [
              {'name': 'Samuel Barber'},
            ],
            'extraartists': [
              {'role': 'Conductor', 'name': 'Leonard Slatkin'},
              {'role': 'Orchestra', 'name': 'St. Louis Symphony'},
            ],
          },
          {
            'type_': 'track',
            'position': '1-2',
            'title': 'Gymnopédie No. 1',
            'artists': [
              {'name': 'Erik Satie'},
            ],
            'extraartists': [
              {'role': 'Piano', 'name': 'Pascal Rogé'},
            ],
          },
        ];
      final d = mapDiscogsReleaseToDraft(j);
      expect(d.defaultPerformers, isEmpty);
      expect(d.compositions[0].composer, 'Samuel Barber');
      expect(d.compositions[0].performerOverrides!.map((p) => p.name),
          ['Leonard Slatkin', 'St. Louis Symphony']);
      expect(d.compositions[1].composer, 'Erik Satie');
      expect(d.compositions[1].performerOverrides!.single.name, 'Pascal Rogé');
    });
  });

  group('빈 응답을 견딘다', () {
    test('필드가 통째로 없어도 터지지 않는다', () {
      final d = mapDiscogsReleaseToDraft(<String, dynamic>{});
      expect(d.title, isNull);
      expect(d.compositions, isEmpty);
      expect(d.defaultPerformers, isEmpty);
    });

    test('타입이 어긋나도(문자열 대신 숫자 등) 터지지 않는다', () {
      final d = mapDiscogsReleaseToDraft({
        'title': 'X',
        'labels': 'not-a-list',
        'formats': 42,
        'identifiers': null,
        'tracklist': {'unexpected': 'shape'},
        'extraartists': 'nope',
      });
      expect(d.title, 'X');
      expect(d.compositions, isEmpty);
    });
  });

  group('이름 정리 헬퍼', () {
    test('별표·동명이인 번호를 뗀다', () {
      expect(discogsCleanName('Beethoven*'), 'Beethoven');
      expect(discogsCleanName('Richard Osborne (2)'), 'Richard Osborne');
    });

    test('검색 결과 제목은 별표만 떼고 괄호 숫자는 남긴다', () {
      expect(
        discogsCleanSearchTitle('Beethoven* - Karajan* - Symphony (2)'),
        'Beethoven - Karajan - Symphony (2)',
      );
    });
  });
}
