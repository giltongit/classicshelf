import 'package:go_router/go_router.dart';

import '../models/album_draft.dart';
import '../screens/add_book_screen.dart';
import '../screens/barcode_scan_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/book_list_screen.dart';
import '../screens/home_screen.dart';
import '../screens/main_scaffold.dart';
import '../screens/settings_screen.dart';
import '../screens/wishlist_screen.dart';

// TODO: 클래식 재작성 (2B)
//   2A에서 제거한 라우트: /stats(+year/author/monthly/wishlist/genre),
//   /search, /book-search, /csv-import.
//   해당 화면 파일은 모두 삭제됨. 클래식 탭·라우트 구성은 2B에서 확정한다.

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // ── 하단 탭 4개 (홈 / 서가 / 희망 / 설정) ────────────────────────────────
    // 아래 branches 개수는 main_scaffold 의 BottomNavigationBarItem 개수와
    // 반드시 같아야 한다(불일치 시 런타임 크래시). 순서도 일치시킬 것.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const AlbumListScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/wishlist',
            builder: (context, state) => const WishlistScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ]),
      ],
    ),

    // ── 탭 외부 라우트 (하단 탭 없음) ────────────────────────────────────────
    // 등록·편집 공용. ?albumId=… 가 붙으면 편집 모드로 pre-fill 한다.
    //   extra 대신 쿼리 파라미터를 쓰는 이유: 딥링크·복원에서 살아남고,
    //   폼이 필요한 건 id 하나뿐이라 객체를 넘길 이유가 없다(로컬에서 다시 읽는다).
    //
    // 자동입력(대 2)은 반대로 extra를 쓴다: 초안은 저장된 적 없는 일회성
    // 객체라 URL로 표현할 id가 없고, Discogs 조회 결과를 URL·복원 이력에
    // 남기지 않는 편이 캐시 금지 제약을 지키기도 쉽다. 복원 시 extra가
    // 사라지면 그냥 빈 등록 폼이 된다 — 잃을 게 없는 값이다.
    GoRoute(
      path: '/add',
      builder: (context, state) => AddAlbumScreen(
        albumId: state.uri.queryParameters['albumId'],
        draft: state.extra is AlbumDraft ? state.extra as AlbumDraft : null,
      ),
    ),
    // 바코드 스캔 → Discogs 조회 → /add 로 초안 전달 (§4-1 수렴 모델).
    GoRoute(
      path: '/scan',
      builder: (context, state) => const BarcodeScanScreen(),
    ),
    // 앨범 id는 클라이언트 생성 UUID(String)다. book 시절의 int localId 파싱을
    // 그대로 두면 UUID에서 예외가 나므로 경로도 /albums/:id 로 옮겼다.
    GoRoute(
      path: '/albums/:id',
      builder: (context, state) => AlbumDetailScreen(
        albumId: state.pathParameters['id']!,
      ),
    ),
  ],
);
