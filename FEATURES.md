# Bookshelf — 기능 정리

개인 도서 관리용 Flutter 앱. 로컬 SQLite 저장 + Google Sheets 동기화 + 표지 사진 Drive 업로드 + 바코드 스캔/검색을 제공한다.

본 문서는 `C:\Users\DSU\Desktop\learningapple\bookshelf_sheets\bookshelf\` 기준의 현 시점 코드를 그대로 반영한다.

---

## 1. 프로젝트 개요

| 항목 | 값 |
|---|---|
| 이름 | Bookshelf (`pubspec.yaml.name`) |
| 버전 | 1.0.0+1 |
| Dart SDK | ^3.11.5 |
| 플랫폼 | Android (AndroidManifest 기준), iOS는 미설정 |
| 상태 관리 | `provider` 6.x (Riverpod 아님) |
| 로컬 DB | `sqflite` 2.x (Drift 아님) |
| 라우팅 | `go_router` 14.x (StatefulShellRoute 사용) |
| 네트워크 | `http` 1.x + `connectivity_plus` |
| 백엔드 | **Google Apps Script 웹훅** (시트 동기화 + 표지 업로드 통합) |

### 디렉토리 구조

```
lib/
├── main.dart                     # MultiProvider 진입점
├── models/
│   ├── book.dart                 # Book + toMap/fromMap (sqflite 매핑)
│   └── book_search_result.dart   # 네이버/Google Books 통합 모델
├── providers/
│   ├── book_provider.dart        # 책장 상태 + 시트 동기화 오케스트레이션
│   └── cover_upload_provider.dart # 표지 펜딩 큐 + 업로드 상태
├── services/
│   ├── database_service.dart     # sqflite 래퍼 (v4 스키마)
│   ├── sheets_service.dart       # Apps Script upsert/list/delete/stats
│   ├── book_search_service.dart  # 네이버 → Google Books 폴백 검색
│   ├── cover_photo_service.dart  # 카메라/갤러리 → 리사이즈 → 캐시
│   ├── cover_upload_service.dart # Drive 업로드 (Apps Script 경유)
│   ├── connectivity_service.dart # 온라인/오프라인 감지
│   └── backup_service.dart       # JSON 내보내기/가져오기
├── screens/
│   ├── home_screen.dart          # 탭 셸 (서재/집계/통계)
│   ├── book_list_screen.dart     # 도서 목록
│   ├── book_detail_screen.dart   # 도서 상세
│   ├── add_book_screen.dart      # 추가/수정 폼
│   ├── search_screen.dart        # 도서 검색
│   ├── scan_screen.dart          # 바코드 스캔
│   ├── aggregate_screen.dart     # 초성/알파벳 집계
│   ├── stats_screen.dart         # 차트/분포
│   └── settings_screen.dart      # 설정 (시트 URL/백업/캐시)
├── widgets/
│   ├── book_card.dart            # 목록 카드
│   ├── cover_photo_picker.dart   # 추가 화면의 표지 영역
│   ├── pending_upload_banner.dart # 표지 업로드 대기 배너
│   └── offline_banner.dart       # 오프라인 알림 배너
├── core/cache/
│   └── book_cover_cache_manager.dart # 표지 캐시 매니저 (150개/30일)
├── router/
│   └── app_router.dart           # GoRouter 설정
└── utils/
    ├── constants.dart            # 색상/문자열/enum (ReadingStatus, SyncState 등)
    ├── cover_color.dart          # placeholder 해시 색
    └── sort_utils.dart           # 숫자→한국어→영어 정렬

apps_script/
├── Code.gs                       # 클라우드 Apps Script 로컬 사본
└── cover_upload.gs               # 표지 업로드 함수 (통합용 참고)
```

---

## 2. 데이터 모델

### 2.1 `Book` ([lib/models/book.dart](lib/models/book.dart))

| 필드 | 타입 | 비고 |
|---|---|---|
| `id` | String | UUID v4. PRIMARY KEY |
| `title` | String | 필수 |
| `author` | String | 필수 |
| `isbn` | String? | 정규화 시 하이픈/공백 무시 |
| `coverUrl` | String? | http(s) URL 또는 **로컬 캐시 경로** (펜딩 상태) |
| `description` | String? | 책 소개 |
| `status` | ReadingStatus | `owned`(소장본) / `wishlist`(희망도서) |
| `review` | String? | 사용자 메모 |
| `pageCount` | int? | 총 페이지 |
| `year` | String? | 출판연도 (4자리 문자열) |
| `genre` | String? | 장르 |
| `publisher` | String? | 출판사 |
| `location` | String? | 책장 위치 (예: "1층 A서가") |
| `priorityRead` | bool | 우선읽기 표식 (로컬 전용, 시트 미동기화) |
| `createdAt` / `updatedAt` | DateTime | ISO8601 저장 |

### 2.2 SQLite 스키마 ([lib/services/database_service.dart](lib/services/database_service.dart))

- 테이블명 `books`. 컬럼명은 snake_case (`cover_url`, `priority_read`, `created_at` …)
- 마이그레이션 이력:
  - v2 → v3: `year TEXT` 추가
  - v3 → v4: `priority_read INTEGER NOT NULL DEFAULT 0` 추가
- 현재 버전: **v4**

### 2.3 `BookSearchResult` ([lib/models/book_search_result.dart](lib/models/book_search_result.dart))

네이버/Google Books 응답을 단일 형태로 흡수하는 모델.
- `fromNaver()`: ISBN은 공백 분리, 저자는 `^` 분리, 제목/설명은 HTML 태그 제거
- `fromJson()`(Google): `industryIdentifiers` 배열에서 ISBN_13/10 추출, http→https 변환

---

## 3. 화면 구조와 라우팅

`StatefulShellRoute.indexedStack` 으로 하단 탭 3개를 유지한다. 그 외 화면은 푸시로 진입.

```
GoRouter (lib/router/app_router.dart)
├── /            ─ Shell ─ [BookListScreen]  ← 탭 0: 내 서재
├── /aggregate   ─ Shell ─ [AggregateScreen] ← 탭 1: 집계
├── /stats       ─ Shell ─ [StatsScreen]    ← 탭 2: 통계
├── /books/:id           [BookDetailScreen]
├── /books/:id/edit      [AddBookScreen(book)]
├── /add                 [AddBookScreen(searchResult?)]
├── /search              [SearchScreen]
├── /scan                [ScanScreen]
└── /settings            [SettingsScreen]
```

### 3.1 HomeScreen ([lib/screens/home_screen.dart](lib/screens/home_screen.dart))
- 상단 AppBar: 동적 제목 + 액션 아이콘 (스캔/검색/직접입력/동기화 상태/설정)
- `OfflineBanner` + `PendingUploadBanner` 를 본문 상단에 항상 노출
- `_SyncIndicator`: 4상태(idle/syncing/done/error) 머신을 아이콘으로 표시. error 클릭 시 메시지 다이얼로그
- FAB(+): `_showAddSheet` — 바코드 스캔 / 제목 검색 / 직접 입력 3가지 진입로

### 3.2 BookListScreen
- 검색창 + 정렬 버튼 + 필터 탭(전체/소장본/희망도서/우선읽기) + 책 카드 리스트
- 검색은 `BookProvider.setSearchQuery()` 로 즉시 필터링
- 정렬은 모달 시트로 `SortOption` 선택 (제목순 / 저자순 / 책장위치순)
- 카드 탭 → `/books/:id`

### 3.3 BookDetailScreen
- SliverAppBar로 표지 풀스크린 배경 + 제목/저자 오버레이
- 정보 행(`출판사`, `출판연도`, `장르`, `책장 위치`, `ISBN`, `총 페이지`)은 값 있을 때만 표시
- 책 소개/메모 섹션
- 하단 상태 전환 버튼: 소장본 ↔ 희망도서
- AppBar 액션: 수정/삭제

### 3.4 AddBookScreen
- 신규 등록 / 검색결과 프리필 / 기존 책 수정 3가지 모드를 한 화면으로 처리
- 상단 표지 영역은 `CoverPhotoPicker` (촬영/갤러리/오프라인 다이얼로그)
- `ListenableBuilder([_coverUrl, _title])` 로 표지/제목 변경 즉시 미리보기 재계산
- ISBN 중복 검사 (`BookProvider.findByIsbn`) — 신규 등록 시 자동 체크 후 "이미 입력하셨습니다" 다이얼로그
- 업로드 중에는 상단 우측 저장 버튼이 spinner로 대체되어 동시 저장 방지

---

## 4. 도서 검색 (네이버 → Google Books 폴백)

[lib/services/book_search_service.dart](lib/services/book_search_service.dart)

### 4.1 검색 우선순위

| 입력 | 1차 | 2차(폴백) |
|---|---|---|
| 일반 텍스트 | 네이버 `book.json` | Google Books `q=` |
| ISBN 13/10 | 네이버 `book_adv.json?d_isbn=` | Google Books `isbn:` |

- 네이버 자격증명은 `.env`의 `NAVER_CLIENT_ID` / `NAVER_CLIENT_SECRET`에서 로드 (flutter_dotenv)
- 타임아웃: 10초
- 한국 책 우선 정책 (네이버 우선) — Google은 자국어/영문 위주

### 4.2 SearchScreen ([lib/screens/search_screen.dart](lib/screens/search_screen.dart))
- 자동 검색: 2글자 이상 입력 시 500ms 디바운스 후 호출
- 결과 카드 탭 → `/add` 로 BookSearchResult 전달 (프리필 입력)
- 4상태 뷰: 입력 전 힌트 / 로딩 / 에러(다시 시도) / 빈 결과

---

## 5. 바코드 스캔 (ISBN)

[lib/screens/scan_screen.dart](lib/screens/scan_screen.dart) + `mobile_scanner` 7.x

### 동작
1. 카메라 자동 시작, 1.8초 주기로 골드색 스윕 라인 애니메이션
2. 바코드 감지 → 숫자/X만 추출 → 13자리 또는 10자리만 유효
3. 카메라 정지 → "책 정보 검색 중…" 오버레이 → `BookSearchService.searchByISBN()` 호출
4. 검색 성공 → `/add` 푸시 (프리필) → 복귀 시 자동 재스캔 모드
5. 검색 실패 → "찾을 수 없습니다" 카드 + [다시 스캔] / [직접 입력]
6. 손전등 토글 (AppBar)
7. **수동 ISBN 입력 바**: 카메라가 안 잡을 때 직접 13자리 입력 후 조회

### 중복 감지 방지
- `MobileScannerController.detectionSpeed: noDuplicates`
- `_busy` 플래그로 동일 프레임 중복 처리 방지
- `_reset()`에서 stop→start로 noDuplicates 캐시 초기화

---

## 6. 표지 사진 (촬영 → 리사이즈 → Drive 업로드)

이 영역은 PHASE 1~5 진단/수정 작업의 핵심이었다. 데이터 흐름은 다음과 같다.

### 6.1 흐름도

```
[1] image_picker (200×300, q80)         ── cover_photo_service.dart::pickAndResize
    ↓
[2] image 패키지 재리사이즈 + JPEG 인코딩 ── cover_photo_service.dart
    ↓
[3] getApplicationCacheDirectory/        ── cover_photo_service.dart::_saveToCache
    pending_covers/pending_{isbn|ts}.jpg
    ↓ (online?)
   ├── 온라인 → 즉시 업로드
   │   ↓
   │   [4] base64 인코딩
   │   ↓
   │   [5] HTTP POST text/plain → Apps Script (action=uploadCover)
   │   ↓ (302 chain 수동 추적)
   │   [6] {ok, url, id} 파싱
   │   ↓
   │   onChanged(url) → Book.coverUrl = "https://lh3.googleusercontent.com/d/<id>"
   │
   └── 오프라인 / 실패 → 펜딩 큐 추가
       ↓
       Book.coverUrl = localPath (로컬 캐시 파일 경로)
       ↓
       PendingUploadBanner 표시
       ↓ ("지금 업로드" 탭 또는 온라인 복귀 시)
       flushPending → 큐 항목별로 위 [4]~[6] 반복
       ↓
       BookProvider.replaceCoverByLocalPath(localPath, newUrl)
       ↓
       Book.coverUrl 갱신 + Sheets upsert
```

### 6.2 단계별 디버그 로그 ([COVER][1]~[7])

PowerShell `flutter run` 콘솔에서 다음 순서로 출력된다:

| 태그 | 위치 | 의미 |
|---|---|---|
| `[COVER][1]` | cover_photo_service.dart | 카메라/갤러리 촬영 완료 + 경로 |
| `[COVER][2]` | cover_photo_service.dart | 캐시에 임시 저장 완료 |
| `[COVER][3]` | cover_upload_service.dart | Apps Script URL 확보 (=인증 자원 OK) |
| `[COVER][4]` | cover_upload_service.dart | Drive 업로드 성공 (fileId 추출) |
| `[COVER][5]` | cover_upload_service.dart | 공개 URL 응답 수신 |
| `[COVER][6]` | book_provider.dart | DB의 coverUrl을 lh3 URL로 교체 완료 |
| `[COVER][7]` | pending_upload_banner.dart | 배너 상태 갱신 (pending 카운트) |

### 6.3 PendingUploadBanner ([lib/widgets/pending_upload_banner.dart](lib/widgets/pending_upload_banner.dart))

- 펜딩 0건 → `SizedBox.shrink()`로 사라짐
- 정상 상태: 골드 톤 배경 + "표지 사진 N건 업로드 대기 중" + **[지금 업로드]** 버튼
- 업로드 중: spinner 표시
- 에러 상태: **빨강 톤 배경** + 두 번째 줄에 에러 메시지 영구 표시 + **[재시도]** + (×) 닫기
- (×) 탭 → `cover.clearError()` — 에러만 해제, 펜딩은 유지

### 6.4 표지 표시 ([lib/widgets/book_card.dart](lib/widgets/book_card.dart))

- `coverUrl`이 `http://` / `https://` 로 시작 → `CachedNetworkImage(BookCoverCacheManager.toThumbnailUrl(v))`
- 그 외 (로컬 경로) → `Image.file(File(v))`
- 둘 다 실패 시 placeholder (제목 첫 글자 + 해시색 + 📚)

### 6.5 캐시 매니저 ([lib/core/cache/book_cover_cache_manager.dart](lib/core/cache/book_cover_cache_manager.dart))

- 정책: 최대 150개, 30일 stale
- `toThumbnailUrl`:
  - `lh3.googleusercontent.com/d/<id>` Drive URL → **변환 없이 그대로** (이번 라운드에서 수정됨)
  - Google Books URL → http→https, `zoom=1` 강제, `edge=curl` 제거
  - 그 외 URL → http→https만

### 6.6 Apps Script 측 ([apps_script/Code.gs](apps_script/Code.gs))

```javascript
function doPost(e) {
  const data = JSON.parse(e.postData.contents);
  const action = data.action || 'upsert';
  if (action === 'upsert' || action === 'add') return handleUpsert(data);
  if (action === 'update')                     return handleUpdate(data);
  if (action === 'uploadCover')                return handleUploadCover(data);
  // ...
}
function handleUploadCover(data) {
  return jsonResponse(uploadCover_(data));
}
function uploadCover_(payload) {
  // base64 decode → DriveApp.createFile → setSharing(ANYONE_WITH_LINK)
  // → 'https://lh3.googleusercontent.com/d/' + fileId
}
```

- 저장 폴더: `BookshelfCovers` (없으면 자동 생성)
- `setSharing`은 try/catch로 swallow됨 (워크스페이스 정책 차단 시 무시)
- **새 버전 배포 필수**: 변경 후 [배포 → 배포 관리 → 새 버전] 안 하면 클라이언트는 옛 버전 호출

---

## 7. Google Sheets 동기화

[lib/services/sheets_service.dart](lib/services/sheets_service.dart)

### 7.1 액션과 응답 규약

| Action | HTTP | 용도 |
|---|---|---|
| `upsert` | POST | 책 신규 등록/갱신 (UUID 기준) |
| `delete` | GET (`?action=delete&uuid=`) | 책 삭제 |
| `list` | GET (`?action=list`) | 시트 전체 책 조회 |
| `stats` | GET (`?action=stats`) | 연결 테스트용 |
| `uploadCover` | POST | 표지 업로드 |

- POST 본문: `Content-Type: text/plain;charset=utf-8` (CORS preflight 회피)
- 302 리다이렉트는 수동 추적 (최대 5회). Apps Script가 `script.googleusercontent.com`으로 리다이렉트하는 패턴 대응
- HTML 응답(인증 페이지 등)은 `_safeJsonDecode`에서 의미 있는 에러로 변환

### 7.2 책 매핑 (Book → 페이로드)

```dart
{
  'uuid': b.id,
  'isbn': b.isbn ?? '',
  'title': b.title,
  'author': b.author,
  'publisher': b.publisher ?? '',
  'year': b.year ?? '',
  'language': _isKorean(b.title) ? 'ko' : '',
  'location': b.location ?? '',
  'memo': b.review ?? '',
  'cover_url': b.coverUrl ?? '',
  'status': b.status == owned ? 'owned' : 'wishlist',
  'genre': b.genre ?? '',
  'page_count': b.pageCount?.toString() ?? '',
  'updated_at': b.updatedAt.toIso8601String(),
  // rating/current_page/start_date/finish_date 는 더 이상 사용 안 함 → 빈 값
}
```

### 7.3 동기화 트리거 ([lib/providers/book_provider.dart](lib/providers/book_provider.dart))

- `addBook` / `updateBook` / `deleteBook` 호출 후 자동으로 `_pushToSheets()` 실행
- `togglePriorityRead`는 **로컬만** — 시트 컬럼이 없고 토글 빈도가 높아 네트워크 비효율
- `pushAllToSheets()`: 설정 화면 "전체 푸시" — 로컬→시트 일괄
- `pullFromSheets()`: 설정 화면 "시트에서 가져오기" — UUID 기준 머지 (없으면 추가, 시트가 더 최신이면 갱신)

### 7.4 SyncState 머신

| 상태 | 진입 | 종료 |
|---|---|---|
| `idle` | 초기 | — |
| `syncing` | 모든 CRUD/푸시/풀 시작 | 완료 → done, 실패 → error |
| `done` | 성공 후 2초 자동 idle 복귀 | — |
| `error` | 실패 시. 30초 후 자동 idle. 사용자 탭으로 즉시 해제 | — |

상단 우측 `_SyncIndicator`가 이 상태를 아이콘으로 표시.

---

## 8. 오프라인 처리

[lib/services/connectivity_service.dart](lib/services/connectivity_service.dart) + `connectivity_plus`

- `Connectivity().onConnectivityChanged` 구독
- 결과 리스트에 `none`이 아닌 항목이 하나라도 있으면 온라인 판정
- `OfflineBanner`: 오프라인일 때만 34px 골드 띠 표시 ("오프라인 모드 — 로컬 데이터를 표시합니다")
- 표지 펜딩 큐는 온라인 복귀 시 자동 flush ([cover_upload_provider.dart:175-179](lib/providers/cover_upload_provider.dart:175))

---

## 9. 정렬 / 필터 / 검색

### 9.1 정렬 ([lib/utils/sort_utils.dart](lib/utils/sort_utils.dart))

`bookshelfCompare()` 공통 규칙:

| 부류 | 우선순위 |
|---|---|
| 숫자 (0-9) | 1 |
| 한국어 (한글 음절·자모) | 2 |
| 영어·기타 | 3 |
| 빈 문자열 | 4 |

같은 부류 안에선 대소문자 무시 알파벳/가나다 순. 책장 위치 정렬에서는 앞쪽 숫자를 자연 수치로 비교 (1층 < 2층 < 10층).

### 9.2 필터 (BookFilter)

`전체` / `소장본` / `희망도서` / `우선읽기` 4개. 각 탭에 카운트 배지 표시.

### 9.3 검색

- 화면 상단 검색창 → `BookProvider.setSearchQuery()` 즉시 필터링
- 매칭 대상: `title`, `author`, `genre`, `location` (소문자 substring)

---

## 10. 통계 ([lib/screens/stats_screen.dart](lib/screens/stats_screen.dart))

### 10.1 Summary Card Grid
- 전체 / 소장본 / 희망도서 3카드 (2열 그리드)

### 10.2 월별 추가 막대그래프
- 최근 6개월 등록 권수, 비율 기반 막대 (애니메이션 600ms)

### 10.3 장르 분포
- 상위 6개 장르, 최댓값 대비 가로 막대

### 10.4 출판연도 분포
- 등록된 모든 연도, 오름차순, 가로 막대 (골드 컬러)

---

## 11. 집계 ([lib/screens/aggregate_screen.dart](lib/screens/aggregate_screen.dart))

제목 첫 글자로 그룹핑한 표 형태 화면.

### 분류 키 산출 (`_groupKeyFor`)
- 숫자(0-9) → 해당 숫자
- 한글 음절 → 14개 기본 자음(초성) 중 하나 (쌍자음은 기본 자음으로 통합: `ㄲ`→`ㄱ`, `ㄸ`→`ㄷ`, …)
- 영문 → 소문자로 통합 표시
- 그 외(특수문자/이모지) → 집계 제외

### 표 구성
- 헤더: `시작 | 전체 | 소장본 | 희망도서`
- 행 탭 → 해당 그룹의 책 목록을 모달 시트로 (DraggableScrollableSheet, 0.3~0.9 비율)
- 하단 고정 합계 행 (총합 / 소장본 / 희망도서)

---

## 12. 백업/복원 ([lib/services/backup_service.dart](lib/services/backup_service.dart))

### 12.1 내보내기 (`exportJson`)
- 형식:
  ```json
  {
    "version": 1,
    "exported_at": "2025-...",
    "count": N,
    "books": [...Book.toMap()...]
  }
  ```
- 파일명: `bookshelf_backup_yyyyMMdd_HHmmss.json`
- 저장 위치: `getApplicationDocumentsDirectory()`
- `share_plus`로 공유 시트 자동 호출

### 12.2 가져오기 (`importJson`)
- `file_picker`로 .json 선택
- `Book.fromMap()`로 역직렬화
- `BookProvider.importBooks()`가 **id 중복은 skip**, 신규만 추가

---

## 13. 캐시 관리

### 13.1 표지 캐시 ([lib/core/cache/book_cover_cache_manager.dart](lib/core/cache/book_cover_cache_manager.dart))
- key: `bookCoverCache`
- 위치: `getTemporaryDirectory()/bookCoverCache/`
- 정책: 최대 150 객체, 30일 stale
- 사용처: `CachedNetworkImage(cacheManager: BookCoverCacheManager())`

### 13.2 펜딩 표지 캐시
- 위치: `getApplicationCacheDirectory()/pending_covers/` (폴백: `getTemporaryDirectory()`)
- 파일명: `pending_{isbn|timestamp}.jpg`
- 앱 시작 시 `CoverUploadProvider._restorePending()`로 디스크에서 큐 복원

### 13.3 설정 화면에서 캐시 관리
- 현재 캐시 크기 표시 (B/KB/MB)
- "지우기" 탭 → `BookCoverCacheManager().emptyCache()` 호출

---

## 14. 권한 / 환경 설정

### 14.1 Android 권한 ([AndroidManifest.xml](android/app/src/main/AndroidManifest.xml))
- `CAMERA`: 바코드 스캔 + 표지 촬영
- `INTERNET`: 검색/동기화/업로드
- `FLASHLIGHT`: 스캔 시 손전등
- `READ_MEDIA_IMAGES`: 갤러리 (Android 13+)
- `READ_EXTERNAL_STORAGE` (maxSdkVersion=32): 구버전 갤러리 호환

### 14.2 환경변수 (.env)
- `NAVER_CLIENT_ID`: 네이버 검색 API
- `NAVER_CLIENT_SECRET`: 네이버 검색 API

### 14.3 SharedPreferences 키
- `sheets_webhook_url`: Apps Script 웹앱 URL (시트 동기화 + 표지 업로드 공통)
- `sheets_sync_enabled`: 동기화 ON/OFF 플래그

---

## 15. 테마 / UI 시스템 ([lib/utils/constants.dart](lib/utils/constants.dart))

다크 골드 팔레트 (웹 앱의 CSS 변수에서 추출). 한글은 `google_fonts.notoSansKr` 자동 적용.

| 색상 | Hex | 용도 |
|---|---|---|
| `bg` | #0F0E0C | 화면 배경 |
| `surface` / `surface2` / `surface3` | #1A1915 / #23211D / #2A2720 | 카드/입력 계층 |
| `gold` | #C8A96E | 주요 액션 |
| `gold2` | #E8C98A | 강조 |
| `cream` | #F0E6D3 | 본문 텍스트 |
| `muted` | #7A7060 | 보조 텍스트 |
| `dim` | #4A4538 | 더 흐린 텍스트 |
| `green` | #2ECC71 | 성공 |
| `red` | #E74C3C | 에러/삭제 |

---

## 16. 진단/디버깅 가이드

### 16.1 표지 업로드 검증 시나리오 A (전체 7단계 확인)

1. 기내모드 ON
2. 직접 입력 → 표지 촬영 → 책 저장 (`[COVER][1]`, `[COVER][2]`, `[COVER][7]` 로그)
3. 기내모드 OFF
4. "지금 업로드" 탭 (`[COVER][3]` → `[4]` → `[5]` → `[6]` → `[7]`)
5. 배너 자동 소멸 + 책 카드의 표지가 로컬→lh3 URL로 교체

### 16.2 자주 발생하는 실패

| 증상 | 원인 | 조치 |
|---|---|---|
| "Apps Script URL이 설정되지 않았습니다" | SharedPreferences 키 미저장 | 설정 화면에서 URL 등록 |
| "알 수 없는 액션" | Apps Script에 `case 'uploadCover'` 분기 없음 또는 미배포 | Code.gs 분기 추가 + **새 버전 배포** |
| "JSON 파싱 실패" | Apps Script가 HTML 응답 (인증 페이지 등) | 배포의 "Access: Anyone" 확인, URL 검증 |
| 책 카드 표지에 placeholder만 보임 (URL은 lh3) | `setSharing` 실패 (워크스페이스 정책) | 개인 Google 계정으로 Apps Script 배포 |
| 책 카드 자체가 안 보임 + 펜딩만 쌓임 | 표지 촬영만 하고 책 저장 안 함 | 저장 버튼까지 탭 확인 |

### 16.3 PowerShell 빠른 점검

```powershell
# Apps Script 연결 확인 (action=stats)
$url = "<설정 화면에 등록된 URL>"
Invoke-WebRequest -Uri "$url`?action=stats" -MaximumRedirection 5 | Select-Object -ExpandProperty Content
# 예상: {"ok":true,"total":N}

# 표지 업로드 단독 테스트 (Apps Script 통합 확인)
$body = '{"action":"uploadCover","filename":"probe.jpg","mime":"image/jpeg","data":"/9j/4AAQ..."}'
Invoke-WebRequest -Uri $url -Method POST -Body $body -ContentType "text/plain;charset=utf-8" -MaximumRedirection 5
# 예상: {"ok":true,"url":"https://lh3.googleusercontent.com/d/...","id":"..."}
```

---

## 17. 알려진 한계 / 향후 작업 후보

- iOS 빌드 미설정 (Info.plist의 카메라/사진 권한 항목, CocoaPods 설정 필요)
- 표지 압축은 200×300 고정 (망원 책 표지는 비율 손실 가능 — 현재는 `copyResize`로 강제 변형)
- 펜딩 큐는 같은 ISBN으로 여러 번 촬영 시 파일명이 동일해 마지막 것만 남음
- `BookProvider.replaceCoverByLocalPath`는 정확한 문자열 일치로 매칭 — 책이 저장 안 된 채 펜딩만 쌓이면 DB 갱신 0건 (큐는 비워지지만 책장에 영향 없음)
- Sheets 동기화는 단일 시트 가정. 다중 시트/사용자 분리 미지원
- 우선읽기는 시트 컬럼이 없어 기기 간 동기화 안 됨
- Apps Script 호출은 직렬 — 대량 일괄 업로드 시 시간이 길어질 수 있음

---

_본 문서는 `C:\Users\DSU\Desktop\learningapple\bookshelf_sheets\bookshelf` 의 현 시점 코드를 기준으로 자동 정리되었다. 코드 변경 시 함께 갱신할 것._
