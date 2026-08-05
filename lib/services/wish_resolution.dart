// =============================================================================
// wish_resolution.dart — 위시 자동 해소 감지 (§17-21)
//
// "희망하던 걸 실제로 샀는데 위시에 그대로 남아 있다"를 없애는 규칙.
// 판정만 하고 아무것도 지우지 않는다 — 삭제는 사용자가 다이얼로그에서
// 승인한 것만 화면이 수행한다(강제 자동화 금지, §4-9).
//
// 트리거가 둘(앨범 저장 직후 / 위시 화면의 "지금 확인")이라 입력 형태를
// CompositionKey 목록 하나로 통일했다. 저장 직후 경로는 방금 만든 Album을
// compositionKeysOf로 변환해 같은 함수에 넣는다.
//
// 매칭 기준 — 정규화 후 완전 일치만 쓴다. 유사도(fuzzy)는 쓰지 않는다:
//   · 강한 매칭: 위시 workId == 수록곡 workId. 둘 다 정규 작품을 가리키므로
//     표기가 달라도 같은 곡이다.
//   · 약한 매칭: 위시에 workId가 없을 때만. composer와 title이 둘 다
//     (trim + 소문자) 기준으로 같아야 한다.
// 오탐보다 누락이 낫다. 놓친 건 사용자가 손으로 지우면 되지만, 잘못 지목한
// 항목은 사용자가 "제거" 체크를 그대로 두고 넘기면 조용히 사라진다.
// =============================================================================

import '../models/album.dart';
import '../models/wishlist_entry.dart';
import '../repositories/collection_repository.dart' show CompositionKey;

/// 해소된 것으로 보이는 위시 한 건 + 근거가 된 앨범 제목(다이얼로그 표시용).
typedef WishMatch = ({WishItem wish, String albumTitle});

/// Album 애그리게이트 → 매칭 키. 저장 직후 트리거가 쓴다(DB 재조회 불필요).
List<CompositionKey> compositionKeysOf(Album album) => album.compositions
    .map((c) => (
          albumId: album.id,
          albumTitle: album.title,
          workId: c.workId,
          composer: c.composer,
          title: c.title,
        ))
    .toList();

/// 대소문자·앞뒤 공백 차이는 같은 값으로 본다. 빈 문자열은 null로 접는다 —
/// "빈 값끼리 일치"로 엉뚱한 매칭이 서는 걸 막는다.
String? _norm(String? s) {
  final t = s?.trim().toLowerCase();
  return (t == null || t.isEmpty) ? null : t;
}

bool _matches(WishItem wish, CompositionKey key) {
  if (wish.workId != null) {
    return wish.workId == key.workId; // 강한 매칭
  }
  final wc = _norm(wish.composer);
  final wt = _norm(wish.title);
  if (wc == null || wt == null) return false; // 한쪽만으론 판정하지 않는다
  return wc == _norm(key.composer) && wt == _norm(key.title);
}

/// [wishes] 중 [keys]에 해당하는 소장 음반이 생긴 것들을 골라낸다.
/// 위시 하나가 여러 수록곡에 걸려도 한 번만 담는다(첫 근거 앨범을 남긴다).
List<WishMatch> findResolvedWishes(
  List<WishItem> wishes,
  List<CompositionKey> keys,
) {
  if (wishes.isEmpty || keys.isEmpty) return const [];
  final out = <WishMatch>[];
  for (final w in wishes) {
    for (final k in keys) {
      if (_matches(w, k)) {
        out.add((wish: w, albumTitle: k.albumTitle));
        break;
      }
    }
  }
  return out;
}
