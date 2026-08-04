import 'package:go_router/go_router.dart';

import '../screens/add_book_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/book_list_screen.dart';
import '../screens/home_screen.dart';
import '../screens/main_scaffold.dart';
import '../screens/settings_screen.dart';
import '../screens/wishlist_screen.dart';

// TODO: 클래식 재작성 (2B)
//   2A에서 제거한 라우트: /stats(+year/author/monthly/wishlist/genre),
//   /search, /book-search, /scan, /csv-import.
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
    // TODO: 2B-2b — 검색 결과 프리필(대 2 자동입력)이 생기면 그때 extra 분기 추가.
    GoRoute(
      path: '/add',
      builder: (context, state) => AddAlbumScreen(
        albumId: state.uri.queryParameters['albumId'],
      ),
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
