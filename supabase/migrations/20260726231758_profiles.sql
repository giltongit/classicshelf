-- =============================================================================
-- profiles — 사용자별 앱 설정 (도서관 이름 · 기록 시작일)
-- =============================================================================
-- 정본 스키마(20260725052147_init_classical_schema.sql)에서 누락된 테이블.
-- ProfileRepositoryImpl이 참조하나 테이블이 없어 설정 화면의 도서관 이름 저장
-- (setLibraryName)이 예외로 끝났다. 초기 마이그레이션은 이미 원격에 적용돼
-- 수정 대상이 아니므로 별도 마이그레이션으로 추가한다.
--
-- user_id를 PK로 두는 게 핵심: 리포지토리가 upsert({'user_id': uid, ...})를
-- 쓰므로 충돌 판정을 위한 유니크 제약이 user_id에 있어야 한다.
-- (PK 없이는 upsert가 매번 새 행을 만들거나 에러가 난다)
--
-- 보안(§12): 다른 사용자 테이블과 동일한 소유자 전용 RLS.
--   익명 로그인 사용자도 role이 authenticated이므로 이 정책 아래서 자기 행만 본다.
-- =============================================================================

create table public.profiles (
  user_id             uuid primary key references auth.users (id) on delete cascade,
  library_name        text,
  tracking_started_at date,
  updated_at          timestamptz not null default now()
);

-- RLS — default-deny 후 소유자 전용 정책 (§12-6)
alter table public.profiles enable row level security;

create policy profiles_owner on public.profiles
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- updated_at 자동 갱신 — albums 등과 동일 패턴.
-- default now()는 insert에만 걸리므로, upsert의 update 경로까지 덮으려면 트리거가 필요.
-- (set_updated_at 함수는 초기 마이그레이션에서 이미 생성됨)
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();
