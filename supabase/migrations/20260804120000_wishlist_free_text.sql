-- =============================================================================
-- wishlist.composer / wishlist.title — 희망 항목 자유 텍스트 (§6-2)
-- =============================================================================
-- 지금까지 wishlist는 FK 전용이었다: album_id(소장 앨범) 또는 work_id(정규 작품)
-- 중 하나가 반드시 있어야 CHECK를 통과했다. 그런데
--   · works 시드(대 1-A)가 미착수라 work_id로 가리킬 행이 없고,
--   · albums는 "소장 컬렉션"이라 위시를 담으면 서가·집계가 오염된다
-- → 결과적으로 위시 항목을 만들 방법 자체가 없었다.
--
-- compositions.title 선례(20260727080019, §3-1a)와 동일한 해법을 적용한다:
-- FK 없이도 사람이 읽는 이름을 자유 텍스트로 담고, FK는 "확정 연결" 자리로 남긴다.
--   · composer / title = 사용자가 적은 자유 텍스트. 지금 위시를 표현하는 주 수단.
--   · album_id / work_id = 확정 연결. Works 시드·자동 해소 감지가 붙는 이후 작업에서
--                          채운다(§17 부채). 지금은 보통 null.
--
-- CHECK는 "type별로 허용되는 칸 중 최소 하나는 채워져야 한다"로 완화한다.
-- type=album ↔ work_id, type=work ↔ album_id 의 상호 배제는 유지 — 유형과
-- 어긋난 FK가 붙는 것은 여전히 정합 위반이다.
-- =============================================================================

alter table public.wishlist add column composer text;
alter table public.wishlist add column title    text;

alter table public.wishlist drop constraint wishlist_target_ck;

alter table public.wishlist add constraint wishlist_target_ck check (
  (type = 'album' and work_id  is null
     and (album_id is not null or composer is not null or title is not null))
  or
  (type = 'work'  and album_id is null
     and (work_id  is not null or composer is not null or title is not null))
);
