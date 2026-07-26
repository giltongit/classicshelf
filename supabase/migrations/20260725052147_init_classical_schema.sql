-- =============================================================================
-- 클래식 음반 컬렉션 앱 — 초기 스키마 (아키텍처 v03 §3-6)
-- =============================================================================
-- 계층: Works(참조) ─ WorkMovements ─ WorkAliases
--       Albums(사용자) ─ Compositions ─ Movements  (+ 연주자 상속 §3-2)
--       Wishlist(album/work 이중) · Commentaries(AI 캐시)
--
-- 보안(§12):
--   · 전 테이블 default-deny RLS (§12-6) — ENABLE 후 정책 없으면 접근 불가
--   · 참조 데이터/AI 캐시는 읽기전용 공용 테이블 (§12-13) — 클라이언트 쓰기 차단,
--     시드·검수 반영은 service_role(Edge Function/관리자)로만
--   · 사용자 컬렉션은 소유자 전용 (user_id = auth.uid())
--
-- 타입(§3-5): 사용자 데이터 PK는 uuid(gen_random_uuid). Works.id는 Open Opus 식별자라 text.
-- 검색: FTS5 trigram(§6-3)은 로컬 Drift(SQLite) 책임이라 여기서 다루지 않는다.
-- =============================================================================

-- gen_random_uuid() 제공 (Supabase는 보통 기본 활성이나 명시적으로 보장)
create extension if not exists pgcrypto;

-- 공통: updated_at 자동 갱신 트리거 함수
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. 참조 데이터 (캐시 · 읽기전용 공용) — §3-1, §3-7
-- ─────────────────────────────────────────────────────────────────────────────

-- 정규 작품
create table public.works (
  id             text primary key,                 -- Open Opus / MusicBrainz 식별자
  composer       text not null,
  title          text not null,                    -- 원어 정규명
  catalog_number text,                             -- BWV / K. / Op. (§3-3)
  musical_key    text,                             -- 조성
  genre          text,                             -- Open Opus genre
  period         text,                             -- 시대
  popular        boolean not null default false,   -- 자동완성 순위 (§3-7)
  recommended    boolean not null default false,   -- Open Opus recommended 플래그
  source         text not null default 'openopus', -- openopus / musicbrainz / user
  cached_at      timestamptz not null default now()
);
create index works_composer_idx on public.works (composer);
create index works_popular_idx  on public.works (popular);

-- 표준 악장 구성 (§3-1 — Movements와 구분)
create table public.work_movements (
  work_id    text not null references public.works (id) on delete cascade,
  seq        integer not null,                     -- 1, 2, 3…
  title      text not null,                        -- "II. Andante con moto"
  tempo_mark text,
  primary key (work_id, seq)
);

-- 표기 변형 별칭 (§6-3)
create table public.work_aliases (
  id           uuid primary key default gen_random_uuid(),
  work_id      text references public.works (id) on delete cascade,  -- nullable
  composer_key text,                               -- 작곡가 단위 별칭 (§3-6)
  alias        text not null,                      -- 차이코프스키 / Tchaikovsky
  language     text
);
create index work_aliases_alias_idx        on public.work_aliases (alias);
create index work_aliases_composer_key_idx on public.work_aliases (composer_key);
create index work_aliases_work_id_idx      on public.work_aliases (work_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. 사용자 컬렉션 (소유자 전용) — §3-1, §3-2
-- ─────────────────────────────────────────────────────────────────────────────

-- 음반
create table public.albums (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  title        text not null,
  label        text,                               -- 레이블
  release_year integer,
  disc_count   integer not null default 1,
  format       text,                               -- CD / LP / SACD / digital
  barcode      text,                               -- EAN-13 (중복 감지 §4-3)
  cover_url    text,                               -- 촬영본 Storage URL / 외부 URL 참조(§13-4)
  location     text,
  review       text,
  acquired_at  date,
  disposed_at  timestamptz,                        -- 처분 시점 (null=소장중)
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index albums_user_id_idx on public.albums (user_id);
create index albums_barcode_idx on public.albums (barcode);
create trigger albums_set_updated_at
  before update on public.albums
  for each row execute function public.set_updated_at();

-- 수록곡
create table public.compositions (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users (id) on delete cascade,
  album_id       uuid not null references public.albums (id) on delete cascade,
  work_id        text references public.works (id) on delete set null,  -- 미매칭 허용(§3-4)
  composer       text not null,
  catalog_number text,
  disc_no        integer,
  track_from     integer,
  track_to       integer,
  seq            integer not null default 0,       -- 음반 내 표시 순서
  confidence     text not null default 'unverified', -- confirmed / unverified (§3-4)
  created_at     timestamptz not null default now()
);
create index compositions_user_id_idx  on public.compositions (user_id);
create index compositions_album_id_idx on public.compositions (album_id);
create index compositions_work_id_idx  on public.compositions (work_id);
-- 희망 해소 감지: "내 컬렉션에 이 work 보유 여부" 조회 최적화 (§6-2)
create index compositions_user_work_idx on public.compositions (user_id, work_id);

-- 실제 수록 악장 (§3-1)
create table public.movements (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users (id) on delete cascade,
  composition_id uuid not null references public.compositions (id) on delete cascade,
  seq            integer not null,
  title          text not null,
  track_no       integer,
  duration_sec   integer
);
create index movements_user_id_idx        on public.movements (user_id);
create index movements_composition_id_idx on public.movements (composition_id);

-- ── 연주자 상속 모델 (§3-2) ──────────────────────────────────────────────────
-- role: conductor / orchestra / soloist / ensemble / vocalist
-- 음반 기본값 = album_performers. 곡별 예외 지정분만 composition_performers에 저장.
-- 상속 중인 곡은 행을 두지 않고 읽을 때 음반 기본값에서 해결한다.

create table public.album_performers (
  id       uuid primary key default gen_random_uuid(),
  user_id  uuid not null references auth.users (id) on delete cascade,
  album_id uuid not null references public.albums (id) on delete cascade,
  role     text not null,
  name     text not null
);
create index album_performers_user_id_idx  on public.album_performers (user_id);
create index album_performers_album_id_idx  on public.album_performers (album_id);

create table public.composition_performers (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users (id) on delete cascade,
  composition_id uuid not null references public.compositions (id) on delete cascade,
  role           text not null,
  name           text not null
);
create index composition_performers_user_id_idx on public.composition_performers (user_id);
create index composition_performers_comp_id_idx  on public.composition_performers (composition_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. 희망 목록 (독립 테이블 · album/work 이중) — §6-2
-- ─────────────────────────────────────────────────────────────────────────────
create table public.wishlist (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users (id) on delete cascade,
  type       text not null,                        -- 'album' | 'work'
  album_id   uuid references public.albums (id) on delete cascade,
  work_id    text references public.works (id) on delete cascade,
  priority   integer,
  note       text,
  created_at timestamptz not null default now(),
  constraint wishlist_target_ck check (
    (type = 'album' and album_id is not null and work_id is null) or
    (type = 'work'  and work_id  is not null and album_id is null)
  )
);
create index wishlist_user_id_idx  on public.wishlist (user_id);
create index wishlist_album_id_idx on public.wishlist (album_id);
create index wishlist_work_id_idx  on public.wishlist (work_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. AI 해설 캐시 (공용 · 읽기전용) — §7
--    캐시 키 = (work_id, language). version/cached_at으로 무효화.
--    생성·쓰기는 Edge Function(service_role) 경유. 클라이언트 직접 쓰기 금지.
-- ─────────────────────────────────────────────────────────────────────────────
create table public.commentaries (
  work_id   text not null references public.works (id) on delete cascade,
  language  text not null,
  body      text not null,
  version   integer not null default 1,
  cached_at timestamptz not null default now(),
  primary key (work_id, language)
);

-- =============================================================================
-- RLS — 전 테이블 default-deny (§12-6)
-- =============================================================================
alter table public.works                  enable row level security;
alter table public.work_movements         enable row level security;
alter table public.work_aliases           enable row level security;
alter table public.commentaries           enable row level security;
alter table public.albums                 enable row level security;
alter table public.compositions           enable row level security;
alter table public.movements              enable row level security;
alter table public.album_performers       enable row level security;
alter table public.composition_performers enable row level security;
alter table public.wishlist               enable row level security;

-- ── 참조 데이터/AI 캐시: 인증 사용자 읽기 전용 (§12-13) ────────────────────────
-- INSERT/UPDATE/DELETE 정책을 두지 않으므로 클라이언트 쓰기는 차단된다.
-- 시드·검수 반영은 RLS를 우회하는 service_role로만 수행한다.
create policy works_read          on public.works          for select to authenticated using (true);
create policy work_movements_read on public.work_movements for select to authenticated using (true);
create policy work_aliases_read   on public.work_aliases   for select to authenticated using (true);
create policy commentaries_read   on public.commentaries   for select to authenticated using (true);

-- ── 사용자 컬렉션: 소유자 전용 (전 CRUD) ─────────────────────────────────────
create policy albums_owner on public.albums
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy compositions_owner on public.compositions
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy movements_owner on public.movements
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy album_performers_owner on public.album_performers
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy composition_performers_owner on public.composition_performers
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy wishlist_owner on public.wishlist
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- =============================================================================
-- 소유권 정합 검증 — 자식 행의 user_id가 부모의 user_id와 일치하는지 강제
--   RLS(user_id = auth.uid())만으로는 "내 user_id + 남의 부모"의 조합을 막지 못한다.
-- =============================================================================
create or replace function public.assert_parent_owner()
returns trigger language plpgsql as $$
declare
  parent_owner uuid;
begin
  case tg_table_name
    when 'compositions' then
      select user_id into parent_owner from public.albums where id = new.album_id;
    when 'movements' then
      select user_id into parent_owner from public.compositions where id = new.composition_id;
    when 'album_performers' then
      select user_id into parent_owner from public.albums where id = new.album_id;
    when 'composition_performers' then
      select user_id into parent_owner from public.compositions where id = new.composition_id;
  end case;

  if parent_owner is null or parent_owner <> new.user_id then
    raise exception 'owner mismatch: % row user_id % does not match parent owner %',
      tg_table_name, new.user_id, parent_owner;
  end if;
  return new;
end;
$$;

create trigger compositions_assert_owner
  before insert or update on public.compositions
  for each row execute function public.assert_parent_owner();

create trigger movements_assert_owner
  before insert or update on public.movements
  for each row execute function public.assert_parent_owner();

create trigger album_performers_assert_owner
  before insert or update on public.album_performers
  for each row execute function public.assert_parent_owner();

create trigger composition_performers_assert_owner
  before insert or update on public.composition_performers
  for each row execute function public.assert_parent_owner();
